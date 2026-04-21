PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iPhone)
DERIVED_DATA_PATH = ~/.derivedData
EXAMPLES_PROJECT = Examples/Examples.xcodeproj

.PHONY: default test-ios test-macos format examples \
        build-examples-ios build-examples-macos build-objc-ios \
        build-swiftui-ios build-swiftui-macos

default: test-ios

test-ios:
	xcodebuild test \
		-scheme Pagination \
		-destination platform="$(PLATFORM_IOS)" \
		-derivedDataPath $(DERIVED_DATA_PATH)

test-macos:
	swift test

format:
	swift format \
		--ignore-unparsable-files \
		--in-place \
		--parallel \
		--recursive \
		./Package.swift ./Sources ./Tests

examples:
	@command -v xcodegen >/dev/null || { echo "xcodegen not found, installing via Homebrew..."; brew install xcodegen; }
	cd Examples && xcodegen generate

build-examples-ios: examples
	xcodebuild build \
		-project $(EXAMPLES_PROJECT) \
		-scheme Examples \
		-destination platform="$(PLATFORM_IOS)" \
		-derivedDataPath $(DERIVED_DATA_PATH)

build-examples-macos: examples
	xcodebuild build \
		-project $(EXAMPLES_PROJECT) \
		-scheme Examples \
		-destination 'platform=macOS' \
		-derivedDataPath $(DERIVED_DATA_PATH)

build-objc-ios: examples
	xcodebuild build \
		-project $(EXAMPLES_PROJECT) \
		-scheme Objc \
		-destination platform="$(PLATFORM_IOS)" \
		-derivedDataPath $(DERIVED_DATA_PATH)

build-swiftui-ios: examples
	xcodebuild build \
		-project $(EXAMPLES_PROJECT) \
		-scheme SwiftUIExample \
		-destination platform="$(PLATFORM_IOS)" \
		-derivedDataPath $(DERIVED_DATA_PATH)

build-swiftui-macos: examples
	xcodebuild build \
		-project $(EXAMPLES_PROJECT) \
		-scheme SwiftUIExample \
		-destination 'platform=macOS' \
		-derivedDataPath $(DERIVED_DATA_PATH)

define udid_for
$(shell xcrun simctl list --json devices available '$(1)' | jq -r '[.devices|to_entries|sort_by(.key)|reverse|.[].value|select(length > 0)|.[0]][0].udid')
endef
