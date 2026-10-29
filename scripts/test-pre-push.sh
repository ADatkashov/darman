#!/usr/bin/env bash
# Tests the file classification of scripts/git-hooks/pre-push. Run: scripts/test-pre-push.sh
set -euo pipefail
hook="$(cd "$(dirname "$0")" && pwd)/git-hooks/pre-push"
fail=0
check() { # name, input files, expected output
  local got; got="$(printf '%s\n' "$2" | bash "$hook" --classify | paste -sd, -)"
  if [ "$got" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: expected '$3', got '$got'"; fail=1; fi
}
check "docs only"      $'docs/CI.md\nREADME.md'                      ""
check "scripts only"   $'scripts/verify-local.sh'                    ""
check "mobile"         $'mobile/lib/main.dart'                       "flutter"
check "backend"        $'backend/src/main/java/kz/darman/A.java'     "backend"
check "both"           $'mobile/lib/x.dart\nbackend/build.gradle.kts' "flutter,backend"
check "workflows only" $'.github/workflows/backend.yml'              ""
exit $fail
