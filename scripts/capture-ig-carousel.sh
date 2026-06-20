#!/usr/bin/env bash
# Capture the 3-slide IG carousel scenes (matches Android story).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "$ROOT/scripts/capture-ig-screenshots.sh" "$ROOT/marketing/screenshots/ig" carousel
