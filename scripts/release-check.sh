#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PROJECT="${PROJECT:-RepRing.xcodeproj}"
SCHEME="${SCHEME:-RepRing}"
DERIVED_DATA="${DERIVED_DATA:-.build/DerivedData}"

./scripts/doctor.sh

BUILD_SETTINGS="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "generic/platform=iOS" -showBuildSettings 2>/dev/null)"
BUNDLE_ID="$(printf '%s\n' "$BUILD_SETTINGS" | awk -F '= ' '$1 ~ /^[[:space:]]*PRODUCT_BUNDLE_IDENTIFIER[[:space:]]*$/ {print $2; exit}')"
MARKETING_VERSION="$(printf '%s\n' "$BUILD_SETTINGS" | awk -F '= ' '$1 ~ /^[[:space:]]*MARKETING_VERSION[[:space:]]*$/ {print $2; exit}')"
BUILD_NUMBER="$(printf '%s\n' "$BUILD_SETTINGS" | awk -F '= ' '$1 ~ /^[[:space:]]*CURRENT_PROJECT_VERSION[[:space:]]*$/ {print $2; exit}')"

echo "Bundle id: ${BUNDLE_ID:-unknown}"
echo "Version: ${MARKETING_VERSION:-unknown} (${BUILD_NUMBER:-unknown})"

if [[ "$BUNDLE_ID" == "com.example.RepRing" ]]; then
  echo "FAIL: replace placeholder bundle id before App Store release."
  exit 1
fi

if ! /usr/bin/plutil -extract NSHealthShareUsageDescription raw RepRing/Info.plist >/dev/null; then
  echo "FAIL: missing NSHealthShareUsageDescription."
  exit 1
fi

if ! /usr/bin/plutil -extract NSHealthUpdateUsageDescription raw RepRing/Info.plist >/dev/null; then
  echo "FAIL: missing NSHealthUpdateUsageDescription."
  exit 1
fi

if ! /usr/libexec/PlistBuddy -c "Print :com.apple.developer.healthkit" RepRing/RepRing.entitlements >/dev/null; then
  echo "FAIL: missing HealthKit entitlement."
  exit 1
fi

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build

echo "OK: local release checks passed. App Store submission still requires real signing, metadata, privacy policy, and TestFlight."
