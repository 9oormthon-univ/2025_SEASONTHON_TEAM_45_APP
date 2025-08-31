import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class BluetoothOffFailure extends Failure {
  const BluetoothOffFailure() : super('블루투스가 꺼져 있습니다');
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure() : super('권한이 거부되었습니다');
}

class ScanFailure extends Failure {
  const ScanFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('알 수 없는 오류가 발생했습니다');
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}