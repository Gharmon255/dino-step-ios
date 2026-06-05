# Dino Step — iOS / watchOS Launch Checklist

Pre–TestFlight and App Store readiness for **dino-step-ios**.  
Update checkboxes as items are completed.

---

## App icons

- [x] **iOS AppIcon complete** — `Dino Step/Assets.xcassets/AppIcon.appiconset` (`AppIcon-1024.png` from `dino-step-assets/icons/app_icon_1024.png`)
- [x] **watchOS AppIcon complete** — `Dino Step Watch Watch App/Assets.xcassets/AppIcon.appiconset` (`AppIcon-Watch-1024.png` from `app_icon_watch_1024.png`)
- [x] **1024×1024 App Store marketing icon** assigned in Xcode (iOS universal 1024 slot)
- [x] Verify icons render correctly in Xcode asset catalog before **Product → Archive** (simulator builds pass; confirm visually in Xcode before Archive)

---

## Privacy & legal

- [x] **Privacy policy text** — `docs/privacy-policy.html` (hosting: `docs/PRIVACY_POLICY_HOSTING.md`)
- [x] **In-app privacy link** — Stats tab `AppleHealthPrivacyCard` + `LegalURLs.privacyPolicy`
- [x] **App Store privacy draft answers** — `docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md`
- [ ] **Privacy policy URL** published on public HTTPS (GitHub Pages) and linked in App Store Connect
- [ ] App Store privacy questionnaire completed in App Store Connect (use draft doc above)
- [x] **PrivacyInfo.xcprivacy** present in iPhone target (`Dino Step/PrivacyInfo.xcprivacy`) — review before each release
- [ ] Confirm privacy manifest still accurate if new APIs or data collection are added

---

## HealthKit

- [ ] **NSHealthShareUsageDescription** reviewed in Xcode build settings (`INFOPLIST_KEY_NSHealthShareUsageDescription`)
- [ ] Wording states: reads step count, used to hatch/grow dinosaurs, no location
- [ ] **Physical iPhone HealthKit test** — authorize, sync steps, verify hatch/progression
- [ ] HealthKit entitlement enabled (`Dino Step.entitlements`)

---

## Release build quality

- [x] **Release configuration** hides DEBUG-only UI (fake steps, egg testing, developer picker, watch/persistence diagnostics)
- [x] Stats tab in Release shows user-facing **Apple Health** disclosure + Current Run + Lifetime (`AppleHealthPrivacyCard`)
- [ ] No debug logging required for normal users
- [ ] **Xcode Archive** succeeds (Release, Any iOS Device) — steps: `docs/ARCHIVE_AND_TESTFLIGHT.md`
- [ ] Archive validates without missing icon / privacy manifest warnings
- [ ] **TestFlight upload** to internal testers

---

## Apple Watch companion

- [ ] Watch app installs from TestFlight / paired device
- [ ] **Physical Apple Watch companion test** — sync from iPhone, egg/dino art, progress ring, milestone text not clipped
- [ ] WatchConnectivity works when iPhone app has been opened at least once

---

## Store metadata (App Store Connect)

- [ ] App name, subtitle, description
- [ ] Keywords, category, age rating
- [ ] **Screenshots** — iPhone (required sizes), Apple Watch if listing watch app
- [ ] Support URL and marketing URL (if any)
- [ ] Privacy policy URL

---

## QA smoke test (Release build)

- [ ] Fresh install → mystery egg → Sync Steps → progression through stages
- [ ] Claim reward → new egg → collection updates
- [ ] Collection sort/filter and adult PNGs for asset-backed species
- [ ] No crash when assets missing (emoji fallback)
- [ ] Watch receives updated state after iPhone changes

---

## Known deferred (not blocking code merge)

- Onboarding flow
- Automatic background HealthKit step sync
- Android parity (separate repo)

---

## Changelog

| Date | Note |
|------|------|
| 2026-06-02 | Initial launch checklist; store-hardening sprint gates DEBUG Stats UI, adds PrivacyInfo.xcprivacy |
| 2026-06-05 | App icons imported from `dino-step-assets/icons/` into iPhone + watch AppIcon.appiconset |
| 2026-06-05 | Privacy policy docs, in-app link, Apple Health Stats card, Archive/TestFlight guide |
