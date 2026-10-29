#!/usr/bin/env bash
# Builds an installable Android APK on this machine — for when GitHub Actions is not available. If
# mobile/android/key.properties exists (scripts/setup-release-signing.sh) the APK is release-signed
# (darman-release-signed.apk); otherwise debug-signed (darman-debug-signed.apk).
#
#   scripts/build-apk-local.sh
#
# Optional env: API_BASE_URL (default https://darman-backend.onrender.com — the service name from render.yaml; set it if
# your Render URL differs), OUT_DIR. On WSL the finished APK is also copied to the Windows Documents\darman-apk folder
# (WIN_APK_DIR overrides the folder, WIN_COPY=0 turns it off).
# Needs scripts/setup-local-dev-wsl.sh + scripts/setup-android-sdk-wsl.sh.
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"
API_BASE_URL="${API_BASE_URL:-https://darman-backend.onrender.com}"
OUT_DIR="${OUT_DIR:-$ROOT/build-apk-out}"

command -v flutter >/dev/null || { echo "flutter not found: scripts/setup-local-dev-wsl.sh" >&2; exit 2; }
[ -n "${ANDROID_HOME:-}" ] || { echo "ANDROID_HOME not set: scripts/setup-android-sdk-wsl.sh, then open a new terminal" >&2; exit 2; }

mkdir -p "$OUT_DIR"
echo "=== building DARMAN (API: $API_BASE_URL)"
(
  cd "$ROOT/mobile"
  flutter pub get
  flutter gen-l10n
  flutter build apk --release --dart-define=API_BASE_URL="$API_BASE_URL"
)
if [ -f "$ROOT/mobile/android/key.properties" ]; then kind=release-signed; else kind=debug-signed; fi
cp "$ROOT/mobile/build/app/outputs/flutter-apk/app-release.apk" "$OUT_DIR/darman-$kind.apk"
echo "-> $OUT_DIR/darman-$kind.apk"

# WSL: also drop the APK into the Windows user's Documents so it is one click from Explorer / the phone transfer.
win_dir="${WIN_APK_DIR:-}"
if [ -z "$win_dir" ] && [ "${WIN_COPY:-1}" != "0" ] && grep -qi microsoft /proc/version 2>/dev/null; then
  profile="$(cd /mnt/c 2>/dev/null && cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r' || true)"
  [ -n "$profile" ] && win_dir="$(wslpath -u "$profile")/Documents/darman-apk"
fi
if [ -n "$win_dir" ] && [ "${WIN_COPY:-1}" != "0" ]; then
  mkdir -p "$win_dir"
  cp -f "$OUT_DIR/darman-$kind.apk" "$win_dir/"
  echo "Copied to Windows: $(wslpath -w "$win_dir" 2>/dev/null || echo "$win_dir")"
fi
echo
echo "Done. From Windows open: \\\\wsl\$\\Ubuntu${OUT_DIR}   (or run: explorer.exe \"\$(wslpath -w '$OUT_DIR')\")"
