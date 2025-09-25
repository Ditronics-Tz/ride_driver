import 'dart:io';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

ApiException mapDioError(Object error) {
  // We'll fill this from Dio layer (kept small to avoid dio import here)
  return ApiException(error.toString());
}

ApiException buildApiExceptionFromResponse(
  int? statusCode,
  dynamic data,
) {
  try {
    if (data is Map<String, dynamic>) {
      final msg = data['message']?.toString() ??
          data['detail']?.toString() ??
          'Unexpected error';
      final errsRaw = data['errors'];
      Map<String, dynamic>? errs;
      if (errsRaw is Map<String, dynamic>) errs = errsRaw;
      return ApiException(msg, statusCode: statusCode, errors: errs);
    }
    return ApiException('Unexpected server response', statusCode: statusCode);
  } catch (_) {
    return ApiException('Failed to parse error', statusCode: statusCode);
  }
}

bool isNetworkError(Object e) =>
    e is ApiException && (e.statusCode == null) ||
    e is SocketException;