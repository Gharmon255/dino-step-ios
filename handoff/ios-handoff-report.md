---
# Dino Step iOS Handoff Report

**Repo:** dino-step-ios  
**Date:** 2026-06-04 (report); **updated 2026-06-06** for asset/doc status  
**Branch:** main  

> **June 2026 update:** Catalog art is **29/29 asset-backed**. All dino stage PNGs are **1024×1024** in phone and watch asset catalogs (87 imagesets + 5 eggs). See `SPECIES_ROSTER.md` and `README.md` for current counts. Sections below retain the original 2026-06-04 handoff snapshot unless noted.

## Executive summary (June 2026 — current)

- **29 catalog species**, **29 asset-backed**, **0 placeholder** — full PNG coverage on iPhone + watch.
- **87** dino stage PNGs + **5** egg PNGs in both `Assets.xcassets` catalogs.
- Legacy `trex`, `triceratops`, `tiny_raptor` PNGs normalized to **1024×1024** (June 2026).
- App icons imported from `dino-step-assets/icons/` (see `LAUNCH_CHECKLIST.md`).
- TestFlight upload pending Apple Developer Program enrollment (see prior session notes).

## Executive summary (2026-06-04 original snapshot)

- Store-hardening commit **`31f7f79`** on `main`.
- Release vs DEBUG audit: **no dev/diagnostic UI leaks** in Release builds.
- **iOS + watchOS simulator builds pass** (`xcodebuild`, exit 0).
- Draft App Store metadata at `docs/APP_STORE_METADATA.md`.

## 1. Workspace identity & git state

| Item | Value |
|------|-------|
| Repo path | `/Users/gharmon/projects/dino-step-ios` |
| Remote | `origin` → `git@github.com:Gharmon255/dino-step-ios.git` |
| Branch | `main` |
| Tracking | `origin/main` |
| Ahead / behind | **Ahead 1**, behind 0 |
| Working tree | **Clean** (no modified or untracked files at inspection time) |
| Latest commit | `31f7f791bb226dbf6efeefadd5e15130f1fc7553` |
| Latest message | Harden iOS release readiness |
| Latest date | 2026-06-04 22:19:26 -0400 |

### Unpushed commits

| Hash | Message | Date | Files changed |
|------|---------|------|---------------|
| `31f7f79` | Harden iOS release readiness | 2026-06-04 | `Dino Step/Views/StatsView.swift`, `Dino Step/PrivacyInfo.xcprivacy`, `Dino Step/Health/HealthKitStepService.swift`, `Dino Step.xcodeproj/project.pbxproj`, `LAUNCH_CHECKLIST.md` |

**Remote HEAD (`origin/main`):** `4d8ab71` — Add iOS Dino Dex completion dashboard (2026-06-03)

## 2. Completed work (with file paths)

### Gameplay & core loop
- Step-based egg → hatch → baby/juvenile/adult → claim — `Dino Step/Game/GameState.swift`, `GameLogic.swift`, `EggRewardLogic.swift`
- Home UI: sync steps, stage/overall progress, claim reward — `Dino Step/Views/HomeView.swift`
- HealthKit manual sync — `Dino Step/Health/HealthKitStepService.swift`
- Local persistence (UUID saves) — `Dino Step/Persistence/GamePersistenceStore.swift`, `SavedGameState.swift`

### Collection & Dino Dex
- Collection grid, species cards, visuals — `Dino Step/Views/CollectionView.swift`, `CollectionSpeciesCard.swift`, `CreatureStageVisualView.swift`
- Dino Dex completion dashboard — `Dino Step/Views/CollectionSummaryView.swift`, `Dino Step/Game/CollectionCatalog.swift` (commit `4d8ab71`)

### Apple Watch
- Phone → watch sync — `Dino Step/Watch/PhoneWatchConnectivityManager.swift`, `WatchGameStatePayloadBuilder.swift`
- Watch UI — `Dino Step Watch Watch App/ContentView.swift`, `WatchProgressRingView.swift`
- Shared payload — `Dino Step Shared/WatchGameStatePayload.swift`
- App-level WC activation (Release + Debug) — `Dino Step/Dino_StepApp.swift`

### Catalog & assets
- 29-species catalog — `Dino Step/Game/CreatureCatalog.swift`
- 29 asset-backed species resolver — `Dino Step Shared/CreatureAssetVisual.swift`
- iPhone PNGs: 92 (87 dino stage + 5 eggs) — `Dino Step/Assets.xcassets/`
- Watch PNGs: 92 (mirrored) — `Dino Step Watch Watch App/Assets.xcassets/`

