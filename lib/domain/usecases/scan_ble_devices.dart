import 'package:dartz/dartz.dart';
import 'package:carefreepass/core/error/failures.dart';
import 'package:carefreepass/core/usecases/usecase.dart';
import 'package:carefreepass/domain/entities/ble_device.dart';
import 'package:carefreepass/domain/repositories/ble_repository.dart';

class ScanBleDevices extends StreamUseCase<List<BleDevice>, NoParams> {
  final BleRepository repository;

  ScanBleDevices(this.repository);

  @override
  Stream<Either<Failure, List<BleDevice>>> call(NoParams params) {
    return repository.scanDevices();
  }
}