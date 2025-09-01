class ApiEndpoints {
  // Base URL - 실제 서버 URL로 변경 필요
  static const String baseUrl = 'https://api.carefreepass.com';
  
  // Auth Endpoints
  static const String login = '$baseUrl/v1/auth/patient/sign-in';
  static const String register = '$baseUrl/v1/auth/patient/sign-up';
  static const String refreshToken = '$baseUrl/v1/auth/reissue';
  
  // Patient Endpoints
  static const String patientProfile = '/patient/profile';
  static const String updateProfile = '/patient/profile/update';
  
  // Hospital Endpoints
  static const String hospitalList = '/hospital/list';
  static const String hospitalDetail = '/hospital/detail';
  
  // Appointment Endpoints
  static const String createAppointment = '/appointment/create';
  static const String appointmentList = '/appointment/list';
  static const String appointmentDetail = '/appointment/detail';
  static const String cancelAppointment = '/appointment/cancel';
  
  // Reservation Endpoints
  static const String reservations = '/api/v1/reservations';
  
  // BLE/Beacon Endpoints
  static const String reportArrival = '/beacon/arrival';
  static const String checkInStatus = '/beacon/status';
}