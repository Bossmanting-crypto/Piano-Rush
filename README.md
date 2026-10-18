# Piano Rush — Android build

Capacitor wrapper around the game. The whole game is one HTML file in `www/`,
bundled into the app, so it runs offline and needs no hosting.

```
www/index.html        the game (edit this, then npm run sync)
android/              native Android project
store/                Play listing assets
capacitor.config.ts   app id, name, theme colour
```

| | |
|---|---|
| App name | Piano Rush |
| applicationId | `app.pianorush.game` |
| Version | 1.0.0 (versionCode 1) |
| Min Android | 7.0 (API 24) |

The applicationId is permanent once uploaded. To change it now: edit `appId` in
`capacitor.config.ts`, delete `android/`, run `npx cap add android`.

## Setup

Needs Node 20+ and Android Studio with SDK Platform 36 and Build-Tools
installed.

```bash
npm install
npm run sync
```

## Signing key

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Move the `.jks` into `android/` and create `android/keystore.properties`:

```properties
storeFile=upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Both are gitignored. Back the keystore up off this machine — if it's lost the
app can't be updated, only republished as a new listing. Accept Play App
Signing on first upload so Google can reset the upload key if that happens.

## Build

```bash
npm run build:aab    # android/app/build/outputs/bundle/release/app-release.aab
npm run build:apk    # debug APK for sideloading to a test device
```

Android Studio equivalent: `npm run open`, then Build → Generate Signed Bundle
/ APK → Android App Bundle.

An `.aab` can't be sideloaded; use the debug APK for on-device testing.

## CI build

`.github/workflows/android.yml` builds and signs on GitHub. Add four
repository secrets:

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | store password |
| `KEY_ALIAS` | `upload` |
| `KEY_PASSWORD` | key password |

Run from the Actions tab, download the `.aab` artifact.

## Updates

`versionCode` must increase on every upload. In `android/app/build.gradle`:

```gradle
versionCode 2
versionName "1.0.1"
```

## Play Console

- Listing: title, short and full description
- Icon 512×512 (`store/icon-512.png`), feature graphic 1024×500
- 2+ phone screenshots
- Privacy policy URL (progress is stored locally only)
- Data safety form, content rating, target audience, ads declaration (no ads)
- Personal developer accounts need a closed test with 12 testers for 14
  continuous days before applying for production

## In-app purchases

Not wired up. See `BILLING.md`. Three one-time products
(`pack_classics`, `pack_masters`, `pack_pop`), a billing plugin, and
server-side verification. Billing only works from a Play test track, not a
debug build.

## What the wrapper adds

The game stays a plain web page and still runs in a browser. The native layer
attaches through `window.PR`, defined at the bottom of `www/index.html`:

- back button pauses mid-run, backs out of sub-screens, minimises on home
- haptics: 12ms on hit, 55ms on miss, off via `localStorage.pr_haptics='off'`
- auto-pause when Android backgrounds the app
- portrait lock, dark splash, no text selection or tap highlights
