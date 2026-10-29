#!/usr/bin/env bash
# Runs what CI runs (.github/workflows/mobile.yml and backend.yml) on this machine — for when GitHub Actions is not
# running (billing, no runner) or you want an answer before pushing.
#
#   scripts/verify-local.sh                 # everything
#   scripts/verify-local.sh flutter         # gen-l10n + analyze + test for mobile/
#   scripts/verify-local.sh backend         # backend tests (+ bootJar)
#
# Flutter needs `flutter` on PATH (CI pins the version in mobile.yml). The backend needs JDK 21; its integration tests
# start PostgreSQL through Testcontainers (needs Docker) or use an empty database from DARMAN_TEST_DB_URL /
# DARMAN_TEST_DB_USER / DARMAN_TEST_DB_PASSWORD (UTF-8 locale; must be empty on the first run).
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"
failed=()

run_flutter() {
  command -v flutter >/dev/null || { echo "flutter is not on PATH (scripts/setup-local-dev-wsl.sh)" >&2; exit 2; }
  echo "=== flutter: mobile"
  (
    cd "$ROOT/mobile"
    flutter pub get >/dev/null
    flutter gen-l10n
    flutter analyze
    flutter test
  ) || failed+=("flutter")
}

run_backend() {
  command -v java >/dev/null || { echo "java (JDK 21) is not on PATH (scripts/setup-local-dev-wsl.sh)" >&2; exit 2; }
  echo "=== backend"
  if [ -z "${DARMAN_TEST_DB_URL:-}" ] && ! { command -v docker >/dev/null && docker info >/dev/null 2>&1; }; then
    echo "Neither Docker nor DARMAN_TEST_DB_URL is available: the integration tests cannot run." >&2
    failed+=("backend (no database for tests)")
    return
  fi
  (
    cd "$ROOT/backend"
    chmod +x gradlew
    ./gradlew --no-daemon test
    ./gradlew --no-daemon bootJar -x test
  ) || failed+=("backend")
}

what="${1:-all}"
case "$what" in
  all) run_flutter; run_backend ;;
  flutter) run_flutter ;;
  backend) run_backend ;;
  *) echo "usage: $0 [all|flutter|backend]" >&2; exit 2 ;;
esac

if [ ${#failed[@]} -gt 0 ]; then
  echo
  echo "FAILED: ${failed[*]}"
  exit 1
fi
echo
echo "All checks passed."
