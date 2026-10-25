import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_store.dart';
import 'api_failure.dart';

typedef LocaleReader = String Function();

/// Dio wrapper that adds auth + language headers and transparently rotates the refresh token on 401.
/// A single in-flight refresh is shared by concurrent requests. When refresh fails, [onSessionExpired] fires.
class ApiClient {
  ApiClient({
    required this.tokens,
    required this.locale,
    this.onSessionExpired,
    this.onReachability,
    Dio? dio,
    Dio? refreshDio,
    String? baseUrl,
  }) : dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
               sendTimeout: const Duration(seconds: 60),
             ),
           ),
       _refreshDio =
           refreshDio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
             ),
           ) {
    this.dio.interceptors.add(InterceptorsWrapper(onRequest: _onRequest, onResponse: _onResponse, onError: _onError));
  }

  final TokenStore tokens;
  final LocaleReader locale;
  final void Function()? onSessionExpired;

  /// true after any response from the server, false after a connection-level failure (drives the offline banner).
  final void Function(bool reachable)? onReachability;
  final Dio dio;
  final Dio _refreshDio;
  Future<bool>? _refreshing;

  static const _retryFlag = 'darman_retried';
  static const _noAuthFlag = 'darman_no_auth';

  Future<void> _onRequest(RequestOptions o, RequestInterceptorHandler h) async {
    o.headers['Accept-Language'] = locale();
    if (o.extra[_noAuthFlag] != true) {
      final t = await tokens.readAccess();
      if (t != null && !o.headers.containsKey('Authorization')) o.headers['Authorization'] = 'Bearer $t';
    }
    h.next(o);
  }

  void _onResponse(Response<dynamic> r, ResponseInterceptorHandler h) {
    onReachability?.call(true);
    h.next(r);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler h) async {
    final req = e.requestOptions;
    if (e.response != null) {
      onReachability?.call(true);
    } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      onReachability?.call(false);
    }
    final isAuthCall = req.path.contains('/auth/');
    if (e.response?.statusCode == 401 && !isAuthCall && req.extra[_retryFlag] != true && req.extra[_noAuthFlag] != true) {
      final hadToken = await tokens.readRefresh() != null;
      if (hadToken) {
        final ok = await (_refreshing ??= _refresh().whenComplete(() => _refreshing = null));
        if (ok) {
          try {
            req.extra[_retryFlag] = true;
            req.headers.remove('Authorization');
            final res = await dio.fetch<dynamic>(req);
            return h.resolve(res);
          } on DioException catch (e2) {
            return h.next(e2);
          }
        }
        onSessionExpired?.call();
      }
    }
    h.next(e);
  }

  Future<bool> _refresh() async {
    final refresh = await tokens.readRefresh();
    if (refresh == null) return false;
    try {
      final res = await _refreshDio.post<Map<String, dynamic>>('${AppConfig.apiPrefix}/auth/refresh', data: {'refreshToken': refresh});
      final d = res.data!;
      await tokens.write(access: d['accessToken'] as String, refresh: d['refreshToken'] as String);
      return true;
    } on DioException catch (e) {
      // Only a definitive rejection ends the session; a network blip keeps tokens for the next attempt.
      final s = e.response?.statusCode;
      if (s == 401 || s == 403) await tokens.clear();
      return false;
    }
  }

  // ───── typed helpers ─────

  Future<T> _run<T>(Future<Response<dynamic>> Function() call, T Function(dynamic data) map) async {
    try {
      final res = await call();
      return map(res.data);
    } on DioException catch (e) {
      throw ApiFailure.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getMap(String path, {Map<String, dynamic>? query, bool auth = true}) => _run(
    () => dio.get<dynamic>(
      '${AppConfig.apiPrefix}$path',
      queryParameters: query,
      options: Options(extra: {_noAuthFlag: !auth}),
    ),
    (d) => d as Map<String, dynamic>,
  );

  Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query, bool auth = true}) => _run(
    () => dio.get<dynamic>(
      '${AppConfig.apiPrefix}$path',
      queryParameters: query,
      options: Options(extra: {_noAuthFlag: !auth}),
    ),
    (d) => d as List<dynamic>,
  );

  Future<Map<String, dynamic>> postMap(String path, {Object? body, Map<String, String>? headers, bool auth = true}) => _run(
    () => dio.post<dynamic>(
      '${AppConfig.apiPrefix}$path',
      data: body,
      options: Options(headers: headers, extra: {_noAuthFlag: !auth}),
    ),
    (d) => (d as Map<String, dynamic>?) ?? <String, dynamic>{},
  );

  Future<Map<String, dynamic>> patchMap(String path, {Object? body}) =>
      _run(() => dio.patch<dynamic>('${AppConfig.apiPrefix}$path', data: body), (d) => d as Map<String, dynamic>);

  Future<void> putVoid(String path) => _run(() => dio.put<dynamic>('${AppConfig.apiPrefix}$path'), (_) {});

  Future<void> deleteVoid(String path) => _run(() => dio.delete<dynamic>('${AppConfig.apiPrefix}$path'), (_) {});

  Future<Map<String, dynamic>> deleteMap(String path) =>
      _run(() => dio.delete<dynamic>('${AppConfig.apiPrefix}$path'), (d) => (d as Map<String, dynamic>?) ?? <String, dynamic>{});

  Future<void> postVoid(String path, {Object? body}) => _run(() => dio.post<dynamic>('${AppConfig.apiPrefix}$path', data: body), (_) {});

  Future<Map<String, dynamic>> postMultipart(String path, FormData form, {void Function(int sent, int total)? onProgress}) => _run(
    () => dio.post<dynamic>('${AppConfig.apiPrefix}$path', data: form, onSendProgress: onProgress),
    (d) => d as Map<String, dynamic>,
  );

  Future<List<int>> getBytes(String path) => _run(
    () => dio.get<List<int>>('${AppConfig.apiPrefix}$path', options: Options(responseType: ResponseType.bytes)),
    (d) => (d as List<int>),
  );
}
