# Tasks

## 0. Red gate

- [ ] 0.1 Write every logic test with its own fixture, the data tests and the executable contract, plus a stub for every model in Model Interface (exact output schema, zero rows, no logic)
- [ ] 0.2 Run the logic tests; confirm each FAILS BY ASSERTION against the stubs; record each failure excerpt in the ledger; confirm only data tests marked `Vacuous on empty: yes` pass on the stubs
- [ ] 0.3 Commit tests, fixtures, contract and stubs only as `test(red): <!-- change-name -->`; write the SHA in the ledger
- [ ] 0.4 STOP: show the user the failing tests and wait for explicit approval before writing model logic

## 1. <!-- model name -->

- [ ] 1.1 Implement <!-- model, one file -->; verified when its logic tests pass [ledger: <!-- V1, V2 -->]
- [ ] 1.2 Unit-test and implement <!-- macro / UDF / function --> one test at a time (inner loop); verified when its unit tests pass
- [ ] 1.3 Build in dev with contract enforced; verified when data tests pass [ledger: <!-- V3 -->]
- [ ] 1.4 Refactor <!-- model -->; everything stays green

## 2. Integration evidence

- [ ] 2.1 Run reconciliation; verified when observed is within threshold and recorded [ledger: <!-- V4 -->]
- [ ] 2.2 Run diff against production; verified when no effect appears beyond impact.md [ledger: <!-- V5 -->]

## 3. Verification

- [ ] 3.1 Mutation check for <!-- model -->: apply "Breaks if" mutation, see <!-- test --> fail, revert
- [ ] 3.2 Fresh full run: logic tests, build with contracts, data tests; all green

## 4. Rollout

- [ ] 4.1 <!-- rollout step from rollout.md; how it is verified -->
- [ ] 4.2 <!-- production step (backfill, cutover) --> with explicit user confirmation; <!-- how it is verified -->

## Workflow follow-up

- Produce evidence.md (`openspec instructions evidence --change <!-- change-name -->`) and reach `DECISION: PASS`
- Archive the change after the rollout is confirmed in production
