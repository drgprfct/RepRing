# First Release Runbook

## Pending Enrollment

- Do not upload to App Store Connect until Apple Developer Program enrollment is complete.
- Use the verified GitHub Pages links for App Store metadata.
- Keep v1 scope frozen: Today, Dials, History, reminders, optional Apple Health export.

## After Enrollment Completes

1. Sign in to Apple Developer and App Store Connect as Account Holder.
2. Accept outstanding agreements in App Store Connect.
3. Create explicit bundle ID `com.drgprfct.RepRing` with HealthKit enabled.
4. If unavailable, use `com.danielwenzel.RepRing` and update the project plus docs.
5. Create App Store Connect app record:
   - Platform: iOS
   - Name: RepRing
   - Bundle ID: `com.drgprfct.RepRing`
   - SKU: `repring-ios`
   - Price: Free
   - Category: Health & Fitness
6. Confirm Xcode signing uses the completed Apple Developer Team.

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

## TestFlight Smoke

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
