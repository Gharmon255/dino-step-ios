#!/usr/bin/env bash
# Capture polished Stepasaurus screenshots from the iOS Simulator for IG / marketing.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${1:-$ROOT/marketing/screenshots/ig}"
DERIVED_DATA="${DERIVED_DATA:-$HOME/Library/Developer/Xcode/DerivedData/Dino_Step-ebahystpgmaltaejccpdbnsigxet}"
BUNDLE_ID="com.gharmon255.Dino-Step"
SIM_NAME="${SIM_NAME:-iPhone 17 Pro}"
STATES_DIR="$ROOT/marketing/screenshot-states"

mkdir -p "$OUT_DIR" "$STATES_DIR"

UDID="$(xcrun simctl list devices available | awk -v name="$SIM_NAME" -F '[()]' '$0 ~ name { print $2; exit }')"
if [[ -z "${UDID:-}" ]]; then
  echo "Could not find simulator: $SIM_NAME" >&2
  exit 1
fi

echo "==> Booting $SIM_NAME ($UDID)"
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$UDID"
xcrun simctl bootstatus "$UDID" -b

echo "==> Clean status bar (9:41, full battery, strong signal)"
xcrun simctl status_bar "$UDID" override \
  --time "9:41" \
  --batteryState charged \
  --batteryLevel 100 \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --dataNetwork lte

echo "==> Building Debug for simulator"
xcodebuild \
  -project "$ROOT/Dino Step.xcodeproj" \
  -scheme "Dino Step" \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA" \
  -destination "platform=iOS Simulator,id=$UDID" \
  build \
  CODE_SIGNING_ALLOWED=NO \
  | xcpretty 2>/dev/null || true

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/Dino Step.app"
if [[ ! -d "$APP_PATH" ]]; then
  APP_PATH="$(find "$DERIVED_DATA/Build/Products" -name 'Dino Step.app' -path '*iphonesimulator*' | head -1)"
fi
if [[ ! -d "$APP_PATH" ]]; then
  echo "Could not find built .app under $DERIVED_DATA" >&2
  exit 1
fi

# Install once so the simulator has the app bundle available.
xcrun simctl install "$UDID" "$APP_PATH"

inject_save_state() {
  local state_file="$1"
  python3 - "$state_file" "$UDID" "$BUNDLE_ID" "$APP_PATH" <<'PY'
import json
import plistlib
import subprocess
import sys
from pathlib import Path

state_file, udid, bundle_id, app_path = sys.argv[1:5]
state = json.loads(Path(state_file).read_text())

# Bootstrap the container with a one-shot launch so preferences path exists.
subprocess.run(["xcrun", "simctl", "launch", udid, bundle_id], check=False, capture_output=True)
subprocess.run(["xcrun", "simctl", "terminate", udid, bundle_id], check=False, capture_output=True)

container = subprocess.check_output(
    ["xcrun", "simctl", "get_app_container", udid, bundle_id, "data"],
    text=True,
).strip()
prefs_dir = Path(container) / "Library" / "Preferences"
prefs_dir.mkdir(parents=True, exist_ok=True)
prefs_path = prefs_dir / f"{bundle_id}.plist"

payload = json.dumps(state).encode("utf-8")
with prefs_path.open("wb") as handle:
    plistlib.dump({"dino_step_saved_game_state": payload}, handle)
PY
}

capture() {
  local name="$1"
  local state_file="$2"
  local tab="${3:-0}"

  echo "==> Capturing $name"
  xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl install "$UDID" "$APP_PATH"
  inject_save_state "$state_file"
  xcrun simctl launch "$UDID" "$BUNDLE_ID" "-screenshotMode" "-screenshotTab=$tab" >/dev/null
  sleep 3
  xcrun simctl io "$UDID" screenshot "$OUT_DIR/$name.png"
}

