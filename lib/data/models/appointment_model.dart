class AppointmentModel {
  final int appointmentId;
  final String memberName;
  final String hospitalName;
  final String department;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String statusDescription;
  final bool canCall;
  final String? roomName; // 호출됨 상태일 때 진료실 정보

  AppointmentModel({
    required this.appointmentId,
    required this.memberName,
    required this.hospitalName,
    required this.department,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.statusDescription,
    required this.canCall,
    this.roomName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointmentId: json['appointmentId'] ?? 0,
      memberName: json['memberName'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      department: json['department'] ?? '',
      appointmentDate: json['appointmentDate'] ?? '',
      appointmentTime: json['appointmentTime'] ?? '',
      status: json['status'] ?? 'SCHEDULED',
      statusDescription: json['statusDescription'] ?? '',
      canCall: json['canCall'] ?? false,
      roomName: json['roomName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'memberName': memberName,
      'hospitalName': hospitalName,
      'department': department,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'status': status,
      'statusDescription': statusDescription,
      'canCall': canCall,
      'roomName': roomName,
    };
  }

  // 상태 확인 헬퍼 메소드
  bool get isScheduled => status == 'SCHEDULED';
  bool get isCheckedIn => status == 'CHECKED_IN' || status == 'ARRIVED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isNoShow => status == 'NO_SHOW';
  bool get isCalled => status == 'CALLED';
}