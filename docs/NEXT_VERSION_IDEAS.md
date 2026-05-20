# Next Version Ideas

Last updated: 2026-05-20

## Working Theme

RepRing 1.4 candidate theme: **More movements, guided reps.**

This should be treated as post-first-release planning. Do not let this scope delay the first App Store release unless there is an explicit decision to reset the release plan.

## Product Direction

The next useful version could expand RepRing from two fixed movements into a small guided training tool:

- Additional training types beyond crunches and push-ups.
- A guided rep mode with audible countdown and counting.
- A short 5-second preparation countdown before the set starts.
- A small end-of-set fanfare.
- Slightly different sound feel per training variant.
- Haptics paired with sound for silent or low-audio use.
- Still local-only, with no accounts, analytics, backend, ads, or third-party observability.

## Scope Guardrail

Do not put this into the first App Store release.

Reason: this touches the data model, UI, audio behavior, HealthKit wording, screenshots, and QA surface. It is good product scope, but it is exactly the kind of feature set that can delay a first release.

## Training Types

RepRing should eventually move away from hardcoded `crunches` and `pushups` and toward an exercise catalog.

Candidate exercise types:

- Crunches
- Push-ups
- Squats
- Lunges
- Pull-ups
- Burpees
- Plank

Not every training type is counted the same way. Some are rep-based and some are duration-based.

Candidate units:

- Reps
- Seconds

Examples:

- Push-ups: 20 reps
- Squats: 25 reps
- Plank: 60 seconds

Avoid custom exercises in the first iteration. Custom exercises sound small, but they create naming, ordering, deletion, history migration, HealthKit metadata, screenshots, and support complexity. Ship a curated catalog first.

## Guided Counter

The guided counter should probably be attached to each exercise rather than being a global app mode.

Suggested flow:

1. User taps a speaker/count button for an exercise.
2. RepRing enters a preparation state: starting in 5 seconds.
3. Audible countdown plays: 5, 4, 3, 2, 1.
4. The set begins.
5. RepRing counts up or down during the set.
6. An end-of-set fanfare plays when the target is reached.
7. The completed set can be logged.

Count modes:

- Count up: 1, 2, 3...
- Count down: 20, 19, 18...

Be careful with auto-logging. People may mis-tap, stop early, or use the counter only as a pacing aid. The first implementation should likely show a clear primary action such as `Log +20` after a guided set completes. Auto-log completed guided sets can become a later setting.

## Sound Design

Keep the first audio system simple.

Possible implementation:

- Short local audio assets for countdown tick, rep tick, and finish fanfare.
- `AVSpeechSynthesizer` only if spoken numbers are desired.
- One simple setting such as `Counter sound: Minimal / Voice / Fanfare`.
- A mute or speaker toggle inside the guided counter flow.

Variant ideas:

- Crunches: softer tick, clean bell finish.
- Push-ups: firmer tick, punchier finish.
- Squats or lunges: lower tick, upward finish.
- Plank: interval chimes rather than every-second counting.

## Recommended 1.4 Scope

Ship a disciplined first version of the idea:

- Add squats and plank.
- Add guided counter for all exercises.
- Add countdown/countup choice.
- Add one sound style plus finish fanfare.
- Keep HealthKit export behavior simple: still one daily RepRing workout, with richer metadata describing exercise totals.

## Possible 1.5 Scope

Defer these until the guided-reps foundation proves useful:

- More exercise types.
- Multiple sound themes.
- Auto-log completed guided sets.
- Custom exercises.
- More detailed HealthKit mapping if Apple APIs and review constraints support it cleanly.

## Implementation Order

1. Generalize the data model from two fixed exercises to an exercise list.
2. Add a safe migration for existing crunch and push-up history.
3. Update Today and Dials to handle variable exercises without clutter.
4. Add a guided counter state machine.
5. Add local audio and haptics.
6. Update HealthKit metadata for multiple exercise totals.
7. Add tests for migration, logging, reset, and guided completion.
8. QA light/dark mode, small iPhone, backgrounding, interruptions, and audio edge cases.

## Release Framing

This is probably a `1.4` release, not `2.0`, unless the whole core experience is redesigned.

The disciplined product frame is **guided reps**, not **full training platform**.
