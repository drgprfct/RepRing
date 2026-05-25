# Release Blockers

Last updated: 2026-05-25

## Blocked By Apple / App Store Connect

- Apple Developer Program enrollment and App Store Connect access should stay confirmed manually before review submission.
- App Store Connect build `1.3 (2)` was uploaded on 2026-05-25 and is processing.
- App Store Connect's app version record was observed as `1.0` in Xcode's upload logs. Align it with the binary version `1.3` before selecting the build for App Review.
- Internal TestFlight has not been run yet.
- App Review submission has not happened yet.

## Local Blockers Closed

- Production bundle ID has been changed to `com.drgprfct.RepRing`.
- Test target bundle ID has been changed to `com.drgprfct.RepRingTests`.
- Xcode automatic development provisioning succeeded for `com.drgprfct.RepRing`.
- The generated development profile includes team `52ZF3NP5J2` and HealthKit entitlement.
- Xcode archive and App Store Connect upload succeeded for `1.3 (1)`.
- Xcode archive and App Store Connect upload succeeded for `1.3 (2)` using the explicit App Store profile `RepRing App Store`.
- GitHub repo exists at `https://github.com/drgprfct/RepRing`.
- GitHub Pages privacy, support, and terms pages are live:
  - `https://drgprfct.github.io/RepRing/privacy.html`
  - `https://drgprfct.github.io/RepRing/support.html`
  - `https://drgprfct.github.io/RepRing/terms.html`
- In-app Privacy Policy and Support links exist in Dials.
- Notification API warning has been addressed.
- Deprecated direct `HKWorkout` initializer has been replaced with `HKWorkoutBuilder`.

## Remaining Manual Release Checks

- Wait for App Store Connect build `1.3 (2)` processing.
- Align the App Store Connect version record with build `1.3` before App Review.
- Add the build to internal TestFlight and install it on a physical iPhone.
- Run physical-device HealthKit QA.
- Capture final App Store screenshots from the submitted build.
