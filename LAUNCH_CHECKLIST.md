# Dino Step — iOS / watchOS Launch Checklist

Pre–TestFlight and App Store readiness for **dino-step-ios**.  
Update checkboxes as items are completed.

**Code/doc sync:** June 2026 — privacy policy, ASC privacy draft, in-app disclosures, and sign-in flags aligned for production.

---

## Still manual (App Store Connect — you)

- [ ] Push `main` to GitHub so **GitHub Pages** serves updated `docs/privacy-policy.html`
- [ ] App Store Connect → privacy policy URL + **App Privacy** questionnaire (`docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md`)
- [ ] Bump **build number** to 10+ → Archive → TestFlight external
- [ ] Store listing metadata + ASC-sized screenshots (source: `marketing/`)
- [ ] Physical release smoke test (checklist below)

---

## App icons

- [x] **iOS AppIcon complete** — `Dino Step/Assets.xcassets/AppIcon.appiconset` (`AppIcon-1024.png` from `dino-step-assets/icons/app_icon_1024.png`)
- [x] **watchOS AppIcon complete** — `Dino Step Watch Watch App/Assets.xcassets/AppIcon.appiconset` (`AppIcon-Watch-1024.png` from `app_icon_watch_1024.png`)
- [x] **1024×1024 App Store marketing icon** assigned in Xcode (iOS universal 1024 slot)
- [x] Verify icons render correctly in Xcode asset catalog before **Product → Archive** (simulator builds pass; confirm visually in Xcode before Archive)

---

## Privacy & legal

- [x] **Privacy policy text** — `docs/privacy-policy.html` (cloud backup, PvP, hourly sync, notifications)
- [x] **In-app privacy link** — Stats tab `AppleHealthPrivacyCard` + `LegalURLs.privacyPolicy`
- [x] **App Store privacy draft answers** — `docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md`
- [ ] **Privacy policy URL** on GitHub Pages matches repo (push `main`, verify in browser)
- [ ] App Store privacy questionnaire completed in App Store Connect
- [x] **PrivacyInfo.xcprivacy** present in iPhone target — Fitness + optional Email / game save
- [x] **Cloud backup privacy** — optional account section in policy + questionnaire
- [x] **PvP privacy note** — optional battle history when signed in
- [x] Cloud sign-in enabled in code (`CloudBackupFeatures.signInEnabled = true`)
- [ ] Verify PvP backend deployed on Supabase prod project

---

## HealthKit

- [x] **NSHealthShareUsageDescription** reviewed in Xcode build settings
- [x] **NSHealthUpdateUsageDescription** added — required for HealthKit entitlement
- [x] Wording: reads step count, manual + ~hourly background sync, no location
- [ ] **Physical iPhone HealthKit test** — authorize, sync steps, verify hatch/progression
- [x] HealthKit entitlement enabled (`Dino Step.entitlements`)

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

## Cloud backup & battles (optional)

- [x] Local-first save + optional Supabase sync (Stats **Account & backup** card)
- [x] Export local save; Sign in with Apple + Google wired (Supabase)
- [x] Sign-in enabled in code (`CloudBackupFeatures.signInEnabled = true`); requires `SupabaseConfig.plist`
- [ ] Verify cloud push on release build after HealthKit sync
- [ ] Supabase prod: Apple/Google OAuth + PvP migrations + `battle` function deployed

---

## Known deferred (not blocking v1.0 store submission)

- ASC screenshot export at required sizes (source assets in `marketing/`)
- Async PvP (see `dino-step/docs/PVP_DESIGN.md`)
- CI / GitHub Actions for `scripts/run-tests.sh`

---

## Changelog

| Date | Note |
|------|------|
| 2026-06-06 | Privacy/sync disclosure aligned; ASC privacy draft updated; sign-in prod flags documented |
| 2026-06-05 | Privacy policy docs, in-app link, Apple Health Stats card, Archive/TestFlight guide |
| 2026-06-02 | Initial launch checklist; store-hardening sprint gates DEBUG Stats UI, adds PrivacyInfo.xcprivacy |
