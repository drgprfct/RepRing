# Project Status

Last updated: 2026-05-19

## Snapshot

- App: RepRing
- Platform: iPhone, iOS 17+
- Xcode on this machine: 26.4.1
- Simulator profile: iPhone 17, iOS 26.4
- Current version in project: `MARKETING_VERSION = 1.3`, `CURRENT_PROJECT_VERSION = 1`
- Current bundle id: `com.drgprfct.RepRing`
- Primary local gate: `make preflight`

## What Works

- Source imported from `/Users/daniel/Downloads/RepRing`.
- Simulator Debug build succeeds on Xcode 26.4.1.
- XcodeBuildMCP local defaults are configured for this machine.
- A unit test target exists for core model/store behavior.
- App has HealthKit entitlement and HealthKit usage descriptions.
- App has no third-party SDKs and no apparent network layer in the imported source.
- GitHub repo exists at `https://github.com/drgprfct/RepRing`.
- GitHub Pages privacy/support pages are live:
  - `https://drgprfct.github.io/RepRing/privacy.html`
  - `https://drgprfct.github.io/RepRing/support.html`
- App Store metadata draft and first-release runbook exist.

## Release Blockers

- Complete Apple Developer Program enrollment.
- Confirm `com.drgprfct.RepRing` is available in Apple Developer and has HealthKit enabled.
- Confirm Apple Developer Team and App Store signing/provisioning.
- Capture final App Store screenshots from the submitted build.
- Run physical-device HealthKit QA. Simulator builds are not enough for HealthKit review confidence.

## Known Technical Debt

- There are unit tests, but no UI test/screenshot automation yet.
- No automated archive/upload lane exists yet; keep App Store upload manual until signing and App Store Connect access are confirmed.

## Next Best Slices

1. Complete Apple enrollment and confirm production App ID.
2. Run physical-device HealthKit QA.
3. Capture App Store screenshots.
4. Create the App Store Connect app record and upload the first TestFlight build.
