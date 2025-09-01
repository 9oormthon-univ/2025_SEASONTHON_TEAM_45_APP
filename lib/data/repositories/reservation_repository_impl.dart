import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_api_service.dart';
import '../models/reservation_model.dart';
import '../network/api_endpoints.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationApiService apiService;

  ReservationRepositoryImpl({required this.apiService});

  @override
  Future<Either<Failure, List<Reservation>>> getReservations() async {
    try {
      final response = await apiService.get(ApiEndpoints.reservations);
      
      if (response.data['success'] == true) {
        final List<dynamic> reservationsJson = response.data['data']['reservations'];
        final reservations = reservationsJson
            .map((json) => ReservationModel.fromJson(json))
            .toList();
        return Right(reservations);
      } else {
        return Left(const ServerFailure('예약 목록 조회에 실패했습니다'));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Left(const NetworkFailure());
      }
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    } catch (e) {
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> getReservationById(String id) async {
    try {
      final response = await apiService.get('${ApiEndpoints.reservations}/$id');
      
      if (response.data['success'] == true) {
        final reservation = ReservationModel.fromJson(response.data['data']);
        return Right(reservation);
      } else {
        return Left(const ServerFailure('예약 목록 조회에 실패했습니다'));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Left(const NetworkFailure());
      }
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    } catch (e) {
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> createReservation({
    required String hospitalId,
    required String departmentId,
    required String doctorId,
    required String date,
    required String time,
    required String symptoms,
    required bool isFirstVisit,
  }) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.reservations,
        data: {
          'hospitalId': hospitalId,
          'departmentId': departmentId,
          'doctorId': doctorId,
          'date': date,
          'time': time,
          'symptoms': symptoms,
          'isFirstVisit': isFirstVisit,
        },
      );
      
      if (response.data['success'] == true) {
        // API 응답에서 예약 정보 생성
        final reservation = ReservationModel(
          id: response.data['data']['reservationId'],
          status: response.data['data']['status'],
          date: date,
          time: time,
          department: '내과', // API에서 반환하도록 수정 필요
          hospitalName: '구름병원', // API에서 반환하도록 수정 필요
          doctorName: '김의사', // API에서 반환하도록 수정 필요
          message: response.data['data']['message'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Right(reservation);
      } else {
        return Left(const ServerFailure('예약 목록 조회에 실패했습니다'));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Left(const NetworkFailure());
      }
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    } catch (e) {
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(String reservationId) async {
    try {
      final response = await apiService.delete(
        '${ApiEndpoints.reservations}/$reservationId',
      );
      
      if (response.data['success'] == true) {
        return const Right(null);
      } else {
        return Left(const ServerFailure('예약 목록 조회에 실패했습니다'));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Left(const NetworkFailure());
      }
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    } catch (e) {
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> updateReservationStatus({
    required String reservationId,
    required String status,
    int? callNumber,
    int? waitingNumber,
    int? estimatedWaitTime,
  }) async {
    try {
      final response = await apiService.patch(
        '${ApiEndpoints.reservations}/$reservationId/status',
        data: {
          'status': status,
          'callNumber': callNumber,
          'waitingNumber': waitingNumber,
          'estimatedWaitTime': estimatedWaitTime,
        },
      );
      
      if (response.data['success'] == true) {
        final reservation = ReservationModel.fromJson(response.data['data']);
        return Right(reservation);
      } else {
        return Left(const ServerFailure('예약 목록 조회에 실패했습니다'));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Left(const NetworkFailure());
      }
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    } catch (e) {
      return Left(const ServerFailure('서버 오류가 발생했습니다'));
    }
  }
}