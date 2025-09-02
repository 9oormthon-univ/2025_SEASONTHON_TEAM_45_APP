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
    on<StartScanning>(_onStartScanning);
    on<StopScanning>(_onStopScanning);
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
                // 권한이 허용되면 자동으로 스캔 시작
                add(StartBleScan());
              } else {
                emit(BlePermissionDenied());
              }
            },
          );
        } else {
          emit(BleBluetoothOff());
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
    
    // 병원 비콘 감지 로직
    const targetServiceData = '354544344134343539434131'; // 병원 비콘 해시값
    for (final device in _currentDevices) {
      // Service Data 확인 (실제 구현은 BLE 패키지에 따라 다를 수 있음)
      // 임시로 디바이스 이름이 'H'인 경우 병원 비콘으로 간주
      if (device.name == 'H' && device.rssi > -100) {
        emit(HospitalBeaconDetected(
          deviceName: device.name,
          rssi: device.rssi,
        ));
        return;
      }
    }
    
    if (state is BleScanning) {
      emit(BleScanning(
        devices: _currentDevices,
        lastUpdate: DateTime.now(),
      ));
    }
  }
  
  Future<void> _onStartScanning(
    StartScanning event,
    Emitter<BleState> emit,
  ) async {
    // StartBleScan과 동일한 동작
    add(StartBleScan());
  }
  
  Future<void> _onStopScanning(
    StopScanning event,
    Emitter<BleState> emit,
  ) async {
    // StopBleScan과 동일한 동작
    add(StopBleScan());
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    repository.stopScan();
    return super.close();
  }
}