import 'package:equatable/equatable.dart';

abstract class BleEvent extends Equatable {
  const BleEvent();

  @override
  List<Object> get props => [];
}

class StartBleScan extends BleEvent {}

class StopBleScan extends BleEvent {}

class StartScanning extends BleEvent {}

class StopScanning extends BleEvent {}

class CheckPermissions extends BleEvent {}

class DevicesUpdated extends BleEvent {
  final List<dynamic> devices;

  const DevicesUpdated(this.devices);

  @override
  List<Object> get props => [devices];
}