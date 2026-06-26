---
name: datadog
description: "Use when working with Datadog APIs, monitors, dashboards, or any Datadog integration. Provides authentication setup guidance."
---

# Datadog

When interacting with Datadog APIs or tools, use the `DD_API_KEY` and `DD_APPLICATION_KEY` environment variables from the local `.env` file in the workspace root.

Load these values from `.env` before making any Datadog API calls. Do not hardcode or expose these keys.
