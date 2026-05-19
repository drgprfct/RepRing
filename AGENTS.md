# AGENTS.md - RepRing

This repo is the App Store release workspace for RepRing, a small SwiftUI iPhone app for daily crunch and push-up tracking.

## Current Aim

Ship a clean App Store release without turning the project into process theater.

## Load First

- `docs/PROJECT_STATUS.md`
- `docs/SDLC.md`
- `docs/APP_STORE_RELEASE_CHECKLIST.md`
- `docs/PRIVACY_AND_HEALTHKIT.md` when touching HealthKit, privacy, analytics, storage, reminders, or App Store metadata

## Local Commands

- `make doctor` - check local Xcode/project assumptions.
- `make preflight` - run the normal local quality gate.
- `make release-check` - run the pre-submission local checks.

The Codex/XcodeBuildMCP local profile is intentionally machine-local under `.xcodebuildmcp/` and is ignored by git.

## Release Rules

- Do not ship or submit until Apple Developer enrollment, App Store signing, and physical-device HealthKit QA are complete.
- Do not change signing team, bundle id, capabilities, privacy claims, or App Store metadata without calling it out explicitly.
- HealthKit is optional user-controlled functionality. Do not add analytics, ads, remote sync, or third-party SDKs casually; they change the privacy label and review risk.
- Keep the app iPhone-first unless Daniel explicitly asks for iPad, watchOS, or Mac expansion.
- Treat screenshots, privacy copy, age rating, and HealthKit review notes as release artifacts, not afterthoughts.

## Quality Bar

- A normal change should pass `make preflight`.
- A release candidate should pass `make release-check`, a simulator smoke run, and a physical-device HealthKit smoke.
- Warnings are allowed only when tracked in `docs/PROJECT_STATUS.md` with an owner/next step. The current known warnings are not acceptable long-term release debt.

## UX Direction

Apple-grade minimalism applies here. Remove clutter, avoid fake success states, keep one clear next action, and prefer progressive disclosure. This app wins by being calm, local, fast, and honest.

## Source Control

Use small branches and commits. Commit only app-scoped changes from this repo. The surrounding OpenClaw workspace is dirty; do not stage or clean anything outside this folder.
