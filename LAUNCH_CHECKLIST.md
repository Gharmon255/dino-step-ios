# Dino Step — iOS / watchOS Launch Checklist

Pre–TestFlight and App Store readiness for **dino-step-ios**.  
Update checkboxes as items are completed.

---

## App icons

- [ ] **iOS AppIcon complete** — `Dino Step/Assets.xcassets/AppIcon.appiconset` (currently missing image files; slots defined only)
- [ ] **watchOS AppIcon complete** — `Dino Step Watch Watch App/Assets.xcassets/AppIcon.appiconset`
- [ ] **1024×1024 App Store marketing icon** assigned in Xcode
- [ ] Verify icons render correctly in Xcode asset catalog before **Product → Archive**

---

## Privacy & legal

- [ ] **Privacy policy URL** published and linked in App Store Connect
- [ ] App Store privacy questionnaire matches actual behavior (HealthKit step count, no tracking)
- [ ] **PrivacyInfo.xcprivacy** present in iPhone target (`Dino Step/PrivacyInfo.xcprivacy`) — review before each release
- [ ] Confirm privacy manifest still accurate if new APIs or data collection are added

---

## HealthKit

- [ ] **NSHealthShareUsageDescription** reviewed in Xcode build settings (`INFOPLIST_KEY_NSHealthShareUsageDescription`)
- [ ] Wording states: reads step count, used to hatch/grow dinosaurs, no location
- [ ] **Physical iPhone HealthKit test** — authorize, sync steps, verify hatch/progression
- [ ] HealthKit entitlement enabled (`Dino Step.entitlements`)

---

## Release build quality

- [ ] **Release configuration** hides DEBUG-only UI (fake steps, egg testing, developer picker, watch/persistence diagnostics)
- [ ] Stats tab in Release shows user-facing run/lifetime stats only
- [ ] No debug logging required for normal users
- [ ] **Xcode Archive** succeeds (Release, Any iOS Device)
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
