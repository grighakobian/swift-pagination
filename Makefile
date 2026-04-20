PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iPhone)

default: test-ios

test-ios:
	xcodebuild test \
		-scheme Pagination \
		-destination platform="$(PLATFORM_IOS)"

test-macos:
	swift test

format:
	swift format \
		--ignore-unparsable-files \
		--in-place \
		--parallel \
		--recursive \
		./Package.swift ./Sources ./Tests

define udid_for
$(shell xcrun simctl list --json devices available '$(1)' | jq -r '[.devices|to_entries|sort_by(.key)|reverse|.[].value|select(length > 0)|.[0]][0].udid')
endef