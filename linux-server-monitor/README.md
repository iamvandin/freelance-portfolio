## Automated Monitoring

The monitoring script can be scheduled using Linux Cron.

Example:

```cron
*/5 * * * * /path/to/monitor.sh >> /path/to/logs/monitoring.log 2>&1

## Alerting

The monitoring tool checks configured thresholds for:

- CPU usage
- Memory usage
- Disk usage

When a threshold is exceeded, an alert is written to:

```text
logs/alerts.log