### Store hardening (31f7f79)
- Release Stats gating — `Dino Step/Views/StatsView.swift`
- Privacy manifest — `Dino Step/PrivacyInfo.xcprivacy`
- HealthKit usage string — `Dino Step.xcodeproj/project.pbxproj`
- Simulator fake-steps hint gated — `Dino Step/Health/HealthKitStepService.swift`
- Launch checklist — `LAUNCH_CHECKLIST.md`

### Docs
- `README.md`, `SPECIES_ROSTER.md`, `SPECIES_ONBOARDING_CHECKLIST.md`, `WATCH_SYNC_CONTRACT.md`, `LAUNCH_CHECKLIST.md`
- **New this session:** `docs/APP_STORE_METADATA.md` (draft)

## 3. Store-hardening verification (31f7f79)

| Check | Status | Notes |
|-------|--------|-------|
| StatsView Release = Current Run + Lifetime only | **Pass** | Lines 18–46 visible in all builds; lines 48–248 wrapped in `#if DEBUG` |
| StatsView dev panels `#if DEBUG` | **Pass** | Persistence, HealthKit tech status, Watch Sync, payload dump, Egg Testing, Developer Testing all gated |
| HomeView fake steps DEBUG only | **Pass** | `#if DEBUG` at lines 127–134; `stepButton` helpers have no Release callers |
| PrivacyInfo.xcprivacy present | **Pass** | `Dino Step/PrivacyInfo.xcprivacy` — tracking false, Fitness collected for App Functionality |
| HealthKit usage string in pbxproj | **Pass** | Debug + Release: *"Dino Step reads your step count from Apple Health to hatch eggs and grow dinosaurs. Location data is not used."* |
| HealthKitStepService simulator hint DEBUG only | **Pass** | `#if DEBUG` around fake-steps message (lines 47–51) |
| LAUNCH_CHECKLIST.md exists | **Pass** | All 7 sections present; **0 items checked** (see §6) |
| HealthKit entitlement | **Pass** | `Dino Step/Dino Step.entitlements` — `com.apple.developer.healthkit` true |

## 4. Release vs DEBUG UI

| Feature | Release | DEBUG |
|---------|---------|-------|
| Home: Sync Steps, progress, claim | Visible | Visible |
| Home: fake +500/+2000/+10000 steps | Hidden | Visible |
| Home: lastHealthKitSyncMessage | Visible (user sync feedback) | Visible |
| Stats: Current Run + Lifetime | Visible | Visible |
| Stats: Persistence diagnostics | Hidden | Visible |
| Stats: HealthKit technical status | Hidden | Visible |
| Stats: Apple Watch Sync + raw payload | Hidden | Visible (iOS) |
| Stats: Watch Sync Debug | Hidden | Visible (iOS) |
| Stats: Last Reward Roll | Hidden | Visible |
| Stats: Egg Testing (give/reset/clear) | Hidden | Visible (iOS) |
| Stats: Developer Testing (picker + force egg) | Hidden | Visible (iOS) |
| Stats onAppear: watchManager.activate() | Hidden (redundant) | Visible (iOS) |
| App init: PhoneWatchConnectivityManager.activate() | **Active** (required for watch sync) | Active |
| HealthKit simulator “fake steps” hint | Hidden | Visible |
| Console prints (GameState, CreatureAssetVisual, HealthKit, WC) | May log | May log |
| GameState dev methods (giveEgg, reset, etc.) | No UI exposure | Callable from Stats |

**Release leak audit result:** No fixes required. Watch connectivity activation in `Dino_StepApp.swift` is intentional production behavior, not a diagnostic panel.

## 5. Species / asset inventory

| Metric | Count | Source |
|--------|-------|--------|
| Catalog species | **29** | `CreatureCatalog.swift` |
| Asset-backed species | **29** | `CreatureAssetVisual.assetBackedSpeciesIds` |
| Placeholder / emoji only | **0** | `SPECIES_ROSTER.md` |
| iPhone baby imagesets | **29** | `Dino Step/Assets.xcassets/` |
| Watch baby imagesets | **29** | `Dino Step Watch Watch App/Assets.xcassets/` |
| iPhone PNG files | **92** | 87 dino stages + 5 egg rarities |
| Watch PNG files | **92** | Mirrored |

**Non-asset species:** None — full catalog is asset-backed (June 2026).

**Orphan/missing PNGs:** None — all 29 species have baby/juvenile/adult on phone and watch.

## 6. Launch readiness — TestFlight

- **Score:** **72%**

### Done (code / repo)
- Release DEBUG UI gating implemented and verified
- `PrivacyInfo.xcprivacy` added
- HealthKit purpose string updated (Debug + Release build settings)
- HealthKit entitlement present
- iOS + watch simulator builds succeed
- 29/29 asset-backed species PNGs in bundle
- `LAUNCH_CHECKLIST.md` and draft `docs/APP_STORE_METADATA.md`

