import 'package:dartz/dartz.dart';
import 'package:carefreepass/domain/entities/ble_device.dart';
import 'package:carefreepass/core/error/failures.dart';

abstract class BleRepository {
  Stream<Either<Failure, List<BleDevice>>> scanDevices();
  Future<Either<Failure, void>> startScan();
  Future<Either<Failure, void>> stopScan();
  Future<Either<Failure, bool>> checkBluetoothStatus();
  Future<Either<Failure, bool>> requestPermissions();
}