import 'package:get_it/get_it.dart';
import 'data/datasources/ble_remote_datasource.dart';
import 'data/datasources/reservation_api_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/ble_repository_impl.dart';
import 'data/repositories/reservation_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/ble_repository.dart';
import 'domain/repositories/reservation_repository.dart';
import 'domain/usecases/auto_login.dart';
import 'domain/usecases/cancel_reservation_usecase.dart';
import 'domain/usecases/create_reservation_usecase.dart';
import 'domain/usecases/get_reservations.dart';
import 'domain/usecases/login.dart';
import 'domain/usecases/logout.dart';
import 'domain/usecases/register.dart';
import 'domain/usecases/scan_ble_devices.dart';
import 'domain/usecases/send_sms_code.dart';
import 'domain/usecases/set_auto_login.dart';
import 'domain/usecases/start_scan.dart';
import 'domain/usecases/verify_sms_code.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/ble/ble_bloc.dart';
import 'presentation/bloc/reservation/reservation_bloc.dart';

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
  
  sl.registerFactory(
    () => AuthBloc(
      login: sl(),
      register: sl(),
      autoLogin: sl(),
      logout: sl(),
      setAutoLogin: sl(),
      sendSmsCode: sl(),
      verifySmsCode: sl(),
    ),
  );
  
  sl.registerFactory(
    () => ReservationBloc(
      getReservations: sl(),
      createReservationUseCase: sl(),
      cancelReservationUseCase: sl(),
    ),
  );

  // Use cases - BLE
  sl.registerLazySingleton(() => ScanBleDevices(sl()));
  sl.registerLazySingleton(() => StartScan(sl()));
  
  // Use cases - Auth
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => AutoLogin(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => SetAutoLogin(sl()));
  sl.registerLazySingleton(() => SendSmsCode(sl()));
  sl.registerLazySingleton(() => VerifySmsCode(sl()));
  
  // Use cases - Reservation
  sl.registerLazySingleton(() => GetReservations(sl()));
  sl.registerLazySingleton(() => CreateReservationUseCase(sl()));
  sl.registerLazySingleton(() => CancelReservationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BleRepository>(
    () => BleRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authService: sl(),
    ),
  );
  
  sl.registerLazySingleton<ReservationRepository>(
    () => ReservationRepositoryImpl(apiService: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BleRemoteDataSource>(
    () => BleRemoteDataSourceImpl(),
  );
  
  // Services
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => ReservationApiService(authService: sl()));
  
  // Initialize auth service
  await sl<AuthService>().init();
}