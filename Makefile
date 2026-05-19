PROJECT ?= RepRing.xcodeproj
SCHEME ?= RepRing
DESTINATION ?= platform=iOS Simulator,name=iPhone 17
DERIVED_DATA ?= .build/DerivedData

.PHONY: doctor build test preflight release-check

doctor:
	./scripts/doctor.sh

build:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration Debug -destination "$(DESTINATION)" -derivedDataPath "$(DERIVED_DATA)" build

test:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration Debug -destination "$(DESTINATION)" -derivedDataPath "$(DERIVED_DATA)" test

preflight:
	./scripts/preflight.sh

release-check:
	./scripts/release-check.sh
