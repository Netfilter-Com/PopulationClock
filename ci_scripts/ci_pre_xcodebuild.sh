#!/bin/sh

# Xcode Cloud runs this before each xcodebuild action. Fail the build early
# when the country data or the localization is inconsistent
# (Scripts/check_data.py exits 1 on errors; warnings do not fail it).

set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

python3 Scripts/check_data.py
