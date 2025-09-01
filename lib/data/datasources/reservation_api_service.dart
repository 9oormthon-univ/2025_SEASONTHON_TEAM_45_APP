import 'package:dio/dio.dart';
import '../network/api_endpoints.dart';
import '../auth_storage.dart';

class ReservationApiService {
  late Dio _dio;
  final AuthStorage _authStorage;

  ReservationApiService({required AuthStorage authStorage}) : _authStorage = authStorage {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // 토큰 갱신 로직
          final refreshToken = await _authStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await Dio().post(
                '${ApiEndpoints.baseUrl}${ApiEndpoints.refreshToken}',
                data: {'refreshToken': refreshToken},
              );
              
              if (response.statusCode == 200) {
                final newAccessToken = response.data['data']['accessToken'];
                await _authStorage.saveAccessToken(newAccessToken);
                
                // 원래 요청 재시도
                error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final cloneReq = await _dio.request(
                  error.requestOptions.path,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );
                return handler.resolve(cloneReq);
              }
            } catch (e) {
              // 토큰 갱신 실패
              await _authStorage.clearTokens();
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {Map<String, dynamic>? data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}