# Bug

## Observed vs Expected

**Observed**: <!-- exact error message, wrong value, or wrong state -->

**Expected**: <!-- correct behavior -->

**Source of the expectation**: <!-- openspec/specs/<capability> requirement | documentation | API or data contract | unwritten user expectation -->

## Reproduction

1. <!-- minimal step -->
2. <!-- minimal step -->

- **Environment / version**: <!-- branch, commit, runtime, data snapshot -->
- **Input**: <!-- the minimal input that triggers the bug -->
- **Frequency**: <!-- always | intermittent (observed rate) -->

## Root Cause Hypothesis

<!-- Suspected cause, the evidence pointing to it, and how apply will confirm or refute it. It stays a hypothesis until apply records confirming evidence. -->

## Regression Test

- **Scenario**: <!-- scenario name used in the delta spec -->
- **Test name**: <!-- test_descriptive_name -->
- **Test file**: <!-- tests/... -->
- **Test type**: <!-- unit | integration | e2e -->
- **GIVEN**: <!-- state to arrange -->
- **WHEN**: <!-- action that triggers the bug -->
- **THEN**: <!-- the CORRECT outcome; fails on current code -->

State: red

**Evidence**: <!-- filled during apply: commands and result summaries for the regression test and the full suite -->

## Fix Scope

**Changes**: <!-- what the fix will change -->

**Does not change**: <!-- what stays as is -->

## Affected Capability

<!-- kebab-case capability name; existing in openspec/specs/ or new -->
