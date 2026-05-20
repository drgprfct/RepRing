# App Store Release Checklist

Verified against Apple developer docs on 2026-05-19.

## Current Hard Facts

- Since 2026-04-28, iOS/iPadOS App Store uploads must be built with the iOS/iPadOS 26 SDK or later.
- This machine has Xcode 26.4.1, so the local toolchain meets that SDK floor.
- The app now uses planned production bundle id `com.drgprfct.RepRing`.
- Apple Developer enrollment is still required before App Store Connect actions can complete.

## Before First App Store Connect Draft

- Use final bundle id `com.drgprfct.RepRing`, with `com.danielwenzel.RepRing` as fallback.
- Confirm Apple Developer Program access and Team ID.
- Create the explicit App ID with HealthKit enabled.
- Create or confirm the App Store Connect app record.
- Decide availability: iPhone only for first release unless there is a deliberate iPad/Mac plan.
- Prepare Support URL and Privacy Policy URL:
  - `https://drgprfct.github.io/RepRing/support.html`
  - `https://drgprfct.github.io/RepRing/privacy.html`
- Prepare Terms URL:
  - `https://drgprfct.github.io/RepRing/terms.html`
- Keep Apple Standard EULA for v1 unless a deliberate custom EULA decision is made in App Store Connect.

## Binary Readiness

- `make preflight` passes.
- `make release-check` passes.
- Release build uses production bundle id.
- Build number is higher than any previous App Store Connect upload.
- HealthKit entitlement is enabled only for the main app target.
- HealthKit usage descriptions are accurate and plain.
- No unexpected third-party SDKs are present.
- No debug-only UI, fake completion states, or placeholder metadata.
- Apple Developer enrollment is complete before upload.

## Product Page

- App name: RepRing, unless unavailable.
- Subtitle: 30 characters max.
- Description: explain local rep tracking, reminders, and optional Apple Health export without medical claims.
- Keywords: fitness, pushups, crunches, strength, habit, reps, reminders.
- Screenshots: Today, Dials, reminders, History, Apple Health connection state.
- App icon: verify the 1024px marketing icon has no transparency.
- Age rating: answer App Store Connect questionnaire from actual app behavior.
- Accessibility Nutrition Label: answer from actual tested support.

## Privacy

- App Privacy answers must match the actual submitted build.
- Current working assumption: no data collected, because imported source appears local-only and has no network/third-party SDK layer.
- Re-check this assumption if analytics, crash reporting, cloud sync, accounts, remote config, ads, or support forms are added.
- Privacy Policy must disclose local storage, local notifications, optional HealthKit read/write of workouts, data deletion/reset behavior, and absence/presence of third-party sharing.

## HealthKit Review Notes

Include concise App Review notes:

- HealthKit is optional.
- RepRing writes the user's daily crunch/push-up total as a `traditionalStrengthTraining` workout only after permission.
- The app stores exact rep counts locally on device.
- Auto-export updates one RepRing workout per day rather than creating duplicate workouts.
- The app does not use HealthKit data for advertising, marketing, or third-party sharing.

## TestFlight

- Upload one internal TestFlight build before App Review.
- Test fresh install.
- Test denied notifications.
- Test denied HealthKit.
- Test granted HealthKit on a physical iPhone.
- Test reset after HealthKit export.
- Test light/dark/automatic appearance.
- Test reminder save with multiple reminders.

## Submission

- Select the processed build in App Store Connect.
- Confirm metadata and privacy answers.
- Add review notes.
- Add for Review.
- Submit for Review.

## References

- [Apple: Submit your apps and games today](https://developer.apple.com/app-store/submitting/)
- [Apple: Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)
- [Apple: Submit an app](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app)
- [Apple: App privacy details](https://developer.apple.com/app-store/app-privacy-details/)
- [Apple: Third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/)
- [Apple: App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
