import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carefreepass/data/models/ble_device_model.dart';
import 'package:carefreepass/core/utils/crypto_utils.dart';
import 'package:carefreepass/data/datasources/api_service.dart';

abstract class BleRemoteDataSource {
  Stream<List<BleDeviceModel>> scanDevices();
  Future<void> startScan();
  Future<void> stopScan();
  Future<bool> checkBluetoothStatus();
  Future<bool> requestPermissions();
}

class BleRemoteDataSourceImpl implements BleRemoteDataSource {
  final StreamController<List<BleDeviceModel>> _devicesController = 
      StreamController<List<BleDeviceModel>>.broadcast();
  final Map<String, BleDeviceModel> _foundDevices = {};
  StreamSubscription? _scanSubscription;
  final Set<String> _reportedDevices = {}; // 이미 보고된 디바이스 추적
  static const int rssiThreshold = -50; // RSSI 임계값

  @override
  Stream<List<BleDeviceModel>> scanDevices() {
    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (results) async {
        for (ScanResult result in results) {
          // RSSI 필터링
          if (result.rssi < rssiThreshold) {
            continue;
          }
          
          // SHA-256 검증
          final deviceName = result.device.platformName;
          final isValidHospital = CryptoUtils.verifyHospitalBeacon(deviceName);
          
          if (isValidHospital) {
            print('====================================');
            print('[BLE] 병원 비콘 감지!');
            print('Device: $deviceName');
            print('RSSI: ${result.rssi}');
            print('====================================');
            
            final device = BleDeviceModel.fromScanResult(result);
            _foundDevices[device.id] = device;
            
            // 자동 POST 요청 (중복 방지)
            if (!_reportedDevices.contains(device.id)) {
              _reportedDevices.add(device.id);
              await ApiService.reportPatientArrival(
                patientId: 'TEMP_USER_001', // TODO: 실제 사용자 ID로 변경
                hospitalId: CryptoUtils.hospitalId,
                rssi: result.rssi,
              );
            }
            
            // 필터링된 디바이스만 UI에 표시
            _devicesController.add(_foundDevices.values.toList());
          }
        }
      },
      onError: (error) {
        print('[BLE] 스캔 에러: $error');
      },
    );
    
    return _devicesController.stream;
  }

  @override
  Future<void> startScan() async {
    try {
      _foundDevices.clear();
      
      // 이미 스캔 중이면 중지
      if (await FlutterBluePlus.isScanning.first) {
        await FlutterBluePlus.stopScan();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      await FlutterBluePlus.startScan(
        timeout: null,
        removeIfGone: const Duration(seconds: 5),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      throw Exception('BLE 스캔 시작 실패: $e');
    }
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
  }

  @override
  Future<bool> checkBluetoothStatus() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      // iOS에서는 블루투스와 위치 권한만 필요
      final bluetooth = await Permission.bluetooth.request();
      final locationWhenInUse = await Permission.locationWhenInUse.request();
      
      return bluetooth.isGranted && locationWhenInUse.isGranted;
    } else if (Platform.isAndroid) {
      // Android에서는 블루투스 스캔/연결 권한
      final bluetoothScan = await Permission.bluetoothScan.request();
      final bluetoothConnect = await Permission.bluetoothConnect.request();
      final locationWhenInUse = await Permission.locationWhenInUse.request();
      
      return bluetoothScan.isGranted && 
             bluetoothConnect.isGranted && 
             locationWhenInUse.isGranted;
    }
    return false;
  }

  void dispose() {
    _scanSubscription?.cancel();
    _devicesController.close();
  }
}