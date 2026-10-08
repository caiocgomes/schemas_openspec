# Evidence

## Red Gate Replay

- **Red commit**: <!-- SHA from `git log --format=%h --grep='^test(red)' -n 1` -->
- **How replayed**: <!-- temporary worktree at the red SHA | clean checkout | not possible (reason; cite task 0.2 excerpts, weaker evidence) -->
- **Result**: <!-- each logic test failed by assertion against the stubs: yes / no (list exceptions) -->

## Test Freeze

- **Command**: <!-- git diff <red-sha>..HEAD --stat -- <test and fixture files> -->
- **Changes found**: <!-- none | list, each matched to an entry in validation.md Test Changes After Red -->

## Mutation Checks

| Model or clause | Mutation applied (model or fixture) | Test that caught it | Reverted |
|-----------------|-------------------------------------|---------------------|----------|
| <!-- model --> | <!-- break --> | <!-- test --> | <!-- yes --> |

## Build and Tests

- **Logic tests**: <!-- command; passed / failed counts -->
- **Build with contracts**: <!-- command; result -->
- **Data tests**: <!-- command; passed / failed / warned counts -->

## Reconciliation and Diff

<!-- From T2: observed vs threshold; whether the diff stayed inside impact.md. Below T2: `N/A: <reason>`. -->

## TDD Path

TDD path: <!-- superpowers | embedded -->

## Decision

DECISION: <!-- PASS | FAIL -->

<!-- When FAIL: the blocking items. -->