write_state_files() {
  local now
  now="$(python3 - <<'PY'
import datetime
ref = datetime.datetime(2001, 1, 1, tzinfo=datetime.timezone.utc)
now = datetime.datetime(2026, 6, 10, 15, 0, 0, tzinfo=datetime.timezone.utc)
print((now - ref).total_seconds())
PY
)"

  cat > "$STATES_DIR/01-legendary-egg.json" <<EOF
{
  "schemaVersion": 2,
  "activeCreature": {
    "creatureDefinitionId": "A100001C-0000-4000-8000-00000000001C",
    "eggRarity": "LEGENDARY",
    "currentSteps": 0,
    "startedAt": $now
  },
  "completedCreatures": [],
  "lastRewardedEggRarity": "LEGENDARY",
  "lastRewardRollPercent": 1.5,
  "lastSyncedHealthKitStepTotal": 8420,
  "lastHealthKitSyncDayStart": $now,
  "lastHealthKitSyncMessage": "Synced 8,420 steps from Apple Health"
}
EOF

  cat > "$STATES_DIR/02-epic-crystal-juvenile.json" <<EOF
{
  "schemaVersion": 2,
  "activeCreature": {
    "creatureDefinitionId": "A1000021-0000-4000-8000-000000000021",
    "eggRarity": "EPIC",
    "currentSteps": 32000,
    "startedAt": $now
  },
  "completedCreatures": [],
  "lastRewardedEggRarity": "EPIC",
  "lastRewardRollPercent": 4.2,
  "lastSyncedHealthKitStepTotal": 32000,
  "lastHealthKitSyncDayStart": $now,
  "lastHealthKitSyncMessage": "Synced 32,000 steps from Apple Health"
}
EOF

  cat > "$STATES_DIR/03-adult-volcanic-trex.json" <<EOF
{
  "schemaVersion": 2,
  "activeCreature": {
    "creatureDefinitionId": "A1000017-0000-4000-8000-000000000017",
    "eggRarity": "LEGENDARY",
    "currentSteps": 125000,
    "startedAt": $now
  },
  "completedCreatures": [],
  "lastRewardedEggRarity": "LEGENDARY",
  "lastRewardRollPercent": 0.8,
  "lastSyncedHealthKitStepTotal": 125000,
  "lastHealthKitSyncDayStart": $now,
  "lastHealthKitSyncMessage": "Synced 125,000 steps from Apple Health"
}
EOF

  cat > "$STATES_DIR/04-adult-abyssal-mosasaurus.json" <<EOF
{
  "schemaVersion": 2,
  "activeCreature": {
    "creatureDefinitionId": "A1000022-0000-4000-8000-000000000022",
    "eggRarity": "LEGENDARY",
    "currentSteps": 190000,
    "startedAt": $now
  },
  "completedCreatures": [],
  "lastRewardedEggRarity": "LEGENDARY",
  "lastRewardRollPercent": 0.4,
  "lastSyncedHealthKitStepTotal": 190000,
  "lastHealthKitSyncDayStart": $now,
  "lastHealthKitSyncMessage": "Synced 190,000 steps from Apple Health"
}
EOF

  cat > "$STATES_DIR/05-baby-trex.json" <<EOF
{
  "schemaVersion": 2,
  "activeCreature": {
    "creatureDefinitionId": "A100000D-0000-4000-8000-00000000000D",
    "eggRarity": "RARE",
    "currentSteps": 16000,
    "startedAt": $now
  },
  "completedCreatures": [],
  "lastRewardedEggRarity": "RARE",
  "lastRewardRollPercent": 6.8,
  "lastSyncedHealthKitStepTotal": 16000,
  "lastHealthKitSyncDayStart": $now,
  "lastHealthKitSyncMessage": "Synced 16,000 steps from Apple Health"
}
EOF

  cat > "$STATES_DIR/06-collection.json" <<EOF
{
  "schemaVersion": 2,
  "activeCreature": {
    "creatureDefinitionId": "A100001C-0000-4000-8000-00000000001C",
    "eggRarity": "LEGENDARY",
    "currentSteps": 4200,
    "startedAt": $now
  },
  "completedCreatures": [
    {
      "id": "B1000001-0000-4000-8000-000000000001",
      "creatureDefinitionId": "A1000001-0000-4000-8000-000000000001",
      "totalStepsCompleted": 8000,
      "completedAt": $now
    },
    {
      "id": "B1000002-0000-4000-8000-000000000002",
      "creatureDefinitionId": "A1000007-0000-4000-8000-000000000007",
      "totalStepsCompleted": 18000,
      "completedAt": $now
    },
    {
      "id": "B1000003-0000-4000-8000-000000000003",
      "creatureDefinitionId": "A100000D-0000-4000-8000-00000000000D",
      "totalStepsCompleted": 50000,
      "completedAt": $now
    },
    {
      "id": "B1000004-0000-4000-8000-000000000004",
      "creatureDefinitionId": "A1000013-0000-4000-8000-000000000013",
      "totalStepsCompleted": 85000,
      "completedAt": $now
    },
    {
      "id": "B1000005-0000-4000-8000-000000000005",
      "creatureDefinitionId": "A1000021-0000-4000-8000-000000000021",
      "totalStepsCompleted": 92000,
      "completedAt": $now
    },
    {
      "id": "B1000006-0000-4000-8000-000000000006",
      "creatureDefinitionId": "A1000017-0000-4000-8000-000000000017",
      "totalStepsCompleted": 125000,
      "completedAt": $now
    },
    {
      "id": "B1000007-0000-4000-8000-000000000007",
      "creatureDefinitionId": "A1000022-0000-4000-8000-000000000022",
      "totalStepsCompleted": 190000,
      "completedAt": $now
    }
  ],
  "lastRewardedEggRarity": "LEGENDARY",
  "lastRewardRollPercent": 0.9,
  "lastSyncedHealthKitStepTotal": 4200,
  "lastHealthKitSyncDayStart": $now,
  "lastHealthKitSyncMessage": "Synced 4,200 steps from Apple Health"
}
EOF
}

write_state_files

MODE="${2:-all}"

if [[ "$MODE" == "carousel" ]]; then
  capture "01-legendary-egg" "$STATES_DIR/01-legendary-egg.json" 0
  capture "02-rare-egg-80" "$STATES_DIR/02-rare-egg-80.json" 0
  capture "03-volcanic-trex-baby" "$STATES_DIR/03-volcanic-trex-baby.json" 0
else
  capture "01-legendary-egg" "$STATES_DIR/01-legendary-egg.json" 0
  capture "02-epic-crystal-juvenile" "$STATES_DIR/02-epic-crystal-juvenile.json" 0
  capture "03-adult-volcanic-trex" "$STATES_DIR/03-adult-volcanic-trex.json" 0
  capture "04-adult-abyssal-mosasaurus" "$STATES_DIR/04-adult-abyssal-mosasaurus.json" 0
  capture "05-baby-trex" "$STATES_DIR/05-baby-trex.json" 0
  capture "06-collection" "$STATES_DIR/06-collection.json" 1
fi

xcrun simctl status_bar "$UDID" clear 2>/dev/null || true

echo ""
echo "Done! Screenshots saved to:"
echo "  $OUT_DIR"
ls -1 "$OUT_DIR"/*.png
