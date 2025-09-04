import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'injection_container.dart' as di;
import 'core/constants/app_colors.dart';
import 'presentation/bloc/ble/ble_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/notification/notification_bloc.dart';
import 'presentation/views/login_initial_view.dart';
import 'presentation/views/login_input_view.dart';
import 'presentation/views/signup_view.dart';
import 'presentation/views/permission_settings_view.dart';
import 'presentation/views/ble_scan_view.dart';
import 'presentation/views/home_view.dart';
import 'presentation/views/settings_view.dart';
import 'presentation/views/profile_management_view.dart';
import 'presentation/bloc/reservation/reservation_bloc.dart';
import 'core/utils/crypto_utils.dart';
import 'data/datasources/api_service.dart';
import 'data/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.handleBackgroundMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  await di.init();
  
  // ApiService 초기화
  await ApiService.init();
  
  // nRF Connect 설정용 해시값 출력
  CryptoUtils.printHashForNRFConnect();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: MaterialApp(
        title: 'CareFreePass',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
          useMaterial3: true,
          fontFamily: 'Pretendard',
          primaryColor: AppColors.primaryGreen,
        ),
        home: const LoginInitialView(),
        routes: {
          '/login': (context) => const LoginInitialView(),
          '/login_input': (context) => const LoginInputView(),
          '/signup': (context) => const SignupView(),
          '/permission_check': (context) => const PermissionSettingsView(),
          '/home': (context) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => di.sl<ReservationBloc>()),
              BlocProvider(create: (_) => di.sl<NotificationBloc>()..add(InitializeNotifications())),
            ],
            child: const HomeView(),
          ),
          '/settings': (context) => const SettingsView(),
          '/profile_management': (context) => const ProfileManagementView(),
          '/ble_scan': (context) => BlocProvider(
            create: (_) => di.sl<BleBloc>(),
            child: const BleScanView(),
          ),
        },
      ),
    );
  }
}