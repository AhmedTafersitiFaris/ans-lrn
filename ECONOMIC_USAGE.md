# Economic Usage

An LRN usage event is a privacy-minimized record that a consumer invoked, executed, retrieved, or received output from a specific LRN version. It is a metering input, not proof of validity, authority, successful outcome, or financial transaction.

Usage events use `schemas/usage-event.schema.json` and contain `usage_id`, `lrn_id`, `lrn_version`, `consumer_id`, `consumer_type`, `timestamp`, `usage_type`, `quantity`, `environment`, `success`, and optional `metadata`.

Use pseudonymous or internal consumer identifiers where possible. Do not store unnecessary personal data, prompts, outputs, credentials, or sensitive operational details in metadata. Retention and access are future platform policy.

An economic event is a conceptual accounting record, not payment. Its types are `usage`, `charge`, `refund`, `creator_revenue`, `platform_fee`, `validation_compensation`, `audit_compensation`, and `adjustment`. Compensation records reference submitted review/audit work, never approval.
