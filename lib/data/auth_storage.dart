// 간단한 인메모리 저장소 (실제 앱에서는 secure_storage 사용 권장)
class AuthStorage {
  static final AuthStorage _instance = AuthStorage._internal();
  factory AuthStorage() => _instance;
  AuthStorage._internal() {
    // 테스트 계정 추가
    _users['01055338237'] = {
      'name': '김호중',
      'password': 'jack8237!!',
      'year': 2000,
      'month': 9,
      'day': 19,
      'gender': '남성',
    };
  }
  
  // 회원 정보 저장
  final Map<String, Map<String, dynamic>> _users = {};
  
  // 현재 로그인한 사용자
  String? _currentUser;
  
  // 토큰 저장
  String? _accessToken;
  String? _refreshToken;
  
  // 회원가입
  void register({
    required String name,
    required String phone,
    required String password,
    required int year,
    required int month,
    required int day,
    required String gender,
  }) {
    _users[phone] = {
      'name': name,
      'password': password,
      'year': year,
      'month': month,
      'day': day,
      'gender': gender,
    };
  }
  
  // 로그인 확인
  bool login(String phone, String password) {
    if (_users.containsKey(phone)) {
      if (_users[phone]!['password'] == password) {
        _currentUser = phone;
        return true;
      }
    }
    return false;
  }
  
  // 로그아웃
  void logout() {
    _currentUser = null;
  }
  
  // 현재 사용자 확인
  bool get isLoggedIn => _currentUser != null;
  
  // 현재 사용자 정보 가져오기
  Map<String, dynamic>? get currentUser => 
      _currentUser != null ? _users[_currentUser] : null;
  
  // 사용자 정보 가져오기
  Map<String, dynamic>? getCurrentUser() {
    if (_currentUser != null && _users.containsKey(_currentUser)) {
      return {
        'phone': _currentUser,
        ..._users[_currentUser]!,
      };
    }
    return null;
  }
  
  // 토큰 관련 메서드들
  Future<String?> getAccessToken() async {
    return _accessToken;
  }
  
  Future<String?> getRefreshToken() async {
    return _refreshToken;
  }
  
  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
  }
  
  Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
  }
  
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}