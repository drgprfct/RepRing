# Release Blockers

Last updated: 2026-05-25

## Blocked By Apple / App Store Connect

- Apple Developer Program enrollment and App Store Connect access still need to be confirmed manually.
- App Store Connect app record still needs to be created.
- App Store distribution signing/provisioning still needs to be confirmed during manual Xcode Archive upload.
- App Store upload/TestFlight has not happened yet.

## Local Blockers Closed

- Production bundle ID has been changed to `com.drgprfct.RepRing`.
- Test target bundle ID has been changed to `com.drgprfct.RepRingTests`.
- Xcode automatic development provisioning succeeded for `com.drgprfct.RepRing`.
- The generated development profile includes team `52ZF3NP5J2` and HealthKit entitlement.
- GitHub repo exists at `https://github.com/drgprfct/RepRing`.
- GitHub Pages privacy, support, and terms pages are live:
  - `https://drgprfct.github.io/RepRing/privacy.html`
  - `https://drgprfct.github.io/RepRing/support.html`
  - `https://drgprfct.github.io/RepRing/terms.html`
- In-app Privacy Policy and Support links exist in Dials.
- Notification API warning has been addressed.
- Deprecated direct `HKWorkout` initializer has been replaced with `HKWorkoutBuilder`.

## Remaining Manual Release Checks

- Create the App Store Connect app record for `com.drgprfct.RepRing`.
- Archive in Xcode and confirm App Store distribution signing.
- Run physical-device HealthKit QA.
- Capture final App Store screenshots from the submitted build.
