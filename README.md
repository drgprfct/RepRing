# RepRing

RepRing is a small SwiftUI iOS app for tracking daily crunches and push-ups.

## Features

- Compact Today dashboard designed to keep the core flow on one screen.
- Main copy: **Count your Reps. Day after day.**
- Daily goal progress now sits below the hero image instead of covering the artwork.
- Crunches and Push-ups sit side by side with one-tap set logging and undo.
- Custom circular dials for each exercise:
  - standard set size
  - daily goal
- Seven-day local history stored on device with `UserDefaults`.
- Multiple daily reminders using `UserNotifications`, stored and scheduled on-device.
- Reminder counters now show the scheduled reminder count on both Today and Dials.
- Light, Dark, and Automatic appearance modes in Dials.
- Apple Health connector lives at the bottom of the **Dials** screen.
- Optional manual export plus **Auto-export to Apple Health**.
- New gender-neutral app icon and exercise illustrations with a clearer crunch pose.

## Version 1.3 update

This build focuses on visual clarity, reminder reliability, and appearance control:

- Replaced the hero, app icon, crunch badge, push-up badge, and goal artwork with gender-neutral illustrations.
- Moved the Daily goal card below the hero image so the artwork is not obscured.
- Added a Dials **Appearance** card with Automatic, Light, and Dark modes.
- Reworked the reminder scheduler so it waits for all local notification requests, then verifies the pending reminder count.
- The Today screen and Dials screen now share the same `NotificationManager`, so the reminder counter stays in sync.
- The Dials reminder card reports how many reminders are scheduled, and warns if iOS only accepted part of the schedule.

## Open the project

1. Open `RepRing.xcodeproj` in Xcode.
2. Select the `RepRing` target.
3. In **Signing & Capabilities**, choose your Team and set a unique bundle identifier.
4. Make sure **HealthKit** is enabled. The entitlement file is already included, but Xcode may need your team selected before signing works.
5. Build and run on an iPhone. HealthKit behavior is best tested on a physical device.

## Continue in Codex

This workspace is set up for Codex continuation under `/Users/daniel/.openclaw/workspace/iOS/RepRing`.

- Run `make doctor` to verify the local Xcode/project assumptions.
- Run `make preflight` before normal commits.
- Run `make release-check` before treating a build as an App Store candidate.
- Read `docs/PROJECT_STATUS.md` and `docs/APP_STORE_RELEASE_CHECKLIST.md` before release work.

The current App Store release blocker is Apple Developer enrollment/signing, not local build identity. The planned production bundle id is `com.drgprfct.RepRing`.

## Reminders

The Dials screen supports several reminder times per day. Toggle reminders on, add as many nudge times as you want, then tap **Save reminders**. RepRing schedules each enabled row as a repeating local notification.

The scheduler now removes old RepRing reminder requests, adds the current enabled reminders, waits for every `UNUserNotificationCenter.add` callback, then refreshes the pending request count. This is what drives the reminder counter on Today and Dials.

Existing installs with the old single-reminder setting are migrated automatically: the old reminder time becomes the first reminder in the new list.

## Appearance

Use Dials → Appearance to choose:

- **Automatic** — follows the iOS system appearance.
- **Light** — keeps RepRing in light mode.
- **Dark** — keeps RepRing in dark mode.

The app backdrop and glass cards adapt to the selected color scheme.

## Apple Health export

Apple Health does not provide a dedicated public quantity type for "push-up reps" or "crunch reps" as first-class samples. RepRing keeps exact rep counts locally, then exports the day as a `traditionalStrengthTraining` workout with custom RepRing metadata:

- `RepRingCrunches`
- `RepRingPushUps`
- `RepRingTotalReps`
- `RepRingDayKey`

Manual export is still available with **Export Today**.

When **Auto-export to Apple Health** is on, RepRing exports from inside the app whenever today's rep total changes. It searches for the current day's existing RepRing workout using RepRing metadata, deletes the previous RepRing workout for that date if one exists, and saves a fresh workout. The goal is one updated RepRing workout per day rather than a pile of duplicates.

A practical iOS note: Auto-export runs while the app is active and recording changes. It is not a midnight background daemon.

## Customize

- Change default values in `Models.swift` inside `RepSettings`.
- Adjust dial ranges in `SettingsView.swift`.
- Edit reminder copy in `NotificationManager.swift` and default reminder rows in `Models.swift`.
- Adjust the compact dashboard layout in `DashboardView.swift`.
- Swap images in `Assets.xcassets`.

## Files

- `DashboardView.swift` — compact Today view, hero image, Daily goal card, side-by-side exercise cards, and auto-export trigger.
- `SettingsView.swift` — dials, multiple reminder setup, appearance selector, and Apple Health connector.
- `DialView.swift` — custom circular dial and progress ring components.
- `Models.swift` — exercise models, daily logs, settings, reminder times, appearance mode, and Apple Health auto-export state.
- `RepStore.swift` — on-device persistence and auto-export bookkeeping.
- `NotificationManager.swift` — local multi-reminder scheduling and pending request verification.
- `HealthKitManager.swift` — Apple Health authorization, one-workout-per-day replacement export, and auto-export support.
