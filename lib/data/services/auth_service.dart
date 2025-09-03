import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_token_model.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
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
  static const String _temporaryTokenKey = 'temporary_token';
  
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
  Future<LoginResponseModel?> login(LoginRequestModel request) async {
    try {
      // 요청 정보 출력 (디버깅용)
      print('=== 로그인 요청 ===');
      print('URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.login}');
      print('Request Data: ${request.toJson()}');
      
      final response = await _dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      
      // 응답 정보 출력 (디버깅용)
      print('=== 로그인 응답 ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        final code = responseData['code'];
        final message = responseData['message'];
        final data = responseData['data'];
        
        print('Response Code: $code');
        print('Response Message: $message');
        
        // 성공 코드 확인 (AUTH_2002가 성공)
        if (code == 'AUTH_2002' && data != null) {
          // 토큰 및 사용자 정보 저장
          final tokens = AuthTokenModel.fromJson(data);
          await _saveTokens(tokens);
          print('=== 토큰 저장 완료 ===');
          print('Access Token: ${tokens.accessToken.substring(0, 20)}...');
          
          // 사용자 정보 저장
          if (data['memberId'] != null) {
            await _prefs.setInt('member_id', data['memberId']);
          }
          if (data['memberName'] != null) {
            await _prefs.setString('member_name', data['memberName']);
          }
          if (data['phoneNumber'] != null) {
            await _prefs.setString('phone_number_info', data['phoneNumber']);
          }
          if (data['gender'] != null) {
            await _prefs.setString('gender', data['gender']);
          }
          if (data['birthDate'] != null) {
            await _prefs.setString('birth_date', data['birthDate']);
          }
          if (data['role'] != null) {
            await _prefs.setString('role', data['role']);
          }
          if (data['email'] != null) {
            await _prefs.setString('email', data['email']);
          }
          if (data['status'] != null) {
            await _prefs.setString('status', data['status']);
          }
          
          // 로그인 응답 모델 반환
          return LoginResponseModel.fromJson(responseData);
        } else {
          // 서버가 200을 반환했지만 실제로는 에러 (사용자 친화적 메시지로 변경)
          print('=== 로그인 실패 (서버 에러 코드) ===');
          if (code == 'MEMBER_NOT_FOUND') {
            throw Exception('회원가입이 필요합니다.\n지금 바로 가입하시겠습니까?');
          } else if (code == 'INVALID_PASSWORD') {
            throw Exception('비밀번호를 다시 확인해주세요.');
          } else if (code == 'REQUIRED_FIELD_MISSING') {
            throw Exception('올바른 전화번호 형식을 입력해주세요.\n(예: 01012345678)');
          } else {
            throw Exception(message ?? '로그인할 수 없습니다.\n잠시 후 다시 시도해주세요.');
          }
        }
      }
      return null;
    } on DioException catch (e) {
      // 에러 정보 출력 (디버깅용)
      print('=== 로그인 에러 ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response Status: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      
      // 에러 응답 처리
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;
        
        if (statusCode == 404) {
          // USER_NOT_FOUND - 등록되지 않은 계정
          throw Exception('등록되지 않은 계정입니다.');
        } else if (statusCode == 400) {
          // INVALID_CREDENTIALS - 비밀번호 불일치
          throw Exception('아이디 또는 비밀번호가 일치하지 않습니다.');
        } else if (statusCode == 500) {
          // SERVER_ERROR
          throw Exception('서버 오류가 발생했습니다.');
        } else {
          // 기타 에러
          final message = errorData?['message'] ?? '로그인에 실패했습니다.';
          throw Exception(message);
        }
      } else {
        // 네트워크 오류 등
        throw Exception('네트워크 연결을 확인해주세요.');
      }
    }
  }
  
  // SMS 인증코드 전송
  Future<bool> sendSmsCode(String phoneNumber) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.smsSend,
        data: {'phoneNumber': phoneNumber},
      );
      
      return response.statusCode == 200;
    } on DioException {
      // SMS 전송 실패 (로그 대신 에러만 반환)
      return false;
    }
  }
  
  // SMS 인증코드 검증
  Future<String?> verifySmsCode(String phoneNumber, String code) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.smsVerify,
        data: {
          'phoneNumber': phoneNumber,
          'code': code,
        },
      );
      
      if (response.statusCode == 200) {
        final temporaryToken = response.data['data']['temporaryToken'];
        // 임시 토큰 저장
        await _prefs.setString(_temporaryTokenKey, temporaryToken);
        return temporaryToken;
      }
      return null;
    } on DioException {
      // SMS 검증 실패 (로그 대신 에러만 반환)
      return null;
    }
  }
  
  // 임시 토큰 가져오기
  Future<String?> getTemporaryToken() async {
    return _prefs.getString(_temporaryTokenKey);
  }
  
  // 임시 토큰 삭제
  Future<void> clearTemporaryToken() async {
    await _prefs.remove(_temporaryTokenKey);
  }
  
  // 회원가입
  Future<AuthTokenModel?> register(RegisterRequestModel request, {String? temporaryToken}) async {
    try {
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      
      // 임시 토큰이 있으면 헤더에 추가
      if (temporaryToken != null) {
        headers['Authorization'] = 'Bearer $temporaryToken';
      }
      
      final response = await _dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
        options: Options(headers: headers),
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
    
    print('=== 자동 로그인 시도 ===');
    print('Phone: $phoneNumber');
    
    final result = await login(LoginRequestModel(
      phoneNumber: phoneNumber,
      password: password,
    ));
    
    return result != null;
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
    await _prefs.remove('member_id');
    await _prefs.remove('member_name');
    await _prefs.remove('phone_number_info');
    await _prefs.remove('gender');
    await _prefs.remove('birth_date');
    await _prefs.remove('role');
    await _prefs.remove('email');
    await _prefs.remove('status');
  }
  
  // 사용자 정보 가져오기
  Future<Map<String, dynamic>> getUserInfo() async {
    return {
      'memberId': _prefs.getInt('member_id'),
      'memberName': _prefs.getString('member_name'),
      'phoneNumber': _prefs.getString('phone_number_info'),
      'gender': _prefs.getString('gender'),
      'birthDate': _prefs.getString('birth_date'),
      'role': _prefs.getString('role'),
      'email': _prefs.getString('email'),
      'status': _prefs.getString('status'),
    };
  }
}