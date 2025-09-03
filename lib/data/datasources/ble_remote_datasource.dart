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
  static const int rssiThreshold = -100; // RSSI 임계값 (10m 정도)

  @override
  Stream<List<BleDeviceModel>> scanDevices() {
    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (results) async {
        for (ScanResult result in results) {
          // 디버그: 모든 스캔된 디바이스 출력
          final deviceName = result.device.platformName;
          // print('[DEBUG] 스캔된 디바이스: $deviceName, RSSI: ${result.rssi}');
          
          // Advertisement Data 확인
          final advertisementData = result.advertisementData;
          // print('[DEBUG] Complete Local Name: ${advertisementData.advName}');
          // print('[DEBUG] Service UUIDs: ${advertisementData.serviceUuids}');
          // print('[DEBUG] Service Data: ${advertisementData.serviceData}');
          // print('[DEBUG] Manufacturer Data: ${advertisementData.manufacturerData}');
          // print('[DEBUG] Connectable: ${advertisementData.connectable}');
          
          // iOS 전용: Service UUID 확인
          // for (var uuid in advertisementData.serviceUuids) {
          //   print('[DEBUG] Found Service UUID: $uuid');
          // }
          
          // RSSI 필터링
          if (result.rssi < rssiThreshold) {
            // print('[DEBUG] RSSI 필터링됨: $deviceName (RSSI: ${result.rssi} < $rssiThreshold)');
            continue;
          }
          
          // 다양한 방법으로 병원 비콘 확인
          bool isValidHospital = false;
          
          // 1. Device Name 확인
          isValidHospital = CryptoUtils.verifyHospitalBeacon(deviceName);
          
          // 2. Service Data 확인
          if (!isValidHospital && advertisementData.serviceData.isNotEmpty) {
            for (var entry in advertisementData.serviceData.entries) {
              final dataString = String.fromCharCodes(entry.value);
              final dataHex = entry.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
              // print('[DEBUG] Service Data String: $dataString, Hex: $dataHex');
              if (CryptoUtils.verifyHospitalBeacon(dataString) || CryptoUtils.verifyHospitalBeacon(dataHex)) {
                isValidHospital = true;
                break;
              }
            }
          }
          
          // 3. Manufacturer Data 확인
          if (!isValidHospital && advertisementData.manufacturerData.isNotEmpty) {
            for (var entry in advertisementData.manufacturerData.entries) {
              final dataString = String.fromCharCodes(entry.value);
              final dataHex = entry.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
              // print('[DEBUG] Manufacturer Data String: $dataString, Hex: $dataHex');
              if (CryptoUtils.verifyHospitalBeacon(dataString) || CryptoUtils.verifyHospitalBeacon(dataHex)) {
                isValidHospital = true;
                break;
              }
            }
          }
          
          // print('[DEBUG] 최종 검증 결과: $isValidHospital');
          
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
        // print('[BLE] 스캔 에러: $error');
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
        // iOS 호환성을 위한 Service UUID 필터 추가 (선택적)
        // 0x180D는 Heart Rate Service UUID (테스트용)
        // withServices: [Guid("0000180D-0000-1000-8000-00805F9B34FB")],
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
      // iOS에서 위치 권한 먼저 요청
      final locationWhenInUse = await Permission.locationWhenInUse.request();
      
      // 블루투스 권한 상태 확인 (iOS는 Permission.bluetooth만 지원!)
      final bluetoothStatus = await Permission.bluetooth.status;
      
      // 블루투스 권한이 아직 요청되지 않았거나 거부된 경우
      if (!bluetoothStatus.isGranted && !bluetoothStatus.isPermanentlyDenied) {
        try {
          // FlutterBluePlus의 어댑터 상태 확인으로 권한 팝업 트리거
          // iOS에서는 이 호출이 자동으로 권한 팝업을 표시함
          final adapterState = await FlutterBluePlus.adapterState.first;
          
          if (adapterState == BluetoothAdapterState.on) {
            // 블루투스가 켜져 있으면 짧은 스캔으로 권한 팝업 확실히 트리거
            try {
              await FlutterBluePlus.startScan(timeout: const Duration(milliseconds: 100));
              await FlutterBluePlus.stopScan();
            } catch (e) {
              // 권한이 없으면 스캔 실패 - 정상적인 동작
            }
          }
          
          // 잠시 대기 후 권한 상태 재확인
          await Future.delayed(const Duration(milliseconds: 500));
          final newBluetoothStatus = await Permission.bluetooth.status;  // iOS는 bluetooth!
          
          return newBluetoothStatus.isGranted && locationWhenInUse.isGranted;
        } catch (e) {
          // 권한 요청 중 오류 발생
          return false;
        }
      }
      
      return bluetoothStatus.isGranted && locationWhenInUse.isGranted;
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