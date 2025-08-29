import 'package:get_it/get_it.dart';
import 'data/datasources/ble_remote_datasource.dart';
import 'data/repositories/ble_repository_impl.dart';
import 'domain/repositories/ble_repository.dart';
import 'domain/usecases/scan_ble_devices.dart';
import 'domain/usecases/start_scan.dart';
import 'presentation/bloc/ble/ble_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () => BleBloc(
      scanBleDevices: sl(),
      startScanUseCase: sl(),
      repository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ScanBleDevices(sl()));
  sl.registerLazySingleton(() => StartScan(sl()));

  // Repository
  sl.registerLazySingleton<BleRepository>(
    () => BleRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BleRemoteDataSource>(
    () => BleRemoteDataSourceImpl(),
  );
}