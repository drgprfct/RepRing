# RepRing App Store Plan Implementation

Date: 2026-05-19
Scope: Implement the local and GitHub-facing pieces of the first App Store release plan while Apple Developer enrollment is still pending.

## Scope

- Set the app's production bundle identity to `com.drgprfct.RepRing`.
- Keep first-upload versioning at `1.3 (1)`.
- Add in-app Privacy Policy and Support links.
- Add GitHub Pages-ready public Privacy Policy and Support pages.
- Publish the GitHub repository and enable GitHub Pages from `/docs`.
- Add App Store metadata, first-release runbook, release blockers, and issue intake templates.
- Remove release-warning debt in notification settings and HealthKit workout export paths.
- Keep v1 observability Apple-only and keep release blockers explicit.

## Files Changed

- `RepRing.xcodeproj/project.pbxproj`
- `RepRing/SettingsView.swift`
- `RepRing/NotificationManager.swift`
- `RepRing/HealthKitManager.swift`
- `README.md`
- `CHANGELOG.md`
- `AGENTS.md`
- `scripts/release-check.sh`
- `docs/APP_STORE_RELEASE_CHECKLIST.md`
- `docs/PROJECT_STATUS.md`
- `docs/APP_STORE_METADATA.md`
- `docs/FIRST_RELEASE_RUNBOOK.md`
- `docs/RELEASE_BLOCKERS.md`
- `docs/index.html`
- `docs/privacy.html`
- `docs/support.html`
- `docs/styles.css`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`

## Tests Run

- `make preflight`: passed.
- `make release-check`: passed.
- XcodeBuildMCP simulator build/install/launch: passed on iPhone 17 / iOS 26.4 with bundle ID `com.drgprfct.RepRing`.
- XcodeBuildMCP UI snapshot: passed and confirmed the RepRing Today screen launched.
- `git diff --check`: passed.
- GitHub Pages build: passed.
- Privacy Policy URL: `https://drgprfct.github.io/RepRing/privacy.html` returned HTTP 200.
- Support URL: `https://drgprfct.github.io/RepRing/support.html` returned HTTP 200.

## Risks

- Apple Developer enrollment is still incomplete, so App ID reservation, signing, App Store Connect app creation, TestFlight upload, and App Review submission remain blocked.
- `com.drgprfct.RepRing` still needs to be confirmed as available inside Apple Developer after enrollment completes.
- HealthKit behavior still requires physical-device QA before submission.

## Rollback

- Revert the implementation commit to return to the previous local SDLC baseline.
- If `com.drgprfct.RepRing` is unavailable, update bundle IDs, docs, XcodeBuildMCP defaults, and App Store metadata to the planned fallback `com.danielwenzel.RepRing`.

## Outcome

The local App Store release baseline is implemented, published to GitHub, and validated. The remaining blockers are external account, signing, App Store Connect, screenshots, and physical-device HealthKit validation.
