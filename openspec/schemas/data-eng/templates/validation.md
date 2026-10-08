# Validation

## Stack and Commands

- **Stack**: <!-- dbt | Dataform | Spark -->
- **Logic tests**: <!-- exact command -->
- **Build with contract**: <!-- exact command -->
- **Data tests**: <!-- exact command -->
- **Mutation tool**: <!-- tool | manual -->

## Ledger

<!-- One row per (scenario, evidence). Every scenario about transformation output has at least one logic-test; every changed model has a GRAIN logic test (fixture with a duplicated key or one-to-many join, one output row per grain key). One fixture per test, never shared. Breaks if: a model mutation (drop join condition, LEFT instead of INNER, remove filter, date window off by one, COALESCE removed, wrong aggregate) or a fixture mutation (duplicate key, null in required column, value outside accepted set, orphan FK, late row). Vacuous on empty: yes for uniqueness / not-null / accepted-values / relationship tests, which pass on an empty table; their scenario needs a non-vacuous row too. State: planned -> red (only with red SHA and observed failure) -> green (only with observed result). Post-build rows go planned -> green. -->

| ID | Capability | Scenario | Evidence type | Check | Fixture | Breaks if | Vacuous on empty | Threshold | Red (SHA: failure) | Observed | State |
|----|------------|----------|---------------|-------|---------|-----------|------------------|-----------|--------------------|----------|-------|
| V1 | <!-- capability --> | <!-- scenario name from spec --> | logic-test | <!-- test file and name --> | <!-- fixture path --> | <!-- break --> | no | N/A | | | planned |
| V2 | <!-- capability --> | <!-- grain scenario --> | logic-test | <!-- grain test --> | <!-- fixture with duplicated key --> | <!-- drop dedup / fan-out join --> | no | N/A | | | planned |
| V3 | <!-- capability --> | <!-- scenario --> | data-test | <!-- unique / not_null / ... --> | N/A | <!-- break --> | yes | N/A | | | planned |

## Reconciliation

<!-- required: T2. Source of truth, query, numeric threshold. -->

## Diff Plan

<!-- required: T2. What is compared (dev or shadow vs prod), at which level, and which result would contradict the impact classification. -->

## SLA Monitors

<!-- required: T2. Monitor, threshold, alert channel. -->

## Test Changes After Red

<!-- Append-only. Empty at planning. Each entry: date, test or fixture, what changed, why, which spec change justifies it, user OK. -->
