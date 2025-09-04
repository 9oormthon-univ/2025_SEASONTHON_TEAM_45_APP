import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/exceptions.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/services/appointment_service.dart';
import '../../../domain/entities/reservation.dart';
import '../../../domain/usecases/get_reservations.dart';
import '../../../domain/usecases/create_reservation_usecase.dart';
import '../../../domain/usecases/cancel_reservation_usecase.dart';
import 'reservation_event.dart';
import 'reservation_state.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final GetReservations getReservations;
  final CreateReservationUseCase createReservationUseCase;
  final CancelReservationUseCase cancelReservationUseCase;
  final AppointmentService appointmentService = AppointmentService();
  Timer? _pollingTimer;
  int? _currentMemberId;

  ReservationBloc({
    required this.getReservations,
    required this.createReservationUseCase,
    required this.cancelReservationUseCase,
  }) : super(ReservationInitial()) {
    on<LoadReservations>(_onLoadReservations);
    on<CreateReservation>(_onCreateReservation);
    on<CancelReservation>(_onCancelReservation);
    on<UpdateReservationStatus>(_onUpdateReservationStatus);
    on<RefreshReservation>(_onRefreshReservation);
    on<CheckInAppointment>(_onCheckInAppointment);
    on<UpdateAppointmentStatus>(_onUpdateAppointmentStatus);
    on<UpdateAppointmentFromNotification>(_onUpdateAppointmentFromNotification);
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
  }
  
  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadReservations(
    LoadReservations event,
    Emitter<ReservationState> emit,
  ) async {
    if (!event.isPollingUpdate) {
      emit(ReservationLoading());
    }
    
    try {
      // 전체 예약 목록 조회
      final appointments = await appointmentService.getAllAppointments(event.memberId);
      
      if (event.isPollingUpdate) {
        print('[폴링] 예약 상태 자동 확인 중...');
        // 호출됨 상태 체크
        for (var appointment in appointments) {
          if (appointment.status == 'CALLED') {
            print('[폴링] 호출됨 상태 감지! ${appointment.department} ${appointment.roomName ?? "진료실"}');
          }
        }
      }
      
      // AppointmentModel을 사용하도록 수정
      // State에서도 AppointmentModel을 직접 사용하도록 변경
      emit(ReservationLoaded(reservations: appointments));
      
      // 폴링 자동 시작 (Push Notification 대체)
      if (!event.isPollingUpdate) {
        _currentMemberId = event.memberId;
        add(StartPolling());
        print('[폴링] 5초 간격 자동 상태 확인 시작 (Push Notification 대체)');
      }
      
    } on ServerException catch (e) {
      emit(ReservationError(message: e.message));
    } catch (e) {
      emit(ReservationError(message: '예약 목록 조회 중 오류가 발생했습니다'));
    }
  }

  Future<void> _onCreateReservation(
    CreateReservation event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationCreating());
    
    // TODO: API 연동 후 실제 예약 생성 로직 구현
    // 임시로 더미 데이터 생성
    final newReservation = Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      status: 'confirmed',
      date: event.date ?? '2025년 8월 31일',
      time: event.time ?? '오전 10:30',
      department: '내과',
      hospitalName: '구름대병원',
      doctorName: '김의사',
      message: '예약이 완료되었습니다',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    emit(ReservationCreated(reservation: newReservation));
    
    // 예약 목록 다시 로드
    // LoadReservations 에 memberId 추가 필요
  }

  Future<void> _onCancelReservation(
    CancelReservation event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationLoading());
    
    final result = await cancelReservationUseCase(event.reservationId);
    
    result.fold(
      (failure) => emit(ReservationError(message: _mapFailureToMessage(failure))),
      (_) => {
        // TODO: memberId를 가져와서 LoadReservations 호출
        // 현재는 상태 유지
      },
    );
  }

  Future<void> _onUpdateReservationStatus(
    UpdateReservationStatus event,
    Emitter<ReservationState> emit,
  ) async {
    if (state is ReservationLoaded) {
      final currentState = state as ReservationLoaded;
      // dynamic 타입 처리 - AppointmentModel에는 copyWith가 없으므로 무시
      emit(ReservationLoaded(reservations: currentState.reservations));
    }
  }

  Future<void> _onRefreshReservation(
    RefreshReservation event,
    Emitter<ReservationState> emit,
  ) async {
    // TODO: 특정 예약 상태 새로고침
    // LoadReservations 에 memberId 추가 필요
  }

  Future<void> _onCheckInAppointment(
    CheckInAppointment event,
    Emitter<ReservationState> emit,
  ) async {
    // TODO: API 호출하여 체크인 처리
    // 현재는 상태 유지
    if (state is ReservationLoaded) {
      final currentState = state as ReservationLoaded;
      emit(ReservationLoaded(reservations: currentState.reservations));
    }
  }

  Future<void> _onUpdateAppointmentStatus(
    UpdateAppointmentStatus event,
    Emitter<ReservationState> emit,
  ) async {
    if (state is ReservationLoaded) {
      final currentState = state as ReservationLoaded;
      // dynamic 타입 처리 - AppointmentModel 사용
      emit(ReservationLoaded(reservations: currentState.reservations));
    }
  }

  Future<void> _onUpdateAppointmentFromNotification(
    UpdateAppointmentFromNotification event,
    Emitter<ReservationState> emit,
  ) async {
    if (state is ReservationLoaded) {
      final currentState = state as ReservationLoaded;
      
      final updatedReservations = currentState.reservations.map((reservation) {
        if (reservation.appointmentId == event.appointmentId) {
          return _createUpdatedAppointment(reservation, event.status, event.roomName);
        }
        return reservation;
      }).toList();
      
      emit(ReservationLoaded(reservations: updatedReservations));
    }
  }
  
  dynamic _createUpdatedAppointment(dynamic appointment, String status, String? roomName) {
    return AppointmentModel(
      appointmentId: appointment.appointmentId,
      memberName: appointment.memberName,
      hospitalName: appointment.hospitalName,
      department: appointment.department,
      appointmentDate: appointment.appointmentDate,
      appointmentTime: appointment.appointmentTime,
      status: status,
      statusDescription: appointment.statusDescription,
      canCall: appointment.canCall,
      roomName: roomName ?? appointment.roomName,
    );
  }

  Future<void> _onStartPolling(
    StartPolling event,
    Emitter<ReservationState> emit,
  ) async {
    _pollingTimer?.cancel();
    
    // 5초마다 상태 확인 (Push Notification 대체)
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_currentMemberId != null) {
        add(LoadReservations(
          memberId: _currentMemberId!,
          isPollingUpdate: true,
        ));
      }
    });
  }

  Future<void> _onStopPolling(
    StopPolling event,
    Emitter<ReservationState> emit,
  ) async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return '서버 오류가 발생했습니다.';
    } else if (failure is NetworkFailure) {
      return '네트워크 연결을 확인해주세요.';
    } else {
      return '예기치 않은 오류가 발생했습니다.';
    }
  }
}