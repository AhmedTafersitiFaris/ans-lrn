# Architecture

```text
ANS runtime ← uses (under granted authority) ← active LRN
                                          ↑
creator → proposed LRN → independent validation → audit / counter-audit
                                          ↓
                       evidence, limits, monitoring, revalidation
                                          ↓
                            correction | suspension | retirement
```

ISA surrounds the lifecycle: it enforces integrity, traceability, separation of roles, and controlled execution. Repository records are append-oriented; operational use is always bounded by external authority and current status.

The operational trace is `input → elaboration → testing → human validation → state transition → operational use → monitoring → revalidation`. PCC context maps `input → candidate interpretation → semantic reduction → constrained output → testing → evidence` using `x_{t+1} = Π_M(B(x_t))`; it is not a truth score or validation shortcut.
