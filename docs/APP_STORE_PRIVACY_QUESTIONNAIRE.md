# App Store Connect — Privacy questionnaire (Dino Step iOS)

Use when completing **App Store Connect → App Privacy** for the iPhone app. Align with `Dino Step/PrivacyInfo.xcprivacy` and `docs/privacy-policy.html`.

## Tracking

**Does this app track users?** → **No**

## Data collected

| Data type | Collected | Linked to identity | Used for tracking | Purpose |
|-----------|-----------|-------------------|-------------------|---------|
| **Health & Fitness → Fitness** (step count) | Yes | No | No | App functionality |
| **Contact info → Email address** | Yes (optional) | Yes (account) | No | Account / cloud backup / battles |
| **User content → Other user content** (game save) | Yes (optional) | Yes (account) | No | Cloud backup |

### Fitness / steps — details

- **Source:** HealthKit (Apple Health) — user taps **Sync Steps** on Home and/or about **once per hour** via HealthKit background delivery when permission is granted
- **Why:** Hatch eggs and grow dinosaurs from step count
- **Stored:** Game state on device; optional encrypted backup to Supabase if user signs in
- **Uploaded:** Raw step history is **not** uploaded

### Optional cloud backup

- **Collected only when user signs in** with Apple or Google from Stats
- Game save JSON (creatures, collection, stats) — not raw step history
- Linked to account for restore across devices
- Not used for tracking or advertising

**Sign-in in production builds:** `CloudBackupFeatures.signInEnabled = true` in `AccountBackupCard.swift`. Requires `SupabaseConfig.plist` at build time.

**Optional PvP:** when signed in and using Battle, match outcomes and species picks are stored on Supabase for battle history. No HealthKit step data is sent for combat.

### Notifications

Local notifications only (stage milestones, step-goal reminders). Generated on-device; not a separate App Privacy data type.

## Data NOT collected (without optional sign-in)

- Location, identifiers for advertising, purchases, browsing history, diagnostics for third-party analytics, etc.

## Privacy manifest

`Dino Step/PrivacyInfo.xcprivacy`:

- `NSPrivacyTracking` = false
- Collected types:
  - `NSPrivacyCollectedDataTypeFitness` — not linked, not used for tracking (HealthKit steps)
  - `NSPrivacyCollectedDataTypeEmailAddress` — linked when user signs in
  - `NSPrivacyCollectedDataTypeOtherUserContent` — game save JSON when signed in; linked to account

## Privacy policy URL

`https://gharmon255.github.io/dino-step-ios/privacy-policy.html`

Push updates to `docs/privacy-policy.html` on `main` and confirm GitHub Pages reflects the new text.

## Apple Watch app

The watch app displays creature state received from the iPhone via WatchConnectivity — no separate HealthKit read on watch for v1.

## Support contact

`stepasaurushelp@gmail.com`
