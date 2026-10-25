import 'dart:convert';
import 'dart:typed_data';

import 'package:darman/core/network/api_client.dart';
import 'package:darman/core/storage/token_store.dart';
import 'package:darman/state/auth_state.dart';
import 'package:darman/state/core_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Scriptable adapter: returns canned responses by path and records calls.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.handler);
  final ResponseBody Function(RequestOptions o, int callIndex) handler;
  final calls = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    calls.add(options);
    return handler(options, calls.length);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Map<String, dynamic> body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

void main() {
  test('401 triggers one refresh, rotates tokens and retries the original request', () async {
    final tokens = MemoryTokenStore()
      ..access = 'old-access'
      ..refresh = 'refresh-1';
    final seenAuth = <String?>[];
    final adapter = ScriptedAdapter((o, i) {
      seenAuth.add(o.headers['Authorization'] as String?);
      if (o.path.endsWith('/users/me')) {
        return o.headers['Authorization'] == 'Bearer new-access' ? json(200, {'id': 'u'}) : json(401, {'code': 'UNAUTHORIZED'});
      }
      return json(404, {});
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = adapter;
    final refreshAdapter = ScriptedAdapter((o, i) => json(200, {'accessToken': 'new-access', 'refreshToken': 'refresh-2'}));
    final client = ApiClient(
      tokens: tokens,
      locale: () => 'ru',
      dio: dio,
      refreshDio: Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = refreshAdapter,
      baseUrl: 'http://x',
    );

    final res = await client.getMap('/users/me');
    expect(res['id'], 'u');
    expect(await tokens.readAccess(), 'new-access');
    expect(await tokens.readRefresh(), 'refresh-2');
    expect(refreshAdapter.calls, hasLength(1));
    expect(seenAuth, ['Bearer old-access', 'Bearer new-access']);
  });

  test('rejected refresh ends the session and notifies', () async {
    final tokens = MemoryTokenStore()
      ..access = 'a'
      ..refresh = 'r';
    var expired = false;
    final dio = Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = ScriptedAdapter((o, i) => json(401, {'code': 'UNAUTHORIZED'}));
    final client = ApiClient(
      tokens: tokens,
      locale: () => 'ru',
      dio: dio,
      refreshDio: Dio(BaseOptions(baseUrl: 'http://x'))
        ..httpClientAdapter = ScriptedAdapter((o, i) => json(401, {'code': 'INVALID_REFRESH_TOKEN'})),
      baseUrl: 'http://x',
      onSessionExpired: () => expired = true,
    );
    await expectLater(client.getMap('/users/me'), throwsA(anything));
    expect(expired, isTrue);
    expect(await tokens.readRefresh(), isNull);
  });

  test('auth notifier: guest without tokens, sign-in stores them, logout clears them, expiry flags the session', () async {
    SharedPreferences.setMockInitialValues({});
    final tokens = MemoryTokenStore();
    final c = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(await SharedPreferences.getInstance()),
        tokenStoreProvider.overrideWithValue(tokens),
      ],
    );
    addTearDown(c.dispose);
    final auth = c.read(authProvider.notifier);
    await auth.restore();
    expect(c.read(authProvider).status, AuthStatus.guest);

    // simulate a restored session, then involuntary expiry
    tokens.refresh = 'r';
    await auth.logout();
    expect(await tokens.readRefresh(), isNull);
    expect(c.read(authProvider).status, AuthStatus.guest);
  });
}
