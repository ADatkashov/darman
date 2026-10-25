# DARMAN mobile (Flutter)

```bash
flutter pub get
flutter gen-l10n                 # after editing lib/l10n/*.arb
flutter analyze && flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080   # Android emulator -> host backend
```

Use your machine's LAN IP as `API_BASE_URL` on a physical device. Debug builds allow cleartext HTTP; release builds require HTTPS.

Optional contract test against a running demo backend:

```bash
DARMAN_API_URL=http://localhost:8080 DARMAN_DEMO_PASSWORD=<demo password> flutter test test/live_contract_test.dart
```

Architecture: Riverpod (state), GoRouter (navigation, auth guards), Dio (HTTP + token refresh), flutter_secure_storage (tokens),
SharedPreferences (cart, favorites for guests, recents, locale/theme). Models are hand-written immutable classes with `fromJson`
(see `docs/architecture.md` for why code generation was not used). Strings live in `lib/l10n/*.arb` (ru default, kk, en).
