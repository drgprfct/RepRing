# RepRing SDLC

This is a small-app SDLC. Anything heavier is bureaucracy wearing a fake mustache.

## 1. Intake

Every change starts as one of four types:

- Bug: broken behavior, crash, data loss, review rejection risk.
- Release: versioning, signing, App Store metadata, TestFlight, screenshots.
- Product: user-visible feature or UX refinement.
- Maintenance: warnings, tests, dependencies, docs, build hygiene.

Each work item should state intent, acceptance criteria, test plan, risk, and rollback. Keep it in the task, PR, or a short note under `docs/` if it will matter later.

## 2. Branching

- `main` is releasable or close to it.
- Use short-lived branches for work.
- Prefer one coherent change per commit.
- Do not mix release metadata, UX changes, and infrastructure unless the change truly requires it.

## 3. Build And Test Gate

Normal local gate:

```sh
make preflight
```

Release candidate gate:

```sh
make release-check
```

Release candidates also require manual simulator smoke and physical-device HealthKit smoke.

## 4. Definition Of Done

A normal change is done when:

- The app builds.
- Relevant tests pass.
- User-visible behavior has been checked in simulator or preview.
- Docs/checklists are updated when release, privacy, or workflow behavior changes.
- Risks and rollback are known.

A release candidate is done when:

- `make release-check` passes.
- Bundle id and signing are production-ready.
- App Store metadata is complete.
- Privacy answers match the actual binary.
- Screenshots match the submitted build.
- HealthKit permissions and export behavior have been tested on a real device.
- TestFlight has at least one clean internal build pass.

## 5. Versioning

- `MARKETING_VERSION` is the user-facing version.
- `CURRENT_PROJECT_VERSION` is the monotonically increasing build number App Store Connect uses to distinguish uploads.
- Every upload attempt gets a new build number.
- Update `CHANGELOG.md` before cutting a release candidate.

## 6. Release Train

1. Stabilize scope.
2. Run `make preflight`.
3. Update version/build.
4. Run `make release-check`.
5. Archive in Xcode.
6. Upload to App Store Connect.
7. TestFlight internal smoke.
8. Fix blockers or submit for review.
9. Tag the accepted release.

## 7. Rollback

Code rollback is `git revert <commit>`.

App Store rollback is operational:

- If not approved: remove the build from review and upload a fixed build.
- If approved but unreleased: cancel release or choose manual release.
- If released: ship a patched higher build/version. App Store production rollback to an older binary is not a normal lever.

## References Verified 2026-05-19

- [Apple: Submit your apps and games today](https://developer.apple.com/app-store/submitting/)
- [Apple: Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)
- [Apple: Submit an app](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app)
