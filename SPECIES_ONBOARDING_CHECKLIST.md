# Dino Step — Species Onboarding Checklist (iOS / watchOS)

Use this checklist when adding a **new asset-backed dinosaur** to the Dino Step iOS and watchOS apps.

## Current asset-backed species (reference)

| speciesId | Display name | Rarity |
|-----------|--------------|--------|
| `tiny_raptor` | Tiny Raptor | Common |
| `triceratops` | Triceratops | Common |
| `ankylosaurus` | Ankylosaurus | Common |
| `parasaurolophus` | Parasaurolophus | Common |
| `stegosaurus` | Stegosaurus | Uncommon |
| `pteranodon` | Pteranodon | Uncommon |
| `brachiosaurus` | Brachiosaurus | Uncommon |
| `trex` | T-Rex | Rare |
| `spinosaurus` | Spinosaurus | Rare |
| `pteranodon` | Pteranodon | Uncommon |
| `dilophosaurus` | Dilophosaurus | Uncommon |
| `carnotaurus` | Carnotaurus | Uncommon |
| `mosasaurus` | Mosasaurus | Rare |
| `pachycephalosaurus` | Pachycephalosaurus | Common |
| `allosaurus` | Allosaurus | Rare |
| `iguanodon` | Iguanodon | Uncommon |

---

## 1. Art preparation

- [ ] Generate or clean source PNGs (baby, juvenile, adult)
- [ ] Export as **RGBA**, **1024×1024** (or consistent size with existing dinos)
- [ ] Alpha channel **0–255**; clear hidden RGB under transparent pixels
- [ ] Visual review: no stray pixels, consistent scale/padding vs existing species

## 2. Xcode asset catalog (iPhone)

Add to `Dino Step/Assets.xcassets/` with **exact** imageset names:

- [ ] `dino_{speciesId}_baby`
- [ ] `dino_{speciesId}_juvenile`
- [ ] `dino_{speciesId}_adult`

Example for a new species `dilophosaurus` (when ready):

```
dino_dilophosaurus_baby
dino_dilophosaurus_juvenile
dino_dilophosaurus_adult
```

## 3. Xcode asset catalog (Apple Watch)

Copy the same three imagesets into:

- [ ] `Dino Step Watch Watch App/Assets.xcassets/`

Watch uses the same naming pattern via `CreatureAssetVisual` (`dino_{speciesId}_{stage}`).

## 4. Creature catalog (Sprint 1)

Edit `Dino Step/Game/CreatureCatalog.swift`:

- [ ] Add `CreatureDefinition` with stable **`speciesId`** slug (e.g. `new_species`)
- [ ] Set display **name**, **rarity**, **habitat**, step thresholds
- [ ] Use a **new catalog index** / UUID — do not reuse an existing creature’s UUID (preserves saves)

## 5. Asset-backed registry (Sprint 2)

Edit `Dino Step Shared/CreatureAssetVisual.swift`:

- [ ] Add `speciesId` to `assetBackedSpeciesIds`
- [ ] Add legacy aliases in `speciesIdAliases` only if needed (e.g. old display names)

No per-species switch statements — naming is automatic: `dino_{speciesId}_{stage}`.

## 6. Visual identity (placeholder fallback)

Edit `Dino Step/Theme/CreatureVisuals.swift`:

- [ ] Add profile entry for display name (emoji + colors) so non-asset stages still look correct

## 7. Developer testing picker (optional)

Edit `Dino Step/Views/StatsView.swift` (DEBUG section):

- [ ] Add picker option with tag = **`speciesId`** (not display name)
- [ ] Confirm **Force Selected Species Egg** hatches that species only

## 8. Collection (Sprint 5)

- [ ] Open **Collection** tab — species appears in roster (locked until completed)
- [ ] After claiming adult: card shows **Discovered**, adult PNG via `dino_{speciesId}_adult`
- [ ] If PNG missing: card shows **that species’ emoji** fallback (never another dino’s art)
- [ ] Locked card shows lock styling only (no species art)

## 9. Phone stage display

- [ ] Home card: egg → baby → juvenile → adult uses correct PNGs per stage
- [ ] Missing asset → emoji fallback for **that** creature only

## 10. Watch sync & display (Sprint 4)

- [ ] iPhone sends `speciesId` in `WatchGameStatePayload`
- [ ] Watch ring center shows hatched PNG or safe emoji fallback
- [ ] Egg stage still uses rarity egg assets

See `WATCH_SYNC_CONTRACT.md` for payload details.

## 11. Simulator test checklist

No physical device required for basic verification:

- [ ] Build **Dino Step** (iOS Simulator)
- [ ] Build **Dino Step Watch Watch App** (watchOS Simulator)
- [ ] Stats → Force Selected Species Egg → verify Home stages
- [ ] Claim adult → verify Collection card (adult art)
- [ ] Stats → Give Random Egg by Rarity → still random (override not applied)
- [ ] Watch simulator shows synced creature (when simulators are paired)

## 12. Commit message example

```
Add {Display Name} asset-backed species to iOS and watch

Add catalog entry, asset catalog images, asset-backed registry entry,
and verify collection/home/watch rendering for {speciesId}.
```

---

## Quick file reference

| Area | File |
|------|------|
| Catalog | `Dino Step/Game/CreatureCatalog.swift` |
| Asset resolver | `Dino Step Shared/CreatureAssetVisual.swift` |
| Stage / collection visuals | `Dino Step/Views/CreatureStageVisualView.swift` |
| Collection sort/cards | `Dino Step/Game/CollectionCatalog.swift`, `CollectionSpeciesCard.swift` |
| Dev picker | `Dino Step/Views/StatsView.swift` |
| Watch payload | `Dino Step Shared/WatchGameStatePayload.swift` |
| Watch sync docs | `WATCH_SYNC_CONTRACT.md` |