### In progress
- Store-hardening commit committed locally, **not pushed**
- Launch checklist written but **not ticked off**

### Blockers
- **App icons empty** — iPhone + watch `AppIcon.appiconset`; 1024×1024 App Store icon not assigned
- **Privacy policy URL** — not published (external)
- **Release Archive** — not verified on device (`Product → Archive`)
- **TestFlight upload** — not done
- **Physical iPhone HealthKit QA** — not done
- **Physical Apple Watch companion QA** — not done
- **App Store Connect metadata + screenshots** — not prepared (draft metadata only)

### LAUNCH_CHECKLIST.md open items

All checklist boxes are **unchecked** `[ ]`. Substantive status:

| Section | Items in file | Code-done but unchecked | Still open |
|---------|---------------|--------------------------|------------|
| App icons | 4 | 0 | 4 (all) |
| Privacy & legal | 4 | PrivacyInfo file exists (item 3) | Privacy URL, ASC questionnaire, ongoing review |
| HealthKit | 4 | Entitlement + string in project (items 1–2, 4) | Physical device test |
| Release build quality | 6 | Gating implemented (items 1–2) | Archive, validate, TestFlight |
| Apple Watch | 3 | 0 | All 3 |
| Store metadata | 5 | 0 | All 5 |
| QA smoke test | 5 | 0 | All 5 |

## 7. Build / Archive notes

### Attempted this session

```bash
xcodebuild -scheme "Dino Step" -destination "generic/platform=iOS Simulator" build
xcodebuild -scheme "Dino Step Watch Watch App" -destination "generic/platform=watchOS Simulator" build
```

| Target | Result |
|--------|--------|
| Dino Step (iOS Simulator) | **Success** (exit 0) |
| Dino Step Watch Watch App (watchOS Simulator) | **Success** (exit 0) |

### Not attempted
- Release Archive (`Any iOS Device (arm64)`)
- Archive validation / App Store Connect upload
- Release configuration UI inspection on physical device

### Recommended at home

```bash
cd /Users/gharmon/projects/dino-step-ios
git push origin main   # after review — pushes 31f7f79

# In Xcode:
# 1. Assign AppIcon PNGs (phone + watch)
# 2. Scheme: Dino Step → Any iOS Device → Product → Archive
# 3. Validate → Distribute → TestFlight
```

## 8. Files changed this session

| File | Change |
|------|--------|
| `handoff/ios-handoff-report.md` | **Created** — this report |
| `docs/APP_STORE_METADATA.md` | **Created** — draft App Store metadata |

**No Swift or project code changes** (inspection-only; no Release leaks found).

## 9. Recommended next sprint (iOS only)

**Sprint name:** `sprint-testflight-submit`

1. **Push** `31f7f79` to `origin/main`
2. **Assign app icons** — iPhone, watch, 1024×1024 App Store marketing icon
3. **Release Archive** in Xcode; resolve icon/privacy/signing warnings
4. **Publish privacy policy URL**; complete App Store Connect privacy questionnaire
5. **Upload TestFlight** internal build
6. **Physical QA** — iPhone HealthKit sync + paired Apple Watch companion
7. **App Store metadata + screenshots** — use `docs/APP_STORE_METADATA.md` as starting point
8. **Tick off** `LAUNCH_CHECKLIST.md` as items complete

## 10. Suggested commit message

**N/A — inspection only** (handoff docs are new uncommitted files; user has not requested commit)

If committing handoff docs only:

```
Add iOS handoff report and App Store metadata draft after store hardening
```

If pushing existing store-hardening only (no new doc commit):

```
git push origin main
```

(no new commit needed — `31f7f79` already committed)

## 11. Next steps for coordinator

1. Review this report and unpushed commit `31f7f79` diff.
2. Push `main` to GitHub when ready (`git push origin main`).
3. Source or design **AppIcon PNGs** for iPhone, watch, and 1024×1024 App Store slot.
4. Publish **privacy policy URL** and add to App Store Connect + `docs/APP_STORE_METADATA.md`.
5. Run **Release Archive** on a Mac with signing credentials; fix any validation errors.
6. Upload to **TestFlight** for internal testers.
7. Execute **physical device QA** (HealthKit + Apple Watch) against `LAUNCH_CHECKLIST.md`.
8. Capture **screenshots** and finalize App Store Connect listing using metadata draft.
9. Optionally commit `handoff/ios-handoff-report.md` and `docs/APP_STORE_METADATA.md`.

---
END OF HANDOFF — dino-step-ios
