import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_appointment_usecase.dart';
import '../../../domain/usecases/get_available_time_slots.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetAvailableTimeSlots getAvailableTimeSlots;
  final CreateAppointment createAppointment;

  String _selectedDepartment = '';
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  BookingBloc({
    required this.getAvailableTimeSlots,
    required this.createAppointment,
  }) : super(BookingInitial()) {
    on<SelectDepartmentEvent>(_onSelectDepartment);
    on<SelectDateEvent>(_onSelectDate);
    on<LoadAvailableTimeSlotsEvent>(_onLoadAvailableTimeSlots);
    on<SelectTimeSlotEvent>(_onSelectTimeSlot);
    on<CreateAppointmentEvent>(_onCreateAppointment);
  }

  void _onSelectDepartment(SelectDepartmentEvent event, Emitter<BookingState> emit) {
    _selectedDepartment = event.department;
    emit(DepartmentSelected(event.department));
  }

  void _onSelectDate(SelectDateEvent event, Emitter<BookingState> emit) {
    _selectedDate = event.date;
    emit(DateSelected(date: event.date, department: _selectedDepartment));
  }

  Future<void> _onLoadAvailableTimeSlots(
    LoadAvailableTimeSlotsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await getAvailableTimeSlots(
      GetTimeSlotsParams(
        hospitalId: event.hospitalId,
        departmentName: event.departmentName,
        date: event.date,
      ),
    );

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (timeSlotResponse) => emit(
        TimeSlotsLoaded(
          timeSlotResponse: timeSlotResponse,
          selectedDepartment: event.departmentName,
          selectedDate: _selectedDate,
          selectedTime: null,
        ),
      ),
    );
  }

  void _onSelectTimeSlot(SelectTimeSlotEvent event, Emitter<BookingState> emit) {
    _selectedTime = event.time;
    if (state is TimeSlotsLoaded) {
      final currentState = state as TimeSlotsLoaded;
      emit(currentState.copyWith(selectedTime: event.time));
    }
  }

  Future<void> _onCreateAppointment(
    CreateAppointmentEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await createAppointment(
      CreateAppointmentParams(
        memberId: event.memberId,
        hospitalId: event.hospitalId,
        departmentName: event.departmentName,
        appointmentDate: event.appointmentDate,
        appointmentTime: event.appointmentTime,
      ),
    );

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (appointmentId) => emit(AppointmentCreated(appointmentId)),
    );
  }
}