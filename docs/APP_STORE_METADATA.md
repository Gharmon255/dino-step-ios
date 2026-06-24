# Stepasaurus — App Store Connect Metadata (Draft)

Draft for **dino-step-ios** TestFlight / App Store submission.  
Review and edit before pasting into App Store Connect.

---

## App name

**Stepasaurus**

## Subtitle (30 characters max)

**Hatch dinos with your steps**

## Promotional text (optional, 170 characters)

Walk to sync steps from Apple Health, hatch mystery eggs, and grow dinosaurs from baby to adult. Collect species across rarity tiers and track your Dino Dex progress.

## Description

Stepasaurus turns your daily steps into a dinosaur adventure.

Start with a mystery egg and sync your step count from Apple Health. As you walk, your egg hatches and your dinosaur grows through baby, juvenile, and adult stages. Claim your fully grown dinosaur to add it to your collection, then start a new egg and discover another species.

**Features**
- Step-powered hatching and growth — your real steps drive progress
- Mystery eggs with rarity tiers from Common to Legendary
- Collection and Dino Dex — track species you've discovered
- Apple Watch companion — see your egg or dinosaur and stage progress on your wrist

Stepasaurus reads step count data from Apple Health to provide app functionality. Optional Sign in with Apple or Google can back up your game save across devices; steps are never uploaded. Location data is not used.

Privacy policy: https://gharmon255.github.io/dino-step-ios/privacy-policy.html *(host `docs/privacy-policy.html` via GitHub Pages — see `docs/PRIVACY_POLICY_HOSTING.md`)*

## Keywords (100 characters max, comma-separated)

dinosaur,steps,walking,health,fitness,egg,hatch,collection,pets,watch

## Category

- **Primary:** Health & Fitness
- **Secondary:** Games (optional — confirm with product owner)

## Age rating

Expected: **4+** (no restricted content; confirm via App Store Connect questionnaire)

## Support URL

mailto:stepasaurushelp@gmail.com

## Marketing URL (optional)

*[Optional — leave blank for v1]*

## Privacy policy URL

https://gharmon255.github.io/dino-step-ios/privacy-policy.html

Host steps: `docs/PRIVACY_POLICY_HOSTING.md`

---

## Screenshots needed

### iPhone (required)

Capture on supported device sizes per App Store Connect. Preset states and IG captures live in **`marketing/screenshot-states/`** and **`marketing/screenshots/`** — resize/re-export for ASC-required dimensions.

| Screen | Suggested content |
|--------|-------------------|
| Home — egg stage | Mystery egg, Sync Steps, stage progress |
| Home — hatched | Baby/juvenile/adult creature with PNG art |
| Collection | Grid with discovered species + Dino Dex summary |
| Stats | Current Run + Lifetime (Release build — no dev panels) |
| Watch (optional in iPhone set) | Companion app on wrist if showcasing watch app |

### Apple Watch (if listing watch app)

| Screen | Suggested content |
|--------|-------------------|
| Egg / creature view | Progress ring + milestone text |
| Stage progress | Juvenile or adult with ring percentage |

---

## App Store privacy questionnaire (notes)

Full answers: **`docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md`**

- **Data collected:** Fitness (step count via HealthKit, manual + ~hourly background); optional Email + game save + battle history when signed in
- **Linked to user:** Fitness — No; Email / game save — Yes (only when signed in)
- **Used for tracking:** No
- **Purpose:** App functionality

---

## Version / copyright (placeholder)

- **Version:** 1.0 (build **10** — bump before next TestFlight upload; current repo build **9**)
- **Copyright:** © 2026 [Your name or company]

---

*Draft created during store-hardening handoff (June 2026). Not submitted.*
