import 'dart:async';
import 'package:dio/dio.dart';
import '../env.dart';
import '../constants.dart' as constants;
import 'token_storage.dart';
import 'api_exceptions.dart';

class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
  headers: constants.Headers.json,
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_shouldAttachAuthHeader(options.path)) {
            final token = await TokenStorage.instance.accessToken;
            if (token != null && token.isNotEmpty) {
              options.headers[constants.Headers.auth] = 'Bearer $token';
            } else {
              options.headers.remove(constants.Headers.auth);
            }
          } else {
            options.headers.remove(constants.Headers.auth);
          }
          if (Env.isDebug) {
            // Lightweight log
            // ignore: avoid_print
            print('[REQ] ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onResponse: (res, handler) {
          if (Env.isDebug) {
            // ignore: avoid_print
            print('[RES] ${res.statusCode} ${res.requestOptions.uri}');
          }
          handler.next(res);
        },
        onError: (e, handler) async {
          if (Env.isDebug) {
            // ignore: avoid_print
            print('[ERR] ${e.response?.statusCode} ${e.requestOptions.uri} ${e.message}');
          }

          if (_shouldAttemptRefresh(e)) {
            try {
              final refreshed = await _refreshAccessToken();
              if (refreshed) {
                final cloneReq = await _retryRequest(e.requestOptions);
                return handler.resolve(cloneReq);
              }
            } catch (_) {
              // fall through to original error
            }
          }

            final ex = e.response != null
                ? buildApiExceptionFromResponse(
                    e.response?.statusCode,
                    e.response?.data,
                  )
                : ApiException(e.message ?? 'Network error');
            handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: ex,
                type: e.type,
                response: e.response,
              ),
            );
        },
      ),
    );
  }

  static final DioClient instance = DioClient._();
  late final Dio _dio;

  bool _isRefreshing = false;
  final List<QueuedRequest> _queue = [];

  bool _shouldAttachAuthHeader(String path) {
    final normalizedPath = path.split('?').first;
    const publicEndpoints = {
      constants.ApiEndpoints.register,
      constants.ApiEndpoints.login,
      constants.ApiEndpoints.verifyOtp,
      constants.ApiEndpoints.resendOtp,
    };
    return !publicEndpoints.any((endpoint) => normalizedPath.endsWith(endpoint));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.get<T>(
        path,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      );

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.post<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      );

  bool _shouldAttemptRefresh(DioException e) {
    final status = e.response?.statusCode;
    return status == 401 && !_isRefreshing;
  }

  Future<bool> _refreshAccessToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refresh = await TokenStorage.instance.refreshToken;
      if (refresh == null) return false;
      final res = await _dio.post(
  constants.ApiEndpoints.refreshToken,
        data: {'refresh': refresh},
        options: Options(headers: {
          // Ensure old / expired access token isn't required
          constants.Headers.auth: null,
        }),
      );
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final newAccess = data['access']?.toString();
        final newRefresh = data['refresh']?.toString() ?? refresh;
        if (newAccess != null) {
          await TokenStorage.instance.saveTokens(
            access: newAccess,
            refresh: newRefresh,
          );
          // Process queued
          for (final q in _queue) {
            q.complete(_retryRequest(q.requestOptions));
          }
          _queue.clear();
          return true;
        }
      }
      return false;
    } catch (_) {
      for (final q in _queue) {
        q.completeError(ApiException('Session expired'));
      }
      _queue.clear();
      await TokenStorage.instance.clear();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions ro) async {
    final opts = Options(
      method: ro.method,
      headers: ro.headers,
      responseType: ro.responseType,
      contentType: ro.contentType,
      followRedirects: ro.followRedirects,
      receiveDataWhenStatusError: ro.receiveDataWhenStatusError,
      validateStatus: ro.validateStatus,
    );
    return _dio.request(
      ro.path,
      data: ro.data,
      queryParameters: ro.queryParameters,
      options: opts,
      cancelToken: ro.cancelToken,
      onReceiveProgress: ro.onReceiveProgress,
      onSendProgress: ro.onSendProgress,
    );
  }
}

class QueuedRequest {
  final RequestOptions requestOptions;
  final Completer<Response<dynamic>> _completer = Completer();

  QueuedRequest(this.requestOptions);

  void complete(Future<Response<dynamic>> fut) {
    fut.then(_completer.complete).catchError(_completer.completeError);
  }

  void completeError(Object e) => _completer.completeError(e);

  Future<Response<dynamic>> get future => _completer.future;
}