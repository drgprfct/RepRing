# Project Status

Last updated: 2026-05-19

## Snapshot

- App: RepRing
- Platform: iPhone, iOS 17+
- Xcode on this machine: 26.4.1
- Simulator profile: iPhone 17, iOS 26.4
- Current version in project: `MARKETING_VERSION = 1.3`, `CURRENT_PROJECT_VERSION = 1`
- Current bundle id: `com.example.RepRing`
- Primary local gate: `make preflight`

## What Works

- Source imported from `/Users/daniel/Downloads/RepRing`.
- Simulator Debug build succeeds on Xcode 26.4.1.
- XcodeBuildMCP local defaults are configured for this machine.
- A unit test target exists for core model/store behavior.
- App has HealthKit entitlement and HealthKit usage descriptions.
- App has no third-party SDKs and no apparent network layer in the imported source.

## Release Blockers

- Replace `com.example.RepRing` with the real App Store bundle id.
- Confirm Apple Developer Team and signing/provisioning for App Store distribution.
- Add a real Privacy Policy URL in App Store Connect and make it reachable from inside the app.
- Prepare App Store product metadata: name, subtitle, description, keywords, support URL, screenshots, age rating, review notes.
- Run physical-device HealthKit QA. Simulator builds are not enough for HealthKit review confidence.

## Known Technical Debt

- `NotificationManager.swift` still emits one Xcode 26 warning recommending the async `UNUserNotificationCenter.notificationSettings()` API.
- `HealthKitManager.swift` uses the iOS 17-deprecated `HKWorkout` initializer; migrate to `HKWorkoutBuilder`.
- There are unit tests, but no UI test/screenshot automation yet.
- No automated archive/upload lane exists yet; keep App Store upload manual until signing and App Store Connect access are confirmed.

## Next Best Slices

1. Set production bundle id and signing, then rerun `make release-check`.
2. Add in-app Privacy Policy access once the URL exists.
3. Remove the Xcode 26 warning debt.
4. Add a small UI smoke test or screenshot checklist for Today, Dials, History, reminders, and HealthKit states.
5. Create App Store Connect draft metadata and TestFlight internal testing plan.
