# Checks

## Check Table

<!-- Each check must be proven able to fail: apply its mutation, see it fail, revert. State starts as red. Keep C1-C5 and add analysis-specific checks. -->

| ID | Check | Command | Mutation that breaks it | State |
|----|-------|---------|-------------------------|-------|
| C1 | Raw data unchanged (hash equals audited snapshot) | <!-- command --> | <!-- alter one raw row --> | red |
| C2 | Row counts preserved across joins | <!-- command --> | <!-- duplicate a join key --> | red |
| C3 | Fixed seed for every stochastic step | <!-- command --> | <!-- remove the seed --> | red |
| C4 | Clean rerun from raw reproduces reported numbers | <!-- command --> | <!-- change one processing step --> | red |
| C5 | Missing values not converted to zero | <!-- command --> | <!-- fillna(0) on a key variable --> | red |
