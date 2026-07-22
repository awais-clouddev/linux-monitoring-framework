# Reports Documentation

## Overview

The monitoring framework automatically generates a system health report after each complete monitoring execution.

The report file is overwritten with the latest monitoring results. When the framework is scheduled through Cron, the report can be generated at any required interval, including daily.

## Report Contents

- Generation time
- CPU usage
- RAM usage
- Disk usage
- Network status
- Nginx status
- Active alerts

The generated report helps administrators quickly verify the latest overall system health.

For a sample report, see the **Daily Health Report** section in the main README.

