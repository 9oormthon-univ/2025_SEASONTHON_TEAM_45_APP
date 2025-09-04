class ApiEndpoints {
  // Base URL - 실제 서버 URL
  static const String baseUrl = 'http://13.209.99.158:8080';
  //static const String baseUrl = 'http://218.51.41.52:9600';
  
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
  static const String myTodayAppointments = '/api/v1/appointments/my/today';
  static const String myAllAppointments = '/api/v1/appointments/my';
  static const String checkIn = '/api/v1/appointments/checkin';
  
  // Time Slot Endpoints
  static const String availableTimeSlots = '/api/v1/patient/time-slots';
  
  // Reservation Endpoints (통합)
  static const String reservations = '/api/v1/appointments';
  
  // BLE/Beacon Endpoints
  static const String reportArrival = '/beacon/arrival';
  static const String checkInStatus = '/beacon/status';
  
  // Chat/AI Endpoints
  static const String chatStart = '/api/v1/chat/start';
  static const String chatMessage = '/api/v1/chat/message';
  static const String chatSessionDetail = '/api/v1/chat/sessions'; // /{sessionId}
  static const String chatSessionList = '/api/v1/chat/sessions';
  static const String chatComplete = '/api/v1/chat/sessions'; // /{sessionId}/complete
  
  // WebSocket URL
  static String get wsBaseUrl {
    // http:// 또는 https://를 ws:// 또는 wss://로 변환
    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    } else if (baseUrl.startsWith('http://')) {
      return baseUrl.replaceFirst('http://', 'ws://');
    }
    return baseUrl;
  }
  static const String wsChat = '/ws/chat'; // /{memberId}
}