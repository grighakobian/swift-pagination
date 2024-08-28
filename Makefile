PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iOS 17.5,iPhone \d\+ Pro [^M])
PLATFORM_TVOS = tvOS Simulator,id=$(call udid_for,tvOS 17.5,TV)
PLATFORM_WATCHOS = watchOS Simulator,id=$(call udid_for,watchOS 10.5,Watch)

TEST_RUNNER_CI = $(CI)

default: test

test: test-ios test-tvos test-watchos

test-ios:
	xcodebuild test \
		-workspace Pagination.xcworkspace \
		-scheme Pagination \
		-destination platform="$(PLATFORM_IOS)"
test-macos:
	xcodebuild test \
		-workspace Pagination.xcworkspace \
		-scheme Pagination \
		-destination platform="$(PLATFORM_MACOS)"
test-tvos:
	xcodebuild test \
		-workspace Pagination.xcworkspace \
		-scheme Pagination \
		-destination platform="$(PLATFORM_TVOS)"
test-watchos:
	xcodebuild test \
		-workspace Pagination.xcworkspace \
		-scheme Pagination \
		-destination platform="$(PLATFORM_WATCHOS)"
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