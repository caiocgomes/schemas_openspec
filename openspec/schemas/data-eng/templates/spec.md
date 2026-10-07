# Contract Delta

## ADDED Requirements

<!-- New dataset or metric: full contract here. Existing one: only the clauses this change touches, using MODIFIED (whole block copied from openspec/specs/) or REMOVED (with Reason and Migration). -->

### Requirement: Grain and primary key
<!-- The table SHALL contain one row per <grain>. Contract: <contractId>@<version> or path to the enforcement artifact -->

#### Scenario: <!-- unique scenario name, e.g. "Primary key is unique" -->
- **WHEN** <!-- the model is built on <data or fixture> -->
- **THEN** <!-- each (<key columns>) appears exactly once -->

### Requirement: Columns
<!-- Name, logical type, required or nullable for each column touched. -->

#### Scenario: <!-- scenario name -->
- **WHEN** <!-- condition -->
- **THEN** <!-- assertable outcome: types, null rates, accepted values -->

### Requirement: PII classification and retention
<!-- For every new or changed column: classification (none | personal | sensitive) and retention. Never omit for a new column. -->

#### Scenario: <!-- scenario name -->
- **WHEN** <!-- condition -->
- **THEN** <!-- assertable outcome: masking, policy tag, retention -->

### Requirement: Data quality
<!-- Quality rules with severity (error | warn). -->

#### Scenario: <!-- scenario name -->
- **WHEN** <!-- condition -->
- **THEN** <!-- assertable outcome -->

### Requirement: Freshness SLA
<!-- required from T2: latency, refresh frequency, time to detect. -->

#### Scenario: <!-- scenario name -->
- **WHEN** <!-- condition -->
- **THEN** <!-- assertable freshness outcome -->

### Requirement: Ownership
<!-- Owner and support channel. -->

#### Scenario: <!-- scenario name -->
- **WHEN** <!-- the contract is read -->
- **THEN** <!-- owner and channel are declared in the executable contract -->
