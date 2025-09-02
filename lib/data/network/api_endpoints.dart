class ApiEndpoints {
  // Base URL - 실제 서버 URL
  static const String baseUrl = 'http://13.124.250.98:8080';
  
  // Auth Endpoints
  static const String login = '/api/v1/auth/patient/sign-in';
  static const String register = '/api/v1/auth/patient/sign-up';
  static const String refreshToken = '/api/v1/auth/reissue';
  static const String smsSend = '/api/v1/auth/sms/send';
  static const String smsVerify = '/api/v1/auth/sms/verify';
  
  // Patient Endpoints
  static const String patientProfile = '/patient/profile';
  static const String updateProfile = '/patient/profile/update';
  
  // Hospital Endpoints
  static const String hospitalList = '/hospital/list';
  static const String hospitalDetail = '/hospital/detail';
  
  // Appointment/Reservation Endpoints (예약 관리 API)
  static const String createAppointment = '/api/v1/appointments';
  static const String appointmentList = '/api/v1/appointments';
  static const String appointmentDetail = '/api/v1/appointments';
  static const String cancelAppointment = '/api/v1/appointments';
  
  // Reservation Endpoints (통합)
  static const String reservations = '/api/v1/appointments';
  
  // BLE/Beacon Endpoints
  static const String reportArrival = '/beacon/arrival';
  static const String checkInStatus = '/beacon/status';
}