# Privacy And HealthKit

Verified against Apple developer docs on 2026-05-19.

## Current Data Model

RepRing currently stores:

- Daily crunch count.
- Daily push-up count.
- Set size and goal settings.
- Reminder times and reminder enabled state.
- Appearance preference.
- Apple Health auto-export preference.
- Last Apple Health export signature.

Storage is local `UserDefaults`.

## Current External Data Flow

No network layer or third-party SDK is present in the imported source.

Optional Apple Health flow:

- User grants HealthKit permission.
- RepRing reads/writes workouts to manage one RepRing strength-training workout per day.
- RepRing writes metadata for crunches, push-ups, total reps, day key, and export kind.

## App Privacy Working Position

Current working assumption: App Store privacy label can likely be "Data Not Collected" because Apple defines collection around data transmitted off device in a way the developer or third-party partners can access beyond real-time request handling. RepRing's imported source appears to keep data on device and in the user's Health store.

This assumption is invalidated by adding analytics, crash reporting, accounts, cloud sync, ads, remote logging, feedback forms, or any third-party SDK that transmits app/user/device data.

## Required Privacy Policy Points

The privacy policy should state:

- RepRing stores rep counts and settings locally on the user's device.
- Reminders are scheduled locally through iOS notifications.
- Apple Health export is optional and requires HealthKit permission.
- HealthKit data is not used for advertising, marketing, or third-party sharing.
- RepRing does not currently run a server account system.
- Deleting the app removes local app data; users can also reset daily reps in the app.
- Users manage HealthKit permissions in iOS Settings/Health.

## Review Risk

- Do not make medical, diagnostic, therapeutic, or injury-prevention claims.
- Do not imply Apple Health export is a precise physiological measurement. It is a user-entered workout representation.
- Do not add Clinical Health Records capability.
- Do not require HealthKit or notifications for core app use.

## References

- [Apple: App privacy details](https://developer.apple.com/app-store/app-privacy-details/)
- [Apple: App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Apple Human Interface Guidelines: HealthKit](https://developer.apple.com/design/human-interface-guidelines/healthkit)
- [Apple: Third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/)
