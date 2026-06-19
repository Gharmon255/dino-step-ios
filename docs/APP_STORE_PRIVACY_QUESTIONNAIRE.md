# App Store Connect — Privacy questionnaire (Dino Step iOS)

Use when completing **App Store Connect → App Privacy** for the iPhone app. Align with `Dino Step/PrivacyInfo.xcprivacy`.

## Tracking

**Does this app track users?** → **No**

## Data collected

| Data type | Collected | Linked to identity | Used for tracking | Purpose |
|-----------|-----------|-------------------|-------------------|---------|
| **Health & Fitness → Fitness** (step count) | Yes | No | No | App functionality |
| **Contact info → Email address** | Yes (optional) | Yes (account) | No | Account / cloud backup |
| **User content → Other user content** (game save) | Yes (optional) | Yes (account) | No | Cloud backup |

### Fitness / steps — details

- **Source:** HealthKit (Apple Health), user-initiated sync only (Sync Steps on Home)
- **Why:** Hatch eggs and grow dinosaurs from step count
- **Stored:** Game state on device; optional encrypted backup to Supabase if user signs in

### Optional cloud backup

- **Collected only when user signs in** with Apple or Google from Stats
- Game save JSON (creatures, collection, stats) — not raw step history
- Linked to account for restore across devices
- Not used for tracking or advertising

## Data NOT collected (without optional sign-in)

- Contact info, location, identifiers for advertising, purchases, browsing history, diagnostics for third-party analytics, etc.

## Privacy manifest

`Dino Step/PrivacyInfo.xcprivacy`:

- `NSPrivacyTracking` = false
- Collected type: `NSPrivacyCollectedDataTypeFitness` for `NSPrivacyCollectedDataTypePurposeAppFunctionality`
- Not linked to user, not used for tracking

## Privacy policy URL

Default (after GitHub Pages): `https://gharmon255.github.io/dino-step-ios/privacy-policy.html`

## Apple Watch app

If the watch app is bundled in the same App Store listing, the watch displays creature state received from the iPhone via WatchConnectivity — no separate HealthKit read on watch for v1.
