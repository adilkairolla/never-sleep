#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")"
swift build -c release
APP="$PWD/dist/Never Sleep.app"
mkdir -p "$APP/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/NeverSleep" "$APP/Contents/MacOS/NeverSleep"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
echo "Built: $APP"
