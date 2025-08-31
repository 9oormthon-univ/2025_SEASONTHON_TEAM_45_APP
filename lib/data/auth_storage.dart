// 간단한 인메모리 저장소 (실제 앱에서는 secure_storage 사용 권장)
class AuthStorage {
  static final AuthStorage _instance = AuthStorage._internal();
  factory AuthStorage() => _instance;
  AuthStorage._internal();
  
  // 회원 정보 저장
  final Map<String, Map<String, dynamic>> _users = {};
  
  // 현재 로그인한 사용자
  String? _currentUser;
  
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
}