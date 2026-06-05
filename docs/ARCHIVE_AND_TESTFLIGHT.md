# Archive and TestFlight (do at home with Mac + Xcode)

Step-by-step for **internal TestFlight** when you have your Apple Developer account and a physical iPhone (Watch optional).

## Prerequisites

- [ ] Apple Developer Program membership (paid)
- [ ] Xcode signed in with your Apple ID (**Xcode → Settings → Accounts**)
- [ ] Privacy policy hosted (see `docs/PRIVACY_POLICY_HOSTING.md`)
- [ ] Bundle ID registered in [Developer Portal](https://developer.apple.com/account) matching Xcode

## 1. Open project

```bash
open ~/projects/dino-step-ios/Dino\ Step.xcodeproj
```

## 2. Signing (iPhone target)

1. Select project **Dino Step** in navigator → target **Dino Step**
2. **Signing & Capabilities**
3. Enable **Automatically manage signing**
4. Team: your developer team
5. Confirm **HealthKit** capability is present (`Dino Step.entitlements`)

Repeat for **Dino Step Watch Watch App** target (same team).

## 3. Release scheme

1. Scheme: **Dino Step**
2. Destination: **Any iOS Device (arm64)** — not a simulator

## 4. Archive

1. **Product → Archive**
2. Wait for Organizer to open
3. **Validate App** — fix any icon, signing, or privacy manifest warnings
4. **Distribute App → App Store Connect → Upload**
5. Enable **Upload your app’s symbols** if offered

First upload creates the app record in App Store Connect if it does not exist yet.

## 5. TestFlight

1. [App Store Connect](https://appstoreconnect.apple.com) → **My Apps → Dino Step → TestFlight**
2. Wait for build processing (often 5–30 minutes)
3. Answer **Export Compliance** if prompted (typically no encryption beyond HTTPS → exempt)
4. Add **Internal Testing** group and your Apple ID as tester
5. Install **TestFlight** on iPhone → accept invite → install build

## 6. Physical QA (Release via TestFlight)

- [ ] Fresh install → mystery egg → **Sync Steps** → progression
- [ ] Stats tab shows **Apple Health** card + **Privacy Policy** link (no dev panels)
- [ ] Claim reward → collection updates
- [ ] Paired Apple Watch shows synced creature (open iPhone app once first)

## 7. App Store Connect metadata

Paste draft copy from `docs/APP_STORE_METADATA.md` (update privacy URL and support email).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| No signing certificate | Xcode → Settings → Accounts → Manage Certificates → + Apple Development |
| HealthKit entitlement error | Enable HealthKit on App ID in Developer Portal |
| Archive greyed out | Select **Any iOS Device**, not simulator |
| Watch app missing on wrist | Install iPhone build from TestFlight first; watch app embeds with iOS app |

## Command-line build (optional sanity check)

```bash
cd ~/projects/dino-step-ios
xcodebuild -scheme "Dino Step" \
  -destination "generic/platform=iOS Simulator" \
  -configuration Release \
  build
```

Simulator Release build does not replace Archive for TestFlight but catches compile errors.
