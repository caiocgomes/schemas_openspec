# Design

## Model Interface

<!-- required: T1. One row per model created or changed; output schema from the contract. The red gate creates stubs with exactly this schema. -->

| Model | File | Columns (name type nullable) |
|-------|------|------------------------------|
| <!-- model --> | <!-- path --> | <!-- order_id INT64 not null, ... --> |

## Materialization

<!-- required: T1. Machine-read line in English. -->

Materialization: <!-- table | view | incremental | ephemeral | streaming -->

<!-- Layer (staging / intermediate / mart), partitioning, clustering. -->

## Incremental Strategy and Late Data

<!-- required: T1 when incremental; otherwise `N/A: <reason>`. Unique key, merge or insert-overwrite, lookback window, late-arriving rows. -->

## Field Mapping

<!-- required: T1. One row per new or changed target field. Kind: mapped | audit | system-generated. -->

| Target field | Source fields | Transformation | Kind |
|--------------|---------------|----------------|------|
| <!-- field --> | <!-- sources --> | <!-- logic --> | <!-- mapped / audit / system-generated --> |

## Idempotency and Reprocessing

<!-- required: T2. What happens when a run repeats or a partition is reprocessed; how duplicates are prevented. -->

## Orchestration

<!-- required when schedule, dependencies or retries change; otherwise `N/A: <reason>`. -->

## Cost Estimate

<!-- required: T2, and always when Backfill: yes. Bytes or compute per run and for the backfill, and how it was estimated. -->

## Decisions

<!-- Key choices with alternatives considered. -->

## Risks / Trade-offs

<!-- [Risk] -> Mitigation -->

## Open Questions

<!-- Unresolved decisions. Those that would change what gets built must be resolved with the user before tasks. -->
