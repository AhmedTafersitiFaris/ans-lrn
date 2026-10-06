# Validation events

Store one JSON event per independent human/operational validation decision. Events conform to `schemas/validation-event.schema.json`, are append-only, and do not replace older decisions. Structural validation checks format only; humans decide operational validity.
