# TestFlight — get Stepasaurus on your iPhone (first upload)

**Status checked 2026-06-09**

| Item | Status |
|------|--------|
| Apple Developer enrollment | ✅ You received enrollment email |
| Xcode team | ✅ `5YZ54R8M4H` wired in project |
| Bundle ID (iPhone) | `com.gharmon255.Dino-Step` |
| Bundle ID (Watch) | `com.gharmon255.Dino-Step.watchkitapp` |
| HealthKit entitlement | ✅ `Dino Step.entitlements` |
| Privacy policy URL | ✅ https://gharmon255.github.io/dino-step-ios/privacy-policy.html |
| Release build | ✅ Compiles |
| Archive | ✅ `xcodebuild archive -allowProvisioningUpdates` succeeds |
| App Store Connect upload | ✅ Build **2** uploaded via `xcodebuild -exportArchive` |

---

## Fast path (recommended)

### 1. Open Xcode

```bash
open ~/projects/dino-step-ios/Dino\ Step.xcodeproj
```

### 2. Confirm signing (one time)

1. Project **Dino Step** → target **Dino Step** → **Signing & Capabilities**
2. ✅ **Automatically manage signing**
3. **Team:** your personal/company team (same as `5YZ54R8M4H`)
4. Repeat for **Dino Step Watch Watch App** and **Dino Step Watch Widgets**

**App IDs must have App Groups** enabled on [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list) for:

- `com.gharmon255.Dino-Step`
- `com.gharmon255.Dino-Step.watchkitapp`
- `com.gharmon255.Dino-Step.watchkitapp.widgets`

App Group: `group.com.gharmon255.dinostep`

If archive fails with “doesn't include the App Groups capability”, run from terminal (refreshes profiles):

```bash
./scripts/archive-for-testflight.sh
```

The script passes **`-allowProvisioningUpdates`** so Xcode can regenerate provisioning profiles.

### 3. Archive

1. Scheme: **Dino Step**
2. Destination: **Any iOS Device (arm64)** — not a simulator
3. **Product → Archive**
4. Organizer opens when done

Or from terminal (archive only):

```bash
./scripts/archive-for-testflight.sh
```

Then **Window → Organizer** → select the archive → **Distribute App**.

### 4. Upload to App Store Connect

In Organizer:

1. **Distribute App**
2. **App Store Connect** → **Upload**
3. Leave defaults (upload symbols ✅)
4. Xcode may create an **Apple Distribution** certificate — allow it
5. First upload may **create the app record** if it doesn’t exist yet

**App Store Connect app setup** (if prompted before upload works):

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps** → **+** New App
2. **Name:** Stepasaurus
3. **Bundle ID:** `com.gharmon255.Dino-Step` (register in [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) if missing)
4. **SKU:** e.g. `stepasaurus-ios-001`
5. **Privacy Policy URL:** https://gharmon255.github.io/dino-step-ios/privacy-policy.html

### 5. TestFlight

1. App Store Connect → **Stepasaurus** → **TestFlight**
2. Wait for build processing (5–30 min, sometimes longer first time)
3. **Export Compliance:** usually **No** for standard HTTPS only
4. **Internal Testing** → add your Apple ID
5. iPhone: install **TestFlight** app → open invite → install

### 6. Smoke test on your phone

- [ ] **Sync Steps** (grant Apple Health when asked)
- [ ] Grow egg → claim or **duplicate trade**
- [ ] Stats shows Apple Health card + privacy link (no debug buttons)
- [ ] Watch: open iPhone app once, check companion updates

---

## Metadata (can do after first TestFlight build)

Copy from `docs/APP_STORE_METADATA.md`:

- **Name:** Stepasaurus
- **Subtitle:** Hatch dinos with your steps
- **Category:** Health & Fitness
- **Privacy questionnaire:** `docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md`

Screenshots can wait until you’re happy with the build.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `exportArchive Error Downloading App Information` | Create app in App Store Connect + register bundle ID; upload via **Organizer** not CLI first time |
| Only “Apple Development” cert, no Distribution | Organizer → Distribute → Xcode offers to create Distribution cert |
| Archive greyed out | Select **Any iOS Device**, not simulator |
| HealthKit provisioning failed | Developer portal → Identifiers → App ID → enable HealthKit |
| Enrollment just arrived | Wait up to 24h; sign out/in of Apple ID in Xcode → Settings → Accounts |

---

## Version for each new upload

Bump in Xcode → target **Dino Step** → **General**:

- **Version** (`MARKETING_VERSION`) — user-facing, e.g. `1.0`
- **Build** (`CURRENT_PROJECT_VERSION`) — must increase every upload, e.g. `1`, `2`, `3`…

**Current repo values:** `MARKETING_VERSION` **1.0**, build **3** (build 2 rejected: duplicate watch assets exceeded 75MB watch limit).
