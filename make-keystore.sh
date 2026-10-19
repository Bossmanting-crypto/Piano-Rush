#!/usr/bin/env bash
# Creates the upload key used to sign every release of this app.
# Run once. Back up the .jks and its password before doing anything else —
# without them the app can never be updated, only republished as a new listing.
set -euo pipefail

KS="upload-keystore.jks"
ALIAS="upload"

if [ -f "$KS" ]; then
  echo "$KS already exists here. Refusing to overwrite it."
  exit 1
fi

if ! command -v keytool >/dev/null 2>&1; then
  echo "keytool not found. It ships with any JDK, and with Android Studio at:"
  echo "  macOS   /Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool"
  echo "  Windows C:\\Program Files\\Android\\Android Studio\\jbr\\bin\\keytool.exe"
  echo "  Linux   ~/android-studio/jbr/bin/keytool"
  exit 1
fi

echo "You'll be asked for a password, then for name and location details."
echo "The details are cosmetic; the password is not. Use a real one and save it."
echo

keytool -genkeypair -v \
  -keystore "$KS" \
  -alias "$ALIAS" \
  -keyalg RSA -keysize 2048 -validity 10000

mkdir -p android
mv "$KS" "android/$KS"

echo
echo "Key written to android/$KS (gitignored)."
echo
echo "Next, create android/keystore.properties with:"
echo
echo "  storeFile=$KS"
echo "  storePassword=<your password>"
echo "  keyAlias=$ALIAS"
echo "  keyPassword=<your password>"
echo
echo "For the GitHub Actions build, the KEYSTORE_BASE64 secret is:"
echo
if base64 --help 2>&1 | grep -q -- '-w'; then
  base64 -w0 "android/$KS"
else
  base64 "android/$KS" | tr -d '\n'
fi
echo
echo
echo "Back up android/$KS and the password somewhere off this machine."
