# shopfloor_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Session persistence & tests ✅

- The app saves a mock JWT and session on login using `shared_preferences` (see `lib/services/session_service.dart`).
- On startup the app restores the previous session (if found) and opens the dashboard instead of the login screen.
- Tests:
  - `test/session_service_test.dart` — unit tests for saving/loading/clearing the session.
  - `test/widget/session_widget_test.dart` — widget test that verifies the dashboard is shown when a saved session exists.

## Alerts (Supervisor view) ⚠️

- Alerts are simulated by `lib/services/alerts_service.dart` and persisted in Hive box `alerts` (model: `lib/models/alert_item.dart`).
- To view alerts, sign in as a user with role `supervisor` and open **Open Alerts (Supervisor)** from the Dashboard.
- Workflow: Alerts are Created (simulated) → Acknowledge → Clear. Acknowledge and Clear actions set audit fields (`acknowledgedBy`, `acknowledgedAt`, `clearedBy`, `clearedAt`).
- For testing: `test/widgets/alerts_screen_test.dart` includes a widget test for the UI behavior (note: may be flaky in certain local runners; see tests folder).

## Summary Reports 📊

- A lightweight reporting feature aggregates data across Hive boxes:
  - Downtime per machine (total downtime computed from `lib/models/downtime.dart`)
  - Checklist completion rates (per machine)
  - Alerts count by severity (INFO/WARN/CRITICAL)
- The `Reports` screen is available from the Dashboard via **Open Summary Reports** and displays the metrics and an **Export Downtime CSV** button that shows a CSV preview (demo export).
- Implementation:
  - `lib/services/reports_service.dart` — aggregation methods and CSV export helper.
  - `lib/screens/reports_screen.dart` — UI to present the summary and export CSV.
- Tests: `test/reports_service_test.dart` contains unit tests for aggregations.

---

**Demo tip:** To exercise Alerts during a demo, either run the app and wait for simulated alerts to appear (Supervisor view), or create alerts manually via tests (or by inserting into the Hive `alerts` box in debug mode).

