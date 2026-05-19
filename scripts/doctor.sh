#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PROJECT="${PROJECT:-RepRing.xcodeproj}"
SCHEME="${SCHEME:-RepRing}"

echo "RepRing doctor"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "FAIL: xcodebuild is not available."
  exit 1
fi

XCODEBUILD_VERSION_OUTPUT="$(xcodebuild -version)"
XCODE_VERSION="$(printf '%s\n' "$XCODEBUILD_VERSION_OUTPUT" | awk 'NR == 1 {print $2}')"
XCODE_MAJOR="${XCODE_VERSION%%.*}"

echo "Xcode: $(printf '%s' "$XCODEBUILD_VERSION_OUTPUT" | tr '\n' ' ')"

if [[ "${XCODE_MAJOR:-0}" -lt 26 ]]; then
  echo "FAIL: App Store uploads after 2026-04-28 require the iOS 26 SDK or later. Install/use Xcode 26+."
  exit 1
fi

if [[ ! -d "$PROJECT" ]]; then
  echo "FAIL: missing $PROJECT"
  exit 1
fi

PROJECT_LIST="$(xcodebuild -list -project "$PROJECT")"
if ! printf '%s\n' "$PROJECT_LIST" | grep -q "^[[:space:]]*$SCHEME$"; then
  echo "FAIL: scheme $SCHEME not found in $PROJECT"
  exit 1
fi

if ! /usr/bin/plutil -lint RepRing/Info.plist >/dev/null; then
  echo "FAIL: Info.plist is invalid."
  exit 1
fi

if ! /usr/bin/plutil -lint RepRing/RepRing.entitlements >/dev/null; then
  echo "FAIL: RepRing.entitlements is invalid."
  exit 1
fi

echo "OK"
