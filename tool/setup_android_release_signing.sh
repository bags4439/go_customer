#!/usr/bin/env bash
# Generates android/upload-keystore.jks and android/key.properties for Play Store release builds.
#
# Back up both files securely — you need the same keystore for every future app update.
#
# After running, register the printed SHA-1 and SHA-256 in:
#   Firebase Console → Project settings → Your apps → Android → Add fingerprint
#   GCP Console → APIs & Services → Credentials → Android key restrictions

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/android"
KEYSTORE="$ANDROID_DIR/upload-keystore.jks"
PROPS="$ANDROID_DIR/key.properties"
ALIAS="upload"

if [[ -f "$KEYSTORE" && -f "$PROPS" ]]; then
  echo "Release signing already configured:"
  echo "  Keystore: $KEYSTORE"
  echo "  Properties: $PROPS"
  echo ""
  STORE_PASS="$(grep '^storePassword=' "$PROPS" | cut -d= -f2-)"
  keytool -list -v \
    -keystore "$KEYSTORE" \
    -alias "$ALIAS" \
    -storepass "$STORE_PASS" 2>/dev/null | grep -E 'SHA1:|SHA256:' || true
  exit 0
fi

if ! command -v keytool >/dev/null 2>&1; then
  echo "keytool not found. Install a JDK (Java 17+) and retry." >&2
  exit 1
fi

STORE_PASS="$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 24)"
KEY_PASS="$STORE_PASS"

keytool -genkey -v \
  -keystore "$KEYSTORE" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "$STORE_PASS" \
  -keypass "$KEY_PASS" \
  -dname "CN=Whiplyn, OU=Mobile, O=Velocitech, L=Accra, ST=Greater Accra, C=GH"

cat > "$PROPS" <<EOF
storePassword=$STORE_PASS
keyPassword=$KEY_PASS
keyAlias=$ALIAS
storeFile=upload-keystore.jks
EOF

chmod 600 "$PROPS"

echo "Created release signing assets:"
echo "  $KEYSTORE"
echo "  $PROPS"
echo ""
echo "SHA fingerprints — add to Firebase Console (Android app) and GCP API key restrictions:"
keytool -list -v \
  -keystore "$KEYSTORE" \
  -alias "$ALIAS" \
  -storepass "$STORE_PASS" | grep -E 'SHA1:|SHA256:'
echo ""
echo "IMPORTANT: Back up upload-keystore.jks and key.properties offline."
echo "Build release AAB with: fvm flutter build appbundle --release"
