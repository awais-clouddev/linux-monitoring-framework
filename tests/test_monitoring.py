import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MonitoringTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.bin = Path(self.temp.name)
        self.env = dict(
            os.environ, PATH=str(self.bin) + ":" + os.environ["PATH"],
            CPU_THRESHOLD="80", RAM_THRESHOLD="80", DISK_THRESHOLD="80"
        )
        for key in ("MONITOR_CPU", "MONITOR_RAM", "MONITOR_DISK"):
            self.env.pop(key, None)
        self.mock("ping", "exit 0")
        self.mock("ps", "echo systemd")
        self.mock("systemctl", "exit 0")
        self.mock("bc", "echo 'ERROR: bc must not be called' >&2; exit 99")
        self.metrics(80)

    def mock(self, name, body):
        p = self.bin / name
        p.write_text("#!/bin/sh\n" + body + "\n")
        p.chmod(0o755)

    def metrics(self, value):
        self.mock("top", f"echo '%Cpu(s): {100-value} id, 0 us'")
        self.mock("free", f"echo 'Mem: 100 {value} 0 0 0 0'")
        self.mock("df",
                  f"printf 'Filesystem Blocks Used Available Capacity Mounted\\n"
                  f"root 100 {value} 0 {value}%% /\\n'")

    def run_script(self, name, **settings):
        return subprocess.run(
            ["bash", str(ROOT / "scripts" / name)],
            env=dict(self.env, **settings),
            capture_output=True, text=True, timeout=15
        )

    def test_threshold_boundaries_without_calculator(self):
        for value in (79, 80, 81):
            self.metrics(value)
            for metric in ("cpu", "ram", "disk"):
                with self.subTest(value=value, metric=metric):
                    r = self.run_script(f"{metric}_check.sh")
                    self.assertEqual(r.returncode, 0, r.stderr)
                    self.assertEqual("Warning" in r.stdout, value >= 80)
                    self.assertNotIn("bc must not", r.stderr)
            r = self.run_script("alert_check.sh")
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertEqual(r.stdout.count("WARNING:"), 3 if value >= 80 else 0)
            self.assertNotIn("bc must not", r.stderr)

    def test_threshold_validation(self):
        for metric in ("CPU", "RAM", "DISK"):
            for value in ("-1", "100.1", "101", "abc", "NaN", "1e2",
                          "0", "80.5", "100"):
                valid = value in ("0", "80.5", "100")
                for name in (f"{metric.lower()}_check.sh", "alert_check.sh"):
                    with self.subTest(metric=metric, value=value, script=name):
                        r = self.run_script(name, **{metric+"_THRESHOLD": value})
                        self.assertEqual(r.returncode == 0, valid, r.stderr)

    def test_missing_metrics_fail(self):
        for metric, command in (("cpu", "top"), ("ram", "free"), ("disk", "df")):
            with self.subTest(metric=metric):
                self.metrics(80)
                self.mock(command, "echo unavailable")
                r = self.run_script(f"{metric}_check.sh")
                self.assertNotEqual(r.returncode, 0, r.stdout)
                r = self.run_script("alert_check.sh")
                self.assertNotEqual(r.returncode, 0, r.stdout)

    def test_invalid_latest_cpu_sample_fails(self):
        self.mock("top",
                  "printf '%%Cpu(s): 90 id, 10 us\\n"
                  "%%Cpu(s): missing idle\\n'")
        r = self.run_script("cpu_check.sh")
        self.assertNotEqual(r.returncode, 0, r.stdout)


    def test_dashboard_reuses_service_and_network_samples(self):
        repo = self.bin / "repo"
        (repo / "scripts").mkdir(parents=True)
        (repo / "dashboard").mkdir()
        for name in ("alert_check.sh", "update_dashboard.sh"):
            target = repo / "scripts" / name
            target.write_text((ROOT / "scripts" / name).read_text())
            target.chmod(0o755)

        for failed in (False, True):
            calls = self.bin / "calls"
            calls.write_text("")
            code = int(failed)
            self.mock("ping", f'echo network >> "{calls}"; exit {code}')
            self.mock("systemctl", f'echo service >> "{calls}"; exit {code}')
            r = subprocess.run(
                ["bash", str(repo / "scripts/update_dashboard.sh")],
                env=self.env, capture_output=True, text=True, timeout=15
            )
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertEqual(calls.read_text().splitlines(), ["network", "service"])
            status = (repo / "dashboard/status.txt").read_text()
            self.assertEqual("Network: Warning" in status, failed)
            self.assertEqual("nginx: Warning" in status, failed)
            self.assertEqual("CRITICAL: Network Down" in status, failed)
            self.assertEqual("CRITICAL: nginx Stopped" in status, failed)


    def test_malformed_ram_fields_fail(self):
        repo = self.bin / "ram-repo"
        (repo / "scripts").mkdir(parents=True)
        (repo / "dashboard").mkdir()
        for name in ("alert_check.sh", "update_dashboard.sh"):
            target = repo / "scripts" / name
            target.write_text((ROOT / "scripts" / name).read_text())
            target.chmod(0o755)

        status = repo / "dashboard/status.txt"
        for sample in (
            "Mem: 100 invalid 0 0 0 0",
            "Mem: invalid 20 0 0 0 0",
            "Mem: 0 0 0 0 0 0",
            "Mem: 100 101 0 0 0 0",
            "Mem: 100 -1 0 0 0 0",
            "Mem: 100",
        ):
            with self.subTest(sample=sample):
                self.mock("free", f"echo '{sample}'")
                for name in ("ram_check.sh", "alert_check.sh"):
                    r = self.run_script(name)
                    self.assertNotEqual(r.returncode, 0, r.stdout)
                    self.assertIn("Invalid RAM", r.stderr)
                status.write_text("previous status")
                r = subprocess.run(
                    ["bash", str(repo / "scripts/update_dashboard.sh")],
                    env=self.env, capture_output=True, text=True, timeout=15
                )
                self.assertNotEqual(r.returncode, 0, r.stdout)
                self.assertEqual(status.read_text(), "previous status")


if __name__ == "__main__":
    unittest.main()
