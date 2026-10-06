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

The operational trace is `input → internal governed processing → output → testing → human validation → state transition → operational use → monitoring → revalidation`.

ANS may use an internal proprietary semantic-bisection process within governed processing. This repository documents only public interfaces, architectural roles, and governance boundaries; it does not document internal implementation. That process does not grant authority to an LRN.
