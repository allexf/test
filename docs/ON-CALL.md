# Plan for Failure

## Backups
- If database exists, we do regular Backups.
- Frequency: daily full backup, hourly incremental backup (if DB supports).
- Retention: keep last 7 full backups, 30 days incremental backups.
- Restore procedure:
    - Find the needed backup.
    - Restore to test environment first.
    - Check data consistency.
    - Promote to production if all correct.

---

## Disaster Recovery (DR)
- Origin failover: CloudFront or Front Door can switch traffic to secondary origin if main origin fails.
- State considerations:
    - For stateless services like small API, failover is simple.
    - For stateful services, need to consider sessions or in-flight data.

---

## On-Call Runbook

### First-15-minutes checklist:
- Check service health (ALB / endpoints / logs).
- Check monitoring alerts (CloudWatch / Application Insights).
- Notify team using communication channel (Slack, Teams, email).
- Try quick mitigation (restart container, switch origin).

### Comms template:
- Incident detected at [time]. Service [name] impacted. Current status: [status]. Actions taken: [actions]. ETA fix: [estimate].

### Rollback steps:
- Revert deploy if needed.
- Restore DB backup.
- Switch traffic back to last known working origin.

### Postmortem template:
- Incident summary
- Timeline
- Root cause
- Mitigation actions
- Lessons learned

