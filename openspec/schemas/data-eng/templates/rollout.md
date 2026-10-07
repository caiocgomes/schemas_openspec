# Rollout

## Strategy by Class

<!-- required: T1. additive: direct deploy after validation. column: new version or new column alongside the old one, deprecation date, consumer migration. model-wide: shadow run, reconciliation, cutover by view or alias swap, rollback window. -->

## Historical Values

<!-- required: T1 whenever New columns: yes. NEVER N/A for an incremental model that gains a column. Do historical rows keep NULL or get backfilled, and what will consumers see? -->

## Backfill Plan

<!-- required when Backfill: yes. Partitions or window, source of truth, write strategy, dry run, publication paused, cost ceiling, reconciliation thresholds that gate publication. -->

## Consumer Migration and Deprecation

<!-- required: T2. Per consumer: what changes, deadline, who confirms. -->

| Consumer | Change | Deadline | Confirmed by |
|----------|--------|----------|--------------|
| <!-- consumer --> | <!-- change --> | <!-- date --> | <!-- owner --> |

## Shadow Run and Cutover

<!-- required: T3. -->

## Rollback

<!-- required: T1. How to revert. From T3: tested before cutover, with the result recorded. -->

## Approvals

<!-- required: T2. -->

| Role | Person | Required | Granted |
|------|--------|----------|---------|
| Dataset owner | <!-- name --> | yes | <!-- yes / no --> |
| Downstream owner | <!-- name --> | yes | <!-- yes / no --> |

## Alerts and Runbook

<!-- required: T3. Alerts, on-call, first steps when the dataset is late or wrong. -->

## Retirement

<!-- required when a dataset is removed entirely: consumers migrated, drop date, retire_capabilities: true set in .openspec.yaml. Otherwise `N/A: <reason>`. -->
