import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
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
  }

  Future<void> _onLoadReservations(
    LoadReservations event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationLoading());
    
    // TODO: 실제 API 연동 전까지 임시 데이터 사용
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    // 테스트용 더미 데이터
    final dummyReservations = [
      Reservation(
        id: '1',
        appointmentId: 1,
        memberId: 1,
        status: 'SCHEDULED',
        date: todayStr,
        time: '14:30',
        department: '내과',
        hospitalName: '구름병원',
        doctorName: '김의사',
        message: '예약시간에 맞게 도착해 주세요',
      ),
      Reservation(
        id: '2',
        appointmentId: 2,
        memberId: 1,
        status: 'SCHEDULED',
        date: '2025-09-05',
        time: '10:00',
        department: '정형외과',
        hospitalName: '구름병원',
        doctorName: '박의사',
        message: '예약시간에 맞게 도착해 주세요',
      ),
    ];
    
    emit(ReservationLoaded(reservations: dummyReservations));
    
    // 실제 API 호출 (주석 처리)
    // final result = await getReservations();
    // 
    // result.fold(
    //   (failure) => emit(ReservationError(message: _mapFailureToMessage(failure))),
    //   (reservations) => emit(ReservationLoaded(reservations: reservations)),
    // );
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
      hospitalName: '구름병원',
      doctorName: '김의사',
      message: '예약이 완료되었습니다',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    emit(ReservationCreated(reservation: newReservation));
    
    // 예약 목록 다시 로드
    add(LoadReservations());
  }

  Future<void> _onCancelReservation(
    CancelReservation event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationLoading());
    
    final result = await cancelReservationUseCase(event.reservationId);
    
    result.fold(
      (failure) => emit(ReservationError(message: _mapFailureToMessage(failure))),
      (_) => add(LoadReservations()),
    );
  }

  Future<void> _onUpdateReservationStatus(
    UpdateReservationStatus event,
    Emitter<ReservationState> emit,
  ) async {
    if (state is ReservationLoaded) {
      final currentState = state as ReservationLoaded;
      final updatedReservations = currentState.reservations.map((reservation) {
        if (reservation.id == event.reservationId) {
          return reservation.copyWith(
            status: event.status,
            callNumber: event.callNumber,
            waitingNumber: event.waitingNumber,
            estimatedWaitTime: event.estimatedWaitTime,
            updatedAt: DateTime.now(),
          );
        }
        return reservation;
      }).toList();
      
      emit(ReservationLoaded(reservations: updatedReservations));
    }
  }

  Future<void> _onRefreshReservation(
    RefreshReservation event,
    Emitter<ReservationState> emit,
  ) async {
    // TODO: 특정 예약 상태 새로고침
    add(LoadReservations());
  }

  Future<void> _onCheckInAppointment(
    CheckInAppointment event,
    Emitter<ReservationState> emit,
  ) async {
    // TODO: API 호출하여 체크인 처리
    // 임시로 상태만 변경
    if (state is ReservationLoaded) {
      final currentState = state as ReservationLoaded;
      final updatedReservations = currentState.reservations.map((reservation) {
        if (reservation.appointmentId.toString() == event.appointmentId) {
          return reservation.copyWith(
            status: 'ARRIVED',
            message: '병원에서 내원여부를 확인했어요',
            updatedAt: DateTime.now(),
          );
        }
        return reservation;
      }).toList();
      
      emit(ReservationLoaded(reservations: updatedReservations));
    }
  }

  Future<void> _onUpdateAppointmentStatus(
    UpdateAppointmentStatus event,
    Emitter<ReservationState> emit,
  ) async {
    if (state is ReservationLoaded) {
      final currentState = state as ReservationLoaded;
      final updatedReservations = currentState.reservations.map((reservation) {
        if (reservation.appointmentId.toString() == event.appointmentId ||
            reservation.id == event.appointmentId) {
          return reservation.copyWith(
            status: event.status,
            roomName: event.roomName,
            message: event.status == 'CALLED' 
              ? '호출된 진료실로 와주세요!' 
              : reservation.message,
            updatedAt: DateTime.now(),
          );
        }
        return reservation;
      }).toList();
      
      emit(ReservationLoaded(reservations: updatedReservations));
    }
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