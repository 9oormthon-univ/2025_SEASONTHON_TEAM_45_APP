import 'package:equatable/equatable.dart';
import 'package:carefreepass/domain/entities/ble_device.dart';

abstract class BleState extends Equatable {
  const BleState();

  @override
  List<Object> get props => [];
}

class BleInitial extends BleState {}

class BleScanning extends BleState {
  final List<BleDevice> devices;
  final DateTime lastUpdate;

  const BleScanning({
    required this.devices,
    required this.lastUpdate,
  });

  @override
  List<Object> get props => [devices, lastUpdate];
}

class BleError extends BleState {
  final String message;

  const BleError(this.message);

  @override
  List<Object> get props => [message];
}

class BlePermissionDenied extends BleState {}

class BleBluetoothOff extends BleState {}

class BleIdle extends BleState {
  final List<BleDevice> devices;

  const BleIdle({this.devices = const []});

  @override
  List<Object> get props => [devices];
}