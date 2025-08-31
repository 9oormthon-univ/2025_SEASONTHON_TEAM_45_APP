import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_token_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../network/api_endpoints.dart';

class AuthService {
  late Dio _dio;
  late SharedPreferences _prefs;
  
  // SharedPreferences 키
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _autoLoginKey = 'auto_login';
  static const String _phoneNumberKey = 'phone_number';
  static const String _passwordKey = 'password';
  
  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // 인터셉터 추가 (토큰 자동 추가 및 갱신)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 토큰이 필요한 API 호출 시 자동으로 헤더에 추가
        final token = await getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401 에러 시 토큰 갱신 시도
        if (error.response?.statusCode == 401) {
          final refreshToken = await getRefreshToken();
          if (refreshToken != null) {
            try {
              final newTokens = await refreshAccessToken(refreshToken);
              if (newTokens != null) {
                // 새 토큰으로 원래 요청 재시도
                error.requestOptions.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';
                final response = await _dio.request(
                  error.requestOptions.path,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );
                handler.resolve(response);
                return;
              }
            } catch (e) {
              // 토큰 갱신 실패 시 로그아웃 처리
              await logout();
            }
          }
        }
        handler.next(error);
      },
    ));
  }
  
  // SharedPreferences 초기화
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // 로그인
  Future<AuthTokenModel?> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final tokens = AuthTokenModel.fromJson(response.data);
        await _saveTokens(tokens);
        return tokens;
      }
      return null;
    } on DioException {
      return null;
    }
  }
  
  // 회원가입
  Future<AuthTokenModel?> register(RegisterRequestModel request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final tokens = AuthTokenModel.fromJson(response.data);
        await _saveTokens(tokens);
        return tokens;
      }
      return null;
    } on DioException {
      return null;
    }
  }
  
  // 토큰 재발급
  Future<AuthTokenModel?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final tokens = AuthTokenModel.fromJson(response.data);
        await _saveTokens(tokens);
        return tokens;
      }
      return null;
    } on DioException {
      return null;
    }
  }
  
  // 자동 로그인
  Future<bool> tryAutoLogin() async {
    final isAutoLogin = _prefs.getBool(_autoLoginKey) ?? false;
    if (!isAutoLogin) return false;
    
    final phoneNumber = _prefs.getString(_phoneNumberKey);
    final password = _prefs.getString(_passwordKey);
    
    if (phoneNumber == null || password == null) return false;
    
    final tokens = await login(LoginRequestModel(
      phoneNumber: phoneNumber,
      password: password,
    ));
    
    return tokens != null;
  }
  
  // 자동 로그인 설정
  Future<void> setAutoLogin(bool enabled, {String? phoneNumber, String? password}) async {
    await _prefs.setBool(_autoLoginKey, enabled);
    
    if (enabled && phoneNumber != null && password != null) {
      await _prefs.setString(_phoneNumberKey, phoneNumber);
      await _prefs.setString(_passwordKey, password);
    } else if (!enabled) {
      await _prefs.remove(_phoneNumberKey);
      await _prefs.remove(_passwordKey);
    }
  }
  
  // 토큰 저장
  Future<void> _saveTokens(AuthTokenModel tokens) async {
    await _prefs.setString(_accessTokenKey, tokens.accessToken);
    await _prefs.setString(_refreshTokenKey, tokens.refreshToken);
  }
  
  // Access Token 가져오기
  Future<String?> getAccessToken() async {
    return _prefs.getString(_accessTokenKey);
  }
  
  // Refresh Token 가져오기
  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }
  
  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  // 로그아웃
  Future<void> logout() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_autoLoginKey);
    await _prefs.remove(_phoneNumberKey);
    await _prefs.remove(_passwordKey);
  }
}