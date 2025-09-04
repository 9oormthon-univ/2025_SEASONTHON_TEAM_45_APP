import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../network/api_endpoints.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _channel != null;

  // 웹소켓 연결
  Future<void> connect(int memberId) async {
    try {
      // URL 생성 및 로깅 (ws:// 명시적 사용)
      final wsUrlString = '${ApiEndpoints.wsBaseUrl}${ApiEndpoints.wsChat}/$memberId';
      print('Attempting WebSocket connection to: $wsUrlString');
      
      // WebSocket 직접 연결
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrlString),
      );
      
      _channel!.stream.listen(
        (message) {
          final data = json.decode(message);
          _messageController.add(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _messageController.addError(error);
        },
        onDone: () {
          print('WebSocket connection closed');
          disconnect();
        },
      );
      
      print('WebSocket connected successfully');
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      // 웹소켓 연결 실패해도 HTTP로 계속 진행 가능하므로 Exception 대신 로깅만
      // throw Exception('WebSocket connection failed: $e');
    }
  }

  // 메시지 전송
  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    } else {
      throw Exception('WebSocket is not connected');
    }
  }

  // 타이핑 이벤트 전송
  void sendTypingEvent(bool isTyping) {
    sendMessage({
      'type': 'typing',
      'isTyping': isTyping,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // 연결 종료
  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}