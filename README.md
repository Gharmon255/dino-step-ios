# Dino Step (iOS / watchOS)

Dino Step is a step-based dinosaur pet and collection game. Walk to earn progress on a mystery egg, hatch a creature, grow it from baby → juvenile → adult, then claim and collect species across rarity tiers.

## Platform

- **iPhone app** — `Dino Step/`
- **Apple Watch companion** — `Dino Step Watch Watch App/` (read-only UI synced from the phone)
- **Shared code** — `Dino Step Shared/` (asset naming, watch payload, visuals)

Open **`Dino Step.xcodeproj`** in Xcode.

## Core gameplay loop

1. Receive a **mystery egg** (rarity: Common → Legendary).
2. **Walk steps** (HealthKit on device; DEBUG builds can add fake steps on Home).
3. **Hatch** when step threshold is reached.
4. Grow **baby → juvenile → adult** with additional steps per stage.
5. **Claim** the adult to add the species to your **collection**.
6. Eggs roll **egg rarity**; the species inside uses its own **creature rarity** from the catalog.

## Species and art status

See [`SPECIES_ROSTER.md`](SPECIES_ROSTER.md) for the full roster.

| | Count |
|---|------|
| Catalog species | **29** |
| Asset-backed (PNG art) | **29** |
| Placeholder / emoji only | **0** |

**Source assets** live in the sibling repo **`dino-step-assets`** (`dinos/` folder). Import into this project after art is ready.

**Naming pattern** (imagesets in `Assets.xcassets`):

- `dino_{speciesId}_baby`
- `dino_{speciesId}_juvenile`
- `dino_{speciesId}_adult`

Non-backed species use emoji fallbacks only — never another species’ `dino_*` images.

## Project layout

| Path | Purpose |
|------|---------|
| `Dino Step/Game/CreatureCatalog.swift` | Species definitions (canonical catalog) |
| `Dino Step Shared/CreatureAssetVisual.swift` | Asset-backed species list + resolver |
| `Dino Step/Assets.xcassets/` | iPhone imagesets + egg art |
| `Dino Step Watch Watch App/Assets.xcassets/` | Watch imagesets (mirror phone dino + eggs) |
| `Dino Step/Views/` | Home, Collection, Stats (incl. DEBUG tools) |

**Docs**

- [`SPECIES_ROSTER.md`](SPECIES_ROSTER.md) — ids, rarities, steps, asset status
- [`SPECIES_ONBOARDING_CHECKLIST.md`](SPECIES_ONBOARDING_CHECKLIST.md) — add a new asset-backed species
- [`WATCH_SYNC_CONTRACT.md`](WATCH_SYNC_CONTRACT.md) — phone → watch payload
- [`docs/CLOUD_SAVE_CONTRACT.md`](../dino-step/docs/CLOUD_SAVE_CONTRACT.md) — cloud save JSON schema (canonical copy in Android repo)
- [`docs/SUPABASE_SETUP.md`](../dino-step/docs/SUPABASE_SETUP.md) — Supabase auth + Apple JWT setup (canonical copy in Android repo)
- [`docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md`](docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md) — App Store Connect privacy answers
- [`LAUNCH_CHECKLIST.md`](LAUNCH_CHECKLIST.md) — TestFlight / App Store readiness

## Developer testing (DEBUG only)

In **Debug** builds only (`#if DEBUG`):

- **Stats** tab — egg testing: random egg, per-rarity eggs, reset game, clear collection
- **Stats** tab — **Force Selected Species Egg** with species picker (29 asset-backed ids)
- **Home** — fake step buttons (+500 / +2000 / +10000)
- **Stats** — watch sync debug readout

These controls must **not** ship in Release; production users rely on real steps and normal egg rolls.

## Asset workflow

1. Create or clean PNGs in **`dino-step-assets/dinos/`** (see `dino-step-assets/ADD_SPECIES_CHECKLIST.md` and `species_queue.md`).
2. Validate: **RGBA**, **1024×1024**, alpha **0–255**, hidden RGB cleared under transparency.
3. Add imagesets to **`Dino Step/Assets.xcassets`** and **`Dino Step Watch Watch App/Assets.xcassets`**.
4. Update **`CreatureCatalog.swift`**, **`CreatureAssetVisual.assetBackedSpeciesIds`**, DEBUG picker in **`StatsView.swift`**, and **`SPECIES_ROSTER.md`** (both app repos).
5. Build, test on simulator (Home stages + Collection adult card + Watch), then commit.

## Build and run

1. Open `Dino Step.xcodeproj` in Xcode.
2. Select the **Dino Step** scheme → run on an **iPhone simulator** (no physical iPhone required).
3. For Watch: select **Dino Step Watch Watch App** scheme → run on a **watchOS simulator** paired with the phone simulator.
4. Use a **Debug** configuration to access developer testing UI.

Physical iPhone / Apple Watch testing is recommended before release but not required for day-to-day simulator work.

## Cloud backup (optional)

Game progress is **local-first**. Optional **Sign in with Apple** or **Google** backs up your save to Supabase for restore on another device.

- **Stats tab** → **Account & backup** — export local save anytime; sign-in when enabled
- **Tester builds:** sign-in is gated behind **Coming soon** (`CloudBackupFeatures.signInEnabled = false` in `AccountBackupCard.swift`). Flip to `true` locally for dev testing only.
- **Setup:** copy `Dino Step/Config/SupabaseConfig.example.plist` → `SupabaseConfig.plist` (gitignored); see [`docs/SUPABASE_SETUP.md`](../dino-step/docs/SUPABASE_SETUP.md) in the Android repo for Supabase + Apple JWT steps
- **Privacy:** [`docs/privacy-policy.html`](docs/privacy-policy.html), [`docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md`](docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md)

Steps and raw HealthKit data are **not** uploaded — only game save JSON when the user signs in.

## Repo notes

- Do **not** commit `*.xcuserstate`, `xcuserdata/`, or `DerivedData/` (see `.gitignore`).
- Push via **GitHub**; keep roster docs in sync with `dino-step` when catalog or art changes.
- **`dino-step-assets`** is the source-of-truth workspace for PNGs before import.

## Known limitations / next work

- Catalog art is **complete** (29/29 species, all stages). See `dino-step-assets/species_queue.md` for expansion notes.
- UI polish and on-device HealthKit / WatchConnectivity validation on real hardware.
- Watch is read-only; all progression happens on the phone.
- Cloud sign-in UI gated for testers; cloud push not yet hooked to every save path.
- Apple and Google sign-in create separate Supabase users (no account linking yet).
