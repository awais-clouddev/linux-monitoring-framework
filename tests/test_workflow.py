import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class WorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        scripts = self.root / "scripts"
        scripts.mkdir()
        self.runner = scripts / "run_all_checks.sh"
        self.runner.write_text((ROOT / "scripts/run_all_checks.sh").read_text())
        for name in ("cpu_check", "ram_check", "disk_check", "network_check",
                     "service_check", "update_dashboard", "generate_report"):
            p = scripts / f"{name}.sh"
            p.write_text("#!/bin/sh\nexit 0\n")
            p.chmod(0o755)
        self.logs = self.root / "logs"
        self.logs.mkdir()
        self.log = self.logs / "system_health.log"
        self.env = dict(os.environ, LOG_MAX_BYTES="10", LOG_KEEP="2")

    def run_workflow(self):
        return subprocess.run(
            ["bash", str(self.runner)], env=self.env,
            capture_output=True, text=True, timeout=15
        )

    def test_reduced_retention_and_rotation(self):
        for i in range(1, 6):
            (self.logs / f"system_health.log.{i}").write_text(f"archive-{i}")
        self.log.write_text("current-" + "x" * 20)
        r = self.run_workflow()
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(
            sorted(p.name for p in self.logs.glob("system_health.log.*")),
            ["system_health.log.1", "system_health.log.2"]
        )
        self.assertTrue((self.logs / "system_health.log.1").read_text().startswith("current-"))
        self.assertEqual((self.logs / "system_health.log.2").read_text(), "archive-1")
        self.assertIn("Monitoring workflow completed successfully.", self.log.read_text())

    def test_retention_cleanup_without_rotation(self):
        self.env["LOG_MAX_BYTES"] = "999999"
        self.log.write_text("previous\n")
        (self.logs / "system_health.log.5").write_text("old")
        r = self.run_workflow()
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertFalse((self.logs / "system_health.log.5").exists())
        self.assertTrue(self.log.read_text().startswith("previous\n"))

    def test_logging_failure_is_reported(self):
        bins = self.root / "bin"
        bins.mkdir()
        tee = bins / "tee"
        tee.write_text("#!/bin/sh\ncat >/dev/null\nexit 1\n")
        tee.chmod(0o755)
        self.env["PATH"] = str(bins) + ":" + os.environ["PATH"]
        r = self.run_workflow()
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("log could not be written completely", r.stderr)

    def test_check_failure_is_preserved(self):
        (self.root / "scripts/cpu_check.sh").write_text("#!/bin/sh\nexit 7\n")
        r = self.run_workflow()
        self.assertEqual(r.returncode, 7, (r.stdout, r.stderr))
        self.assertNotIn("Monitoring workflow completed successfully.", r.stdout)


if __name__ == "__main__":
    unittest.main()
