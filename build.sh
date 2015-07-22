#!/bin/sh

# The script exits immediately if any statement or command returns non-true value
set -e

xcodebuild -workspace "$PROJECT_NAME" -scheme "$SCHEME_NAME" -configuration "$CONFIGURATION_NAME" -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO | xcpretty -c && exit ${PIPESTATUS[0]}

