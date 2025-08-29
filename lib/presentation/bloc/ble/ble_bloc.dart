import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:carefreepass/core/usecases/usecase.dart';
import 'package:carefreepass/domain/entities/ble_device.dart';
import 'package:carefreepass/domain/usecases/scan_ble_devices.dart';
import 'package:carefreepass/domain/usecases/start_scan.dart';
import 'package:carefreepass/domain/repositories/ble_repository.dart';
import 'ble_event.dart';
import 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  final ScanBleDevices scanBleDevices;
  final StartScan startScanUseCase;
  final BleRepository repository;
  
  StreamSubscription? _scanSubscription;
  List<BleDevice> _currentDevices = [];

  BleBloc({
    required this.scanBleDevices,
    required this.startScanUseCase,
    required this.repository,
  }) : super(BleInitial()) {
    on<CheckPermissions>(_onCheckPermissions);
    on<StartBleScan>(_onStartBleScan);
    on<StopBleScan>(_onStopBleScan);
    on<DevicesUpdated>(_onDevicesUpdated);
  }

  Future<void> _onCheckPermissions(
    CheckPermissions event,
    Emitter<BleState> emit,
  ) async {
    final bluetoothStatus = await repository.checkBluetoothStatus();
    bluetoothStatus.fold(
      (failure) => emit(BleBluetoothOff()),
      (isOn) async {
        if (isOn) {
          final permissions = await repository.requestPermissions();
          permissions.fold(
            (failure) => emit(BlePermissionDenied()),
            (granted) {
              if (granted) {
                add(StartBleScan());
              }
            },
          );
        }
      },
    );
  }

  Future<void> _onStartBleScan(
    StartBleScan event,
    Emitter<BleState> emit,
  ) async {
    emit(BleScanning(
      devices: _currentDevices,
      lastUpdate: DateTime.now(),
    ));

    final result = await startScanUseCase(NoParams());
    result.fold(
      (failure) => emit(BleError(failure.message)),
      (_) {
        _scanSubscription?.cancel();
        _scanSubscription = scanBleDevices(NoParams()).listen(
          (either) {
            either.fold(
              (failure) => add(DevicesUpdated([])),
              (devices) => add(DevicesUpdated(devices)),
            );
          },
        );
      },
    );
  }

  Future<void> _onStopBleScan(
    StopBleScan event,
    Emitter<BleState> emit,
  ) async {
    await repository.stopScan();
    _scanSubscription?.cancel();
    emit(BleIdle(devices: _currentDevices));
  }

  void _onDevicesUpdated(
    DevicesUpdated event,
    Emitter<BleState> emit,
  ) {
    _currentDevices = event.devices.cast<BleDevice>();
    if (state is BleScanning) {
      emit(BleScanning(
        devices: _currentDevices,
        lastUpdate: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    repository.stopScan();
    return super.close();
  }
}