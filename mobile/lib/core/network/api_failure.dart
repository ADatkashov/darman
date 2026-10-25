import 'package:dio/dio.dart';

/// Normalised error for every failed API interaction. [code] is the backend's machine-readable error code
/// (or NETWORK / TIMEOUT / UNKNOWN for transport-level problems) and is mapped to localized text in the UI layer.
class ApiFailure implements Exception {
  const ApiFailure({required this.code, this.status, this.message, this.fieldErrors = const {}});

  final String code;
  final int? status;
  final String? message;
  final Map<String, String> fieldErrors;

  bool get isNetwork => code == 'NETWORK' || code == 'TIMEOUT';
  bool get isUnauthorized => status == 401;

  factory ApiFailure.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiFailure(code: 'TIMEOUT');
      case DioExceptionType.connectionError:
        return const ApiFailure(code: 'NETWORK');
      case DioExceptionType.cancel:
        return const ApiFailure(code: 'CANCELLED');
      default:
        break;
    }
    final res = e.response;
    if (res == null) return const ApiFailure(code: 'NETWORK');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      final fields = <String, String>{};
      final raw = data['fieldErrors'];
      if (raw is List) {
        for (final f in raw) {
          if (f is Map && f['field'] != null) fields[f['field'].toString()] = (f['message'] ?? '').toString();
        }
      }
      return ApiFailure(
        code: (data['code'] as String?) ?? _byStatus(res.statusCode),
        status: res.statusCode,
        message: data['message'] as String?,
        fieldErrors: fields,
      );
    }
    return ApiFailure(code: _byStatus(res.statusCode), status: res.statusCode);
  }

  static String _byStatus(int? s) => switch (s) {
    401 => 'UNAUTHORIZED',
    403 => 'FORBIDDEN',
    404 => 'NOT_FOUND',
    429 => 'RATE_LIMITED',
    final int c when c >= 500 => 'INTERNAL_ERROR',
    _ => 'UNKNOWN',
  };

  @override
  String toString() => 'ApiFailure($code, status=$status, message=$message)';
}
