# Validation

## Stack and Commands

- **Stack**: <!-- dbt | Dataform | Spark -->
- **Logic tests**: <!-- exact command -->
- **Build with contract**: <!-- exact command -->
- **Data tests**: <!-- exact command -->

## Ledger

<!-- One row per (scenario, evidence). Every `#### Scenario:` in specs/ appears at least once. Evidence type: logic-test | data-test | contract | reconciliation | diff | monitor. State starts as red; Observed is filled during apply. Tasks reference IDs as [ledger: V1]. -->

| ID | Capability | Scenario | Evidence type | Check | Threshold | Observed | State |
|----|------------|----------|---------------|-------|-----------|----------|-------|
| V1 | <!-- capability --> | <!-- scenario name from spec --> | <!-- logic-test --> | <!-- test file and name, or query --> | <!-- threshold or N/A --> | | red |

## Reconciliation

<!-- required: T2. Source of truth, query, numeric threshold. -->

## Diff Plan

<!-- required: T2. What is compared (dev or shadow vs prod), at which level (rows, columns, profile), and which result would contradict the impact classification. -->

## SLA Monitors

<!-- required: T2. Monitor, threshold, alert channel. -->

## Evidence

<!-- Filled at the end of apply: exact commands and result summaries. Leave empty until then. -->
