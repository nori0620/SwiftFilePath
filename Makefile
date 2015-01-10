all: test

test:
	xcodebuild -scheme SwiftFilePath test

.PHONY: all test
