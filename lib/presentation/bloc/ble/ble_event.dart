import 'package:equatable/equatable.dart';

abstract class BleEvent extends Equatable {
  const BleEvent();

  @override
  List<Object> get props => [];
}

class StartBleScan extends BleEvent {}

class StopBleScan extends BleEvent {}

class StartScanning extends BleEvent {
  final int? appointmentId;
  final int? memberId;
  
  const StartScanning({this.appointmentId, this.memberId});
  
  @override
  List<Object> get props => [
    if (appointmentId != null) appointmentId!,
    if (memberId != null) memberId!,
  ];
}

class StopScanning extends BleEvent {}

class CheckPermissions extends BleEvent {}

class DevicesUpdated extends BleEvent {
  final List<dynamic> devices;

  const DevicesUpdated(this.devices);

  @override
  List<Object> get props => [devices];
}