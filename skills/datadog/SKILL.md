---
name: datadog
description: "Use when working with Datadog APIs, monitors, dashboards, or any Datadog integration. Provides authentication setup guidance."
---

# Datadog

When interacting with Datadog APIs or tools, use the `DD_API_KEY` and `DD_APPLICATION_KEY` environment variables from the local `.env` file in the workspace root.

Load these values from `.env` before making any Datadog API calls. Do not hardcode or expose these keys.

## Monitor authoring: sparse count metrics and missing data

Never wrap a whole monitor query in `default_zero()` around a sparse `.as_count()` metric. It makes Datadog treat the query as interpolated, so an empty evaluation window "shows last known status" instead of evaluating as zero: a triggered failure monitor wedges in Alert forever (no recovery, no fresh page on the next burst), and an absence monitor (`< 1`) holds OK forever and can never fire. Bare `.as_count()` with `on_missing_data = "default"` evaluates empty windows as zero — that is the correct pattern.

`default_zero()` is only legitimate inside cross-series arithmetic (ratio numerators, subtraction guards) to align a sparse series against a steady one. Never add two sparse `.as_count()` series either — use one series with an OR filter or a combined logs metric. For sparse gauges, use `on_missing_data = "resolve"` when absence should clear the alert.

Always define what makes a monitor recover (or fire from quiet steady state), not just what makes it trigger. In the Auctor repo, `terraform/datadog/AGENTS.md` and the conftest rule `terraform/datadog/policy/no_default_zero_sparse_count.rego` enforce this.

Reference: <https://docs.datadoghq.com/monitors/guide/as-count-in-monitor-evaluations/>
