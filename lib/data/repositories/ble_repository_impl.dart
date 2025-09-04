import 'package:dartz/dartz.dart';
import 'package:carefreepass/core/error/failures.dart';
import 'package:carefreepass/domain/entities/ble_device.dart';
import 'package:carefreepass/domain/repositories/ble_repository.dart';
import 'package:carefreepass/data/datasources/ble_remote_datasource.dart';

class BleRepositoryImpl implements BleRepository {
  final BleRemoteDataSource remoteDataSource;

  BleRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<BleDevice>>> scanDevices() async* {
    try {
      final stream = remoteDataSource.scanDevices();
      await for (final devices in stream) {
        yield Right(devices.map((model) => model.toEntity()).toList());
      }
    } catch (e) {
      yield Left(ScanFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> startScan({int? appointmentId, int? memberId}) async {
    try {
      await remoteDataSource.startScan(
        appointmentId: appointmentId,
        memberId: memberId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stopScan() async {
    try {
      await remoteDataSource.stopScan();
      return const Right(null);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkBluetoothStatus() async {
    try {
      final isOn = await remoteDataSource.checkBluetoothStatus();
      if (!isOn) {
        return const Left(BluetoothOffFailure());
      }
      return Right(isOn);
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      final granted = await remoteDataSource.requestPermissions();
      if (!granted) {
        return const Left(PermissionDeniedFailure());
      }
      return Right(granted);
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}