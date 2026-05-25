# First Release Runbook

## Pending Enrollment

- Do not upload to App Store Connect until Apple Developer Program enrollment is complete.
- Use the verified GitHub Pages links for App Store metadata.
- Use Apple's Standard EULA for v1. The public Terms page is a support/reference page, not a custom App Store Connect EULA.
- Keep v1 scope frozen: Today, Dials, History, reminders, optional Apple Health export.

## After Enrollment Completes

1. Sign in to Apple Developer and App Store Connect as Account Holder.
2. Accept outstanding agreements in App Store Connect.
3. Confirm explicit bundle ID `com.drgprfct.RepRing` is visible with HealthKit enabled. Xcode automatic development provisioning has already succeeded for this bundle ID and team `52ZF3NP5J2`.
4. If unavailable in App Store Connect, use `com.danielwenzel.RepRing` and update the project plus docs.
5. Create App Store Connect app record:
   - Platform: iOS
   - Name: RepRing
   - Bundle ID: `com.drgprfct.RepRing`
   - SKU: `repring-ios`
   - Price: Free
   - Category: Health & Fitness
6. Confirm Xcode signing uses the completed Apple Developer Team.
7. During Archive upload, confirm Xcode Organizer can create or use App Store distribution signing.

## Local Release Gate

```sh
make preflight
make release-check
```

## Manual Xcode Upload

1. Open `RepRing.xcodeproj`.
2. Select Any iOS Device.
3. Product → Archive.
4. Distribute App → App Store Connect.
5. Upload.
6. Wait for App Store Connect processing email.

Status: build `1.3 (1)` was archived and uploaded from Xcode command-line tooling on 2026-05-25. App Store Connect reported: uploaded package is processing.

Status: build `1.3 (2)` was archived and uploaded from Xcode command-line tooling on 2026-05-25 using the explicit App Store provisioning profile `RepRing App Store`. App Store Connect reported: uploaded package is processing. Prefer build `1.3 (2)` if both builds become available.

Important: Xcode's upload logs observed the current App Store Connect app version record as `1.0`. Before App Review, update the App Store Connect version record to `1.3` so it matches the submitted binary version, unless you deliberately decide to release a `1.0` binary instead.

## TestFlight Smoke

- Wait until build `1.3 (2)` finishes processing in App Store Connect.
- Add yourself as an internal tester.
- Install build `1.3 (2)` from TestFlight on a physical iPhone.
- Fresh install.
- Deny notifications.
- Allow notifications and save multiple reminders.
- Deny HealthKit.
- Allow HealthKit on a physical iPhone.
- Export Today.
- Enable auto-export and log another set.
- Reset after Health export.
- Check light, dark, and automatic appearance.

## Submit For Review

- Select processed build.
- Confirm privacy answers match the binary.
- Use `docs/APP_STORE_METADATA.md` for copy and review notes.
- Answer export compliance as no custom/proprietary encryption if no encryption feature is added.
- Use phased release unless there is a deliberate reason not to.
