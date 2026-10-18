# Piano Rush — Android build

A Capacitor wrapper around the game. The whole game is one HTML file in `www/`,
bundled inside the app, so it works offline and needs no hosting.

```
www/index.html        the game (edit this, then `npm run sync`)
android/              the native Android project
store/                Play Console listing assets
capacitor.config.ts   app id, name, theme colour
```

| | |
|---|---|
| App name | Piano Rush |
| Package (applicationId) | `app.pianorush.game` |
| Current version | 1.0.0 (versionCode 1) |
| Min Android | 7.0 (API 24) |

**The package name is permanent** once you upload. Changing it later means a new
Play listing with zero installs and zero reviews. To change it now, edit `appId`
in `capacitor.config.ts`, then delete `android/` and run `npx cap add android`.

---

## 1. One-time setup

Install [Node.js 20+](https://nodejs.org) and
[Android Studio](https://developer.android.com/studio). In Android Studio open
**More Actions → SDK Manager** and make sure "Android SDK Platform 36" and
"Android SDK Build-Tools" are ticked.

```bash
npm install
npm run sync
```

## 2. Create your upload key — then back it up

**Lose this file or its password and you can never update the app again.** Not
"it's difficult" — it is impossible. You would have to publish a new listing.

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Answer the prompts (name, organisation, country code `KE`). You'll set a
password — use a real one and store it in a password manager.

Move `upload-keystore.jks` into `android/`, then create
`android/keystore.properties`:

```properties
storeFile=upload-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=upload
keyPassword=YOUR_KEY_PASSWORD
```

Both files are gitignored and must stay that way. Back the `.jks` up somewhere
off your laptop — a password manager attachment or an encrypted cloud folder.

When Play offers **Play App Signing** during your first upload, accept it. It is
the only safety net that exists: Google holds the real signing key and can reset
your upload key if you lose it.

## 3. Build the bundle

```bash
npm run build:aab
```

Output: `android/app/build/outputs/bundle/release/app-release.aab` — this is
what you upload.

Via Android Studio instead: `npm run open`, then **Build → Generate Signed
Bundle / APK → Android App Bundle**.

To test on your own phone first (an `.aab` can't be sideloaded):

```bash
npm run build:apk    # android/app/build/outputs/apk/debug/app-debug.apk
```

## 4. Or build in the cloud

`.github/workflows/android.yml` builds and signs the bundle on GitHub, so you
don't need Android Studio at all. Push the repo, then add four repository
secrets under **Settings → Secrets and variables → Actions**:

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | `base64 -i upload-keystore.jks` (macOS/Linux) or `base64 -w0 upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | store password |
| `KEY_ALIAS` | `upload` |
| `KEY_PASSWORD` | key password |

Run the workflow from the Actions tab and download the `.aab` artifact.

## 5. Every update after the first

`versionCode` must increase on every single upload — Play rejects a repeat.
Edit `android/app/build.gradle`:

```gradle
versionCode 2
versionName "1.0.1"
```

## 6. Play Console checklist

Before production:

- Store listing: title, short description, full description
- Icon 512×512 (`store/icon-512.png`), feature graphic 1024×500
- At least 2 phone screenshots — use 6, with the combo meter high
- Privacy policy URL (required; the game stores progress locally only)
- Data safety form
- Content rating questionnaire
- Target audience and ads declaration (the game has no ads)
- **If your developer account is personal, not organisational:** Google requires
  a closed test with 12 testers opted in for 14 continuous days before you can
  apply for production access. Start this early — it is the usual two-week delay
  on a first launch.

## 7. In-app purchases

Not wired up yet, by design. See `BILLING.md`. Short version: create three
one-time products (`pack_classics`, `pack_masters`, `pack_pop`), add a billing
plugin, and implement the server verification step. Billing does **not** work in
a debug build — you must test from a Play test track with a licence-tester
account.

## Notes on what the wrapper adds

The game stays a plain web page that still runs in a browser. The Android layer
only attaches through `window.PR`, a small bridge exposed at the bottom of
`www/index.html`:

- **Back button** pauses mid-run, backs out of sub-screens, and minimises on the
  home screen instead of killing the app.
- **Haptics** — a 12ms tick on each hit, 55ms on a miss. Respects
  `localStorage.pr_haptics = 'off'` once you build a settings screen.
- **Auto-pause** when Android backgrounds the app for a call or notification.
- Portrait lock, dark splash screen, no text selection or tap highlights.
