import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:carefreepass/domain/entities/ble_device.dart';

class BleDeviceModel extends BleDevice {
  const BleDeviceModel({
    required super.id,
    required super.name,
    required super.rssi,
    required super.isConnectable,
    required super.lastSeen,
  });

  factory BleDeviceModel.fromScanResult(ScanResult scanResult) {
    return BleDeviceModel(
      id: scanResult.device.remoteId.toString(),
      name: scanResult.device.platformName.isNotEmpty 
          ? scanResult.device.platformName 
          : 'Unknown Device',
      rssi: scanResult.rssi,
      isConnectable: scanResult.advertisementData.connectable,
      lastSeen: DateTime.now(),
    );
  }

  BleDevice toEntity() {
    return BleDevice(
      id: id,
      name: name,
      rssi: rssi,
      isConnectable: isConnectable,
      lastSeen: lastSeen,
    );
  }
}