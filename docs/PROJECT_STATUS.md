# Project Status

Last updated: 2026-05-25

## Snapshot

- App: RepRing
- Platform: iPhone, iOS 17+
- Xcode on this machine: 26.4.1
- Simulator profile: iPhone 17, iOS 26.4
- Current version in project: `MARKETING_VERSION = 1.3`, `CURRENT_PROJECT_VERSION = 1`
- Current bundle id: `com.drgprfct.RepRing`
- Apple Developer Team configured in Xcode: `52ZF3NP5J2`
- Latest App Store Connect upload: `1.3 (2)` uploaded on 2026-05-25 and is processing.
- App Store Connect app version record observed in Xcode upload logs: `1.0`. Before App Review, align the App Store version record with the binary version `1.3` or deliberately upload a `1.0` binary instead.
- Primary local gate: `make preflight`

## What Works

- Source imported from `/Users/daniel/Downloads/RepRing`.
- Simulator Debug build succeeds on Xcode 26.4.1.
- XcodeBuildMCP local defaults are configured for this machine.
- A unit test target exists for core model/store behavior.
- App has HealthKit entitlement and HealthKit usage descriptions.
- Xcode automatic development provisioning succeeded for `com.drgprfct.RepRing` with HealthKit entitlement.
- Xcode archive and App Store Connect uploads succeeded for `1.3 (1)` and `1.3 (2)`.
- Build `1.3 (2)` was exported with the explicit App Store provisioning profile `RepRing App Store` and Apple Distribution certificate.
- App has no third-party SDKs and no apparent network layer in the imported source.
- GitHub repo exists at `https://github.com/drgprfct/RepRing`.
- GitHub Pages privacy/support/terms pages are live:
  - `https://drgprfct.github.io/RepRing/privacy.html`
  - `https://drgprfct.github.io/RepRing/support.html`
  - `https://drgprfct.github.io/RepRing/terms.html`
- App Store metadata draft and first-release runbook exist.

## Release Blockers

- Wait for App Store Connect build processing for build `1.3 (2)` to finish.
- Align the App Store Connect app version record with the binary version before App Review.
- Add the processed build to internal TestFlight.
- Capture final App Store screenshots from the submitted build.
- Run physical-device HealthKit QA. Simulator builds are not enough for HealthKit review confidence.

## Known Technical Debt

- There are unit tests, but no UI test/screenshot automation yet.
- No automated archive/upload lane exists yet; keep App Store upload manual until signing and App Store Connect access are confirmed.

## Next Best Slices

1. Wait for App Store Connect processing for build `1.3 (2)`.
2. Add yourself as an internal TestFlight tester.
3. Install the TestFlight build on a physical iPhone.
4. Run physical-device HealthKit QA.
5. Capture App Store screenshots from the submitted/TestFlight build.
