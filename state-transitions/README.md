# State transitions

Every lifecycle movement is an immutable JSON event conforming to `schemas/state-transition.schema.json`. Current directory/status is only a projection; history is reconstructed from these events.
