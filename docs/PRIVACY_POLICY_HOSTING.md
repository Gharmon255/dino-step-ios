# Hosting the Dino Step privacy policy (iOS App Store)

App Store Connect requires a **public HTTPS URL**. The policy text is in **`docs/privacy-policy.html`**.

## GitHub Pages (recommended)

1. Push `dino-step-ios` to GitHub (e.g. `gharmon255/dino-step-ios`).
2. Repo **Settings → Pages → Build and deployment → Source**: Deploy from branch `main`, folder **`/docs`**.
3. Your URL becomes:
   ```
   https://gharmon255.github.io/dino-step-ios/privacy-policy.html
   ```
4. That URL is set in `Dino Step Shared/LegalURLs.swift` and linked from the Stats tab.
5. Paste the same URL in **App Store Connect → App Information → Privacy Policy URL**.

### One URL for both iOS and Android?

If you prefer a single policy page, host one combined HTML (e.g. from the `dino-step` repo) and update **both**:

- Android: `app/src/main/res/values/strings.xml` → `privacy_policy_url`
- iOS: `Dino Step Shared/LegalURLs.swift` → `privacyPolicy`

## Before TestFlight / App Store

- [ ] Push `main` — GitHub Pages rebuilds from `/docs`
- [ ] Run `../dino-step/scripts/verify-privacy-url.sh` (checks both Android and iOS hosted URLs)
- [ ] Open the URL in a private browser window — loads over HTTPS
- [ ] Complete App Store privacy questionnaire using `docs/APP_STORE_PRIVACY_QUESTIONNAIRE.md`
- [ ] Add URL to `docs/APP_STORE_METADATA.md` and App Store Connect
