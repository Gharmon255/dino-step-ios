# Dino Step — iOS / watchOS Watch Sync Contract

This document describes how game state is sent from the iPhone app to the Apple Watch companion app via **WatchConnectivity** (`updateApplicationContext` + optional `sendMessage`).

## Transport

| Item | Value |
|------|--------|
| Context key | `watchGameStatePayload` |
| Format | JSON string (UTF-8) in application context dictionary |
| Encoder | `JSONEncoder` on `WatchGameStatePayload` |
| Source of truth | iPhone `GameState` (watch is read-only) |

Phone: `PhoneWatchConnectivityManager.send(payload:)`  
Watch: `WatchConnectivityReceiver` decodes via `WatchGameStatePayload.decode(from:)`

## Payload fields

| Field | Type | Meaning |
|-------|------|---------|
| `displayName` | String | UI title (mystery egg name or hatched creature name) |
| `creatureName` | String | Catalog display name (e.g. `T-Rex`, `Pteranodon`) |
| `speciesId` | String? | Canonical species slug (e.g. `trex`, `pteranodon`). **Optional** for backward compatibility. |
| `stage` | String | `EGG`, `BABY`, `JUVENILE`, or `ADULT` |
| `rarity` | String | Egg rarity: `COMMON` … `LEGENDARY` |
| `currentSteps` | Int | Steps applied to the active creature |
| `nextMilestone` | Int | Next step threshold (hatch / juvenile / adult) |
| `totalStepsRequired` | Int | Steps to reach adult |
| `progressPercent` | Double | **Lifetime** progress toward fully grown (0–100) |
| `stageProgressPercent` | Double | **Current stage** progress toward next stage (0–100) |
| `stepsUntilNextStage` | Int | Steps remaining until next stage |
| `nextStageLabel` | String | Short label: `hatch`, `juvenile`, `adult`, `claim` |
| `isRevealed` | Bool | Whether the creature identity is revealed (post-hatch) |
| `placeholderVisual` | String | Emoji fallback for watch center when no PNG |
| `updatedAt` | Date | ISO-encoded sync timestamp |

### Computed (watch-side, not in JSON)

| Property | Rule |
|----------|------|
| `ringProgressPercent` | Clamped `stageProgressPercent` (0–100) — **used for the watch ring** |
| `resolvedSpeciesIdForAssets` | `speciesId` if present, else normalize `creatureName` via `CreatureAssetVisual` |
| `milestoneText` | Human-readable “X to hatch/juvenile/adult” or “Ready to claim” |

## Stage progress semantics (watch ring)

**The watch progress ring shows progress toward the *next* stage, not total lifetime progress.**

| Field | Used for ring? |
|-------|----------------|
| `stageProgressPercent` | **Yes** (via `ringProgressPercent`) |
| `progressPercent` | No (lifetime / fully grown only; shown in DEBUG on iPhone) |

iPhone computes `stageProgressPercent` in `GameLogic.stageProgressPercent` per stage segment (egg→hatch, baby→juvenile, juvenile→adult).

## Species ID rule

Canonical asset-backed species IDs (Sprint 1 catalog):

- `tiny_raptor`, `triceratops`, `trex`, `stegosaurus`, `brachiosaurus`
- `ankylosaurus`, `parasaurolophus`, `spinosaurus`, `pteranodon`

**Asset naming pattern (Sprint 2):**

```
dino_{speciesId}_{stage}
```

Where `stage` is `baby`, `juvenile`, or `adult` (from `BABY` / `JUVENILE` / `ADULT`).

Phone sends `speciesId` from `CreatureDefinition.speciesId` when building the payload.

## Fallback behavior

| Condition | Watch behavior |
|-----------|----------------|
| Missing `speciesId` in payload | Resolve assets using `creatureName` + legacy aliases (`Pterodactyl` → `pteranodon`, etc.) |
| Unknown / non-asset-backed species | Show `placeholderVisual` emoji |
| Missing PNG in asset catalog | Show `placeholderVisual` emoji (no crash) |
| Unknown `stage` | No dino PNG; emoji fallback |
| Egg stage (`EGG`) | Use `RarityEggVisual` / egg PNGs by rarity |
| Legacy JSON (no `stageProgressPercent`) | Decode via `decodeLegacyPayload`; ring uses `progressPercent` as fallback |
| Empty strings | Treated as missing; safe emoji fallback |

## Backward compatibility

1. **Legacy payloads** without `speciesId`: decode succeeds; `speciesId` is `nil`; watch uses `creatureName` for asset lookup.
2. **Legacy payloads** without `stageProgressPercent`: `stageProgressPercent` defaults to `progressPercent` during legacy decode.
3. New iPhone builds always send `speciesId` when syncing.

## Simulator testing notes

- Build and run **Dino Step** (iOS) and **Dino Step Watch Watch App** in Xcode simulators.
- Pair iPhone + Watch simulators in the same session when testing WC.
- Use **Stats → Egg Testing** (DEBUG) to force species or roll rarity eggs; each action calls `persistCurrentState()` → watch sync.
- **Stats → Apple Watch Sync** shows session status and last outbound payload fields.
- **Stats → Watch Sync Debug** (DEBUG only) shows active iPhone state vs ring progress.
- WatchConnectivity may report “not paired” or “not reachable” in Simulator; context updates can still work when simulators are paired.
- **Do not require** real HealthKit steps or physical devices for this contract.

## Real-device testing (later)

Still recommended on physical iPhone + Apple Watch:

- Verify `updateApplicationContext` delivery when watch app is backgrounded
- Verify reachability / `sendMessage` path
- Confirm PNG assets render at watch resolution
- End-to-end progression after claim reward and dev force-egg flows

## Related files

| File | Role |
|------|------|
| `Dino Step Shared/WatchGameStatePayload.swift` | Payload model + decode |
| `Dino Step/Watch/WatchGameStatePayloadBuilder.swift` | iPhone → payload |
| `Dino Step/Watch/PhoneWatchConnectivityManager.swift` | Send + debug last payload |
| `Dino Step Watch Watch App/WatchConnectivityReceiver.swift` | Receive + decode |
| `Dino Step Watch Watch App/WatchProgressRingView.swift` | Ring + center visual |
| `Dino Step Shared/CreatureAssetVisual.swift` | `dino_{speciesId}_{stage}` resolver |
