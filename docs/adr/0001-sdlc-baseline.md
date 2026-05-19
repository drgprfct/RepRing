# ADR 0001: Small-App SDLC Baseline

Date: 2026-05-19

## Status

Accepted.

## Context

RepRing is a small SwiftUI app being prepared for App Store release. The main risks are not architecture scale; they are release hygiene, privacy accuracy, HealthKit review confidence, and repeatable local verification.

## Decision

Use a lightweight SDLC:

- App-scoped docs in `docs/`.
- Local scripts behind `make`.
- Unit tests for core store/model behavior.
- Manual App Store upload until signing and App Store Connect access are confirmed.
- App Store readiness tracked in `docs/APP_STORE_RELEASE_CHECKLIST.md`.

## Alternatives Rejected

- Full enterprise process with issue templates, release boards, and heavyweight CI: too much drag for a tiny app.
- No process beyond README: too fragile for HealthKit/App Store release.
- Immediate automated App Store upload: premature until bundle id, signing, team, and App Store Connect access are confirmed.

## Consequences

The repo has enough structure for future Codex sessions to continue safely, but does not pretend release submission is solved before Apple account and privacy-policy details exist.
