PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iOS 17.5,iPhone \d\+ Pro [^M])

TEST_RUNNER_CI = $(CI)

default: test

test: test-ios test-examples

test-ios:
	xcodebuild test \
		-workspace Pagination.xcworkspace \
		-scheme Pagination \
		-destination platform="$(PLATFORM_IOS)"
test-examples:
	xcodebuild test \
		-workspace Pagination.xcworkspace \
		-scheme TMDB \
		-destination platform="$(PLATFORM_IOS)"

format:
	swift format \
		--ignore-unparsable-files \
		--in-place \
		--parallel \
		--recursive \
		./Examples ./Package.swift ./Sources ./Tests

define udid_for
$(shell xcrun simctl list devices available '$(1)' | grep '$(2)' | sort -r | head -1 | awk -F '[()]' '{ print $$(NF-3) }')
endef