# Release Blockers

Last updated: 2026-05-19

## Blocked By Apple Enrollment

- Apple Developer Program enrollment is not complete.
- App Store Connect app record cannot be created yet.
- Production App ID and HealthKit capability cannot be confirmed yet.
- App Store upload/TestFlight cannot happen yet.

## Local Blockers Closed

- Production bundle ID has been changed to `com.drgprfct.RepRing`.
- Test target bundle ID has been changed to `com.drgprfct.RepRingTests`.
- GitHub Pages privacy and support pages exist in `docs/`.
- In-app Privacy Policy and Support links exist in Dials.
- Notification API warning has been addressed.
- Deprecated direct `HKWorkout` initializer has been replaced with `HKWorkoutBuilder`.

## Remaining Manual Release Checks

- Verify `https://drgprfct.github.io/RepRing/privacy.html` is live after GitHub Pages deploys.
- Verify `https://drgprfct.github.io/RepRing/support.html` is live after GitHub Pages deploys.
- Confirm `com.drgprfct.RepRing` is available in Apple Developer.
- Run physical-device HealthKit QA.
- Capture final App Store screenshots from the submitted build.
