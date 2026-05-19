# Changelog

All notable RepRing changes should be recorded here before a release candidate is cut.

## 1.3 - In Progress

- Imported RepRing into the Codex iOS workspace.
- Added a local SDLC baseline for App Store release work.
- Added a unit test target covering core model and persistence behavior.
- Fixed `RepStore` persistence isolation so injected `UserDefaults` are used for both reads and writes.
- Set planned production bundle identifiers for the app and test target.
- Added in-app Privacy Policy and Support links.
- Added GitHub Pages privacy/support pages and App Store metadata/runbook docs.
- Migrated notification settings checks to async APIs and Apple Health workout saving to `HKWorkoutBuilder`.

## 1.3 - Source Import Baseline

- Compact Today dashboard with crunch and push-up logging.
- Dials for set size, daily goals, appearance, reminders, and Apple Health export.
- Seven-day local history stored on device.
- Multiple local reminders using `UserNotifications`.
- Optional Apple Health export as one updated strength-training workout per day.
