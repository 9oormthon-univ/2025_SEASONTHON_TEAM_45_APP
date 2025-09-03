import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/exceptions.dart';
import '../models/appointment_model.dart';
import '../network/api_endpoints.dart';

class AppointmentService {
  late Dio _dio;
  late SharedPreferences _prefs;

  AppointmentService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        _prefs = await SharedPreferences.getInstance();
        final token = _prefs.getString('access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  // 오늘 내 예약 조회
  Future<List<AppointmentModel>> getTodayAppointments(int memberId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.myTodayAppointments,
        queryParameters: {
          'memberId': memberId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['data'] != null && response.data['data'] is List) {
          return (response.data['data'] as List)
              .map((json) => AppointmentModel.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw ServerException(message: response.data?['message'] ?? '예약 조회 실패');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data?['message'] ?? '예약 조회 실패',
        );
      } else {
        throw ServerException(message: '네트워크 오류가 발생했습니다');
      }
    } catch (e) {
      throw ServerException(message: '예약 조회 중 오류가 발생했습니다');
    }
  }

  // 전체 내 예약 목록 조회
  Future<List<AppointmentModel>> getAllAppointments(int memberId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.myAllAppointments,
        queryParameters: {
          'memberId': memberId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['data'] != null && response.data['data'] is List) {
          return (response.data['data'] as List)
              .map((json) => AppointmentModel.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw ServerException(message: response.data?['message'] ?? '예약 목록 조회 실패');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data?['message'] ?? '예약 목록 조회 실패',
        );
      } else {
        throw ServerException(message: '네트워크 오류가 발생했습니다');
      }
    } catch (e) {
      throw ServerException(message: '예약 목록 조회 중 오류가 발생했습니다');
    }
  }
}