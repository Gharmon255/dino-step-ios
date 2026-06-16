#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ARCHIVE_PATH="$ROOT/build/DinoStep.xcarchive"
EXPORT_PATH="$ROOT/build/export"
EXPORT_OPTIONS="$ROOT/ExportOptions.plist"

echo "==> Archive (Release, iOS device)"
xcodebuild \
  -scheme "Dino Step" \
  -destination "generic/platform=iOS" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  archive

echo ""
echo "==> Export for App Store Connect / TestFlight"
rm -rf "$EXPORT_PATH"
xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS"

echo ""
echo "Done."
echo "  Archive: $ARCHIVE_PATH"
echo "  Export:  $EXPORT_PATH"
echo ""
echo "If export uploaded successfully, check App Store Connect → TestFlight."
echo "Otherwise upload from Xcode Organizer or Transporter."
echo "Full checklist: docs/TESTFLIGHT_GET_STARTED.md"
