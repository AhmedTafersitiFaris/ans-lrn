# Test observations: LRN-CELSIUS-FAHRENHEIT-0001 v0.1.0

Date: 2026-10-06

Status: testing only. These observations are not human validation, operational approval, or runtime authorization.

The public conversion was executed directly for this architecture test. The repository currently has no LRN execution/runtime mechanism, so these observations do not demonstrate ANS runtime execution.

| Case | Input | Expected | Observed | Result |
| --- | --- | --- | --- | --- |
| Zero | `temperature_celsius: 0` | `temperature_fahrenheit: 32` | `32` | PASS |
| Boiling point | `temperature_celsius: 100` | `temperature_fahrenheit: 212` | `212` | PASS |
| Equal-scale point | `temperature_celsius: -40` | `temperature_fahrenheit: -40` | `-40` | PASS |
| Body temperature | `temperature_celsius: 37` | `temperature_fahrenheit: 98.6` | `98.6` | PASS |
| Decimal | `temperature_celsius: 36.6` | `temperature_fahrenheit: 97.88` | `97.88` | PASS |
| Negative | `temperature_celsius: -17.5` | `temperature_fahrenheit: 0.5` | `0.5` | PASS |
| String | string value | rejection | rejected | PASS |
| Null | null value | rejection | rejected | PASS |
| Missing | missing field | rejection | rejected | PASS |
| Malformed object | unexpected field | rejection | rejected | PASS |

Positive evidence: six numeric conversions produced the expected values.

Negative evidence: four invalid inputs were rejected. No counterexample was observed within this limited direct test set.

This record is prepared for independent human review. It does not create a validation event.
