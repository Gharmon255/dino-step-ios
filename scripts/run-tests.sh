#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DESTINATION="${1:-platform=iOS Simulator,name=iPhone 16}"

echo "==> iOS unit tests (scheme: Dino Step)"
xcodebuild test \
  -scheme "Dino Step" \
  -destination "$DESTINATION" \
  -only-testing:"Dino StepTests" \
  CODE_SIGNING_ALLOWED=NO

echo ""
echo "All iOS unit tests passed."
