import 'package:dio/dio.dart';
import 'package:health_mate/shared/constants/api_constants.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  final TokenStorage _tokenStorage;
  late final Dio _dio;

  Dio get dio => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      await _tokenStorage.clearTokens();
    }

    final statusCode = error.response?.statusCode ?? 0;
    final message = _extractMessage(error.response?.data) ??
        error.message ??
        'Unknown error';
    handler.reject(
      DioException(
        requestOptions: error.requestOptions,
        error: ApiException(statusCode: statusCode, message: message),
        response: error.response,
        type: error.type,
      ),
    );
  }

  String? _extractMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  static Map<String, dynamic> unwrap(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }

  static List<dynamic> unwrapList(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as List<dynamic>;
    }
    return body as List<dynamic>;
  }
}
