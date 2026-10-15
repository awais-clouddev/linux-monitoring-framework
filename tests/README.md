# Regression Tests

Run from the repository root:

    python3 -m unittest discover -s tests -v
    node tests/test_dashboard.js

Requirements: Python 3 and Node.js 18+.
Node.js is only needed for JavaScript tests, not dashboard hosting.

Python tests cover threshold boundaries and validation, missing metrics,
invalid latest CPU samples, shared service/network snapshots, log retention,
logger failures and workflow failure exit codes.

JavaScript tests cover successful responses, HTTP errors, network failures,
timeouts and empty responses using simulated browser APIs.
They do not verify browser layout.

Earlier lock, temporary-file and service-manager checks were performed
interactively. Actual WSL Cron execution and HTTP data serving were
verified separately.

Tests use disposable fixtures and do not change host services or create
AWS resources.
