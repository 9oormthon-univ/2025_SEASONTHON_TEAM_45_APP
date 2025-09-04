import 'package:dio/dio.dart';
import '../models/chat/chat_session_model.dart';
import '../network/api_endpoints.dart';

class ChatApiService {
  final Dio _dio;

  ChatApiService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // 채팅 세션 시작
  Future<ChatSessionModel> startChatSession(int memberId, String initialMessage) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.chatStart,
        data: {
          'memberId': memberId,
          'initialMessage': initialMessage,
        },
      );

      if (response.statusCode == 200) {
        // 응답 구조에 따라 처리
        final data = response.data;
        final sessionData = data is Map<String, dynamic> 
            ? (data['body'] ?? data['data'] ?? data)
            : data;
        
        print('ChatApiService - Response data: $sessionData');
        return ChatSessionModel.fromJson(sessionData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to start chat session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('ChatApiService - DioException: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('ChatApiService - Error: $e');
      throw Exception('Failed to start chat session: $e');
    }
  }

  // 메시지 전송
  Future<Map<String, dynamic>> sendMessage(int sessionId, int memberId, String content) async {
    try {
      print('ChatApiService - Sending message: sessionId=$sessionId, memberId=$memberId, content=$content');
      
      final response = await _dio.post(
        ApiEndpoints.chatMessage,
        data: {
          'sessionId': sessionId,
          'memberId': memberId,
          'content': content,
        },
      );

      print('ChatApiService - Response status: ${response.statusCode}');
      print('ChatApiService - Response data: ${response.data}');

      if (response.statusCode == 200) {
        // 응답 구조에 따라 처리
        final data = response.data;
        final responseBody = data is Map<String, dynamic> 
            ? (data['body'] ?? data['data'] ?? data)
            : data;
        
        print('ChatApiService - Parsed response: $responseBody');
        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('ChatApiService - DioException: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('ChatApiService - Error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // 채팅 세션 상세 조회
  Future<ChatSessionModel> getChatSession(int sessionId, int memberId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.chatSessionDetail}/$sessionId',
        queryParameters: {'memberId': memberId},
      );

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get chat session');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  // 사용자 채팅 세션 목록 조회
  Future<List<ChatSessionModel>> getChatSessions(int memberId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.chatSessionList,
        queryParameters: {'memberId': memberId},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => ChatSessionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get chat sessions');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  // 채팅 세션 완료
  Future<void> completeChatSession(int sessionId, int memberId) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.chatComplete}/$sessionId/complete',
        queryParameters: {'memberId': memberId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to complete chat session');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}