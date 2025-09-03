import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/exceptions.dart';
import '../models/time_slot_model.dart';
import '../network/api_endpoints.dart';

class BookingService {
  late Dio _dio;
  late SharedPreferences _prefs;

  BookingService() {
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

  Future<TimeSlotResponseModel> getAvailableTimeSlots({
    required int hospitalId,
    required String departmentName,
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.availableTimeSlots,
        queryParameters: {
          'hospitalId': hospitalId,
          'departmentName': departmentName,
          'date': date,
        },
      );

      print('Time slots API Response: $response');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        final code = responseData['code'];
        final data = responseData['data'];

        if (code == 'TIME_SLOT_1001' && data != null) {
          return TimeSlotResponseModel.fromJson(data);
        } else {
          throw ServerException(
            message: responseData['message'] ?? '시간대 조회에 실패했습니다',
          );
        }
      } else {
        throw ServerException(message: '시간대 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      print('Time slots API Error: ${e.toString()}');
      if (e.response?.statusCode == 404) {
        throw ServerException(message: '예약 가능한 시간대가 없습니다');
      }
      throw ServerException(
        message: e.response?.data['message'] ?? '네트워크 오류가 발생했습니다',
      );
    } catch (e) {
      print('Unexpected error in getAvailableTimeSlots: $e');
      throw ServerException(message: '예상치 못한 오류가 발생했습니다');
    }
  }

  Future<int> createAppointment({
    required int memberId,
    required int hospitalId,
    required String departmentName,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    try {
      final requestData = {
        'memberId': memberId,
        'hospitalId': hospitalId,
        'departmentName': departmentName,
        'appointmentDate': appointmentDate,
        'appointmentTime': appointmentTime,
      };
      
      print('Create appointment API Request: $requestData');
      
      final response = await _dio.post(
        ApiEndpoints.createAppointment,
        data: requestData,
      );

      print('Create appointment API Response: $response');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        final code = responseData['code'];
        final data = responseData['data'];

        if (code == 'APPOINTMENT_4001' && data != null) {
          // data가 숫자로 직접 오는 경우 처리
          if (data is int) {
            return data;
          }
          // data가 객체로 오는 경우 처리
          return data['appointmentId'] ?? data['id'] ?? 0;
        } else {
          throw ServerException(
            message: responseData['message'] ?? '예약 생성에 실패했습니다',
          );
        }
      } else {
        throw ServerException(message: '예약 생성에 실패했습니다');
      }
    } on DioException catch (e) {
      print('Create appointment API Error: ${e.toString()}');
      if (e.response?.statusCode == 409) {
        throw ServerException(message: '이미 해당 시간에 예약이 있습니다');
      }
      throw ServerException(
        message: e.response?.data['message'] ?? '네트워크 오류가 발생했습니다',
      );
    } catch (e) {
      print('Unexpected error in createAppointment: $e');
      throw ServerException(message: '예상치 못한 오류가 발생했습니다');
    }
  }
}