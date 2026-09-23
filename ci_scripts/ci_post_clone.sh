#!/bin/sh

# Xcode Cloud runs this right after cloning the repo, before any
# xcodebuild action. Pods/ is gitignored (never committed), so the
# workspace won't resolve without this.

set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

if ! command -v pod >/dev/null 2>&1; then
    brew install cocoapods
fi

pod install
