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
    // print('[BleBloc] _onCheckPermissions 호출');
    final bluetoothStatus = await repository.checkBluetoothStatus();
    bluetoothStatus.fold(
      (failure) {
        // print('[BleBloc] 블루투스 OFF');
        emit(BleBluetoothOff());
      },
      (isOn) async {
        if (isOn) {
          // print('[BleBloc] 블루투스 ON - 권한 요청');
          final permissions = await repository.requestPermissions();
          permissions.fold(
            (failure) {
              // print('[BleBloc] 권한 거부됨');
              emit(BlePermissionDenied());
            },
            (granted) {
              if (granted) {
                // print('[BleBloc] 권한 허용됨');
                // 권한 허용 상태만 알리고 스캔은 StartScanning 이벤트를 기다림
                // StartBleScan을 호출하지 않음
              } else {
                // print('[BleBloc] 권한 거부됨');
                emit(BlePermissionDenied());
              }
            },
          );
        } else {
          // print('[BleBloc] 블루투스 OFF');
          emit(BleBluetoothOff());
        }
      },
    );
  }

  Future<void> _onStartBleScan(
    StartBleScan event,
    Emitter<BleState> emit,
  ) async {
    // print('[BleBloc] _onStartBleScan 호출');
    emit(BleScanning(
      devices: _currentDevices,
      lastUpdate: DateTime.now(),
    ));

    final result = await startScanUseCase(NoParams());
    result.fold(
      (failure) {
        // print('[BleBloc] 스캔 시작 실패: ${failure.message}');
        emit(BleError(failure.message));
      },
      (_) {
        // print('[BleBloc] 스캔 시작 성공 - 스트림 구독');
        _scanSubscription?.cancel();
        _scanSubscription = scanBleDevices(NoParams()).listen(
          (either) {
            either.fold(
              (failure) => add(DevicesUpdated([])),
              (devices) {
                // print('[BleBloc] 디바이스 업데이트: ${devices.length}개');
                add(DevicesUpdated(devices));
              },
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
    // print('[BleBloc] _onStartScanning 호출 - appointmentId: ${event.appointmentId}, memberId: ${event.memberId}');
    
    // BLE 스캔 상태로 변경
    emit(BleScanning(
      devices: _currentDevices,
      lastUpdate: DateTime.now(),
    ));
    
    // appointmentId와 memberId를 전달하여 스캔 시작
    final result = await repository.startScan(
      appointmentId: event.appointmentId,
      memberId: event.memberId,
    );
    
    result.fold(
      (failure) {
        // print('[BleBloc] 스캔 시작 실패: ${failure.message}');
        emit(BleError(failure.message));
      },
      (_) {
        // print('[BleBloc] 스캔 시작 성공 - 스트림 구독');
        _scanSubscription?.cancel();
        _scanSubscription = scanBleDevices(NoParams()).listen(
          (either) {
            either.fold(
              (failure) => add(DevicesUpdated([])),
              (devices) {
                // print('[BleBloc] 디바이스 업데이트: ${devices.length}개');
                add(DevicesUpdated(devices));
              },
            );
          },
        );
      },
    );
  }
  
  Future<void> _onStopScanning(
    StopScanning event,
    Emitter<BleState> emit,
  ) async {
    // BleBloc이 닫히지 않았을 때만 이벤트 추가
    if (!isClosed) {
      // StopBleScan과 동일한 동작
      add(StopBleScan());
    } else {
      // 이미 닫힌 경우 직접 처리
      await repository.stopScan();
      _scanSubscription?.cancel();
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    repository.stopScan();
    return super.close();
  }
}