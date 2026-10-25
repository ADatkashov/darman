import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT pair. Tokens are sensitive, so they live in the platform keystore/keychain, never in SharedPreferences.
abstract class TokenStore {
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> write({required String access, required String refresh});
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage]) : _s = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;
  static const _a = 'darman.access';
  static const _r = 'darman.refresh';

  @override
  Future<String?> readAccess() => _s.read(key: _a);
  @override
  Future<String?> readRefresh() => _s.read(key: _r);
  @override
  Future<void> write({required String access, required String refresh}) async {
    await _s.write(key: _a, value: access);
    await _s.write(key: _r, value: refresh);
  }

  @override
  Future<void> clear() async {
    await _s.delete(key: _a);
    await _s.delete(key: _r);
  }
}

/// In-memory implementation for tests.
class MemoryTokenStore implements TokenStore {
  String? access;
  String? refresh;
  @override
  Future<String?> readAccess() async => access;
  @override
  Future<String?> readRefresh() async => refresh;
  @override
  Future<void> write({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}
