# Impact

## Classification

<!-- required: T1. Machine-read lines: keep keys and values in English, one per line. -->

Change class: <!-- additive | column | model-wide -->
Breaking contract change: <!-- yes | no -->
New columns: <!-- yes | no -->
New PII: <!-- yes | no -->
Backfill: <!-- yes | no -->
Critical consumer: <!-- yes | no -->
Tier: <!-- T1 | T2 | T3 (at least the derived tier) -->

## Tier Rationale

<!-- required: T1. Which criterion set the tier. T2: column change, breaking contract change, new PII or backfill. T3: model-wide change or critical consumer. -->

## Upstream

<!-- required: T2. Below T2 write `N/A: <reason>`. -->

### Input Contracts

<!-- Sources the change relies on and their contracts or owners. -->

### Source Profiling

<!-- Numbers from queries: key uniqueness, null rates, orphans in joins, value ranges, arrival delay. -->

## Downstream

<!-- required: T1 -->

### Column-level Lineage

<!-- Columns touched by this change and where they flow. -->

### Named Consumers

| Consumer | Type | Owner | Columns used |
|----------|------|-------|--------------|
| <!-- name --> | <!-- dashboard / model / export / team --> | <!-- owner --> | <!-- columns --> |
