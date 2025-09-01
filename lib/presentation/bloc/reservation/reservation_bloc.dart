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
  }

  Future<void> _onLoadReservations(
    LoadReservations event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationLoading());
    
    final result = await getReservations();
    
    result.fold(
      (failure) => emit(ReservationError(message: _mapFailureToMessage(failure))),
      (reservations) => emit(ReservationLoaded(reservations: reservations)),
    );
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