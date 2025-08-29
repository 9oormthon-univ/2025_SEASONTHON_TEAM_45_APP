import 'package:dartz/dartz.dart';
import 'package:carefreepass/core/error/failures.dart';
import 'package:carefreepass/core/usecases/usecase.dart';
import 'package:carefreepass/domain/repositories/ble_repository.dart';

class StartScan extends UseCase<void, NoParams> {
  final BleRepository repository;

  StartScan(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.startScan();
  }
}