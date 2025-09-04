import 'package:flutter/material.dart';
import '../../domain/entities/chat/chat_session.dart';
import '../../domain/entities/chat/chat_message.dart';
import '../../domain/entities/chat/symptom_analysis.dart';
import '../../data/services/chat_api_service.dart';
import '../../data/services/websocket_service.dart';
import '../../data/models/chat/chat_message_model.dart';
import '../../data/models/chat/symptom_analysis_model.dart';

class ChatProvider with ChangeNotifier {
  final ChatApiService _apiService = ChatApiService();
  final WebSocketService _wsService = WebSocketService();
  
  ChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _errorMessage;
  int? _memberId;

  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;

  // 채팅 세션 시작
  Future<void> startChatSession(int memberId, String initialMessage) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _memberId = memberId;
      notifyListeners();

      // API 호출로 세션 시작
      final session = await _apiService.startChatSession(memberId, initialMessage);
      _currentSession = session;
      _messages = session.messages;

      // 웹소켓 연결 (선택적)
      try {
        await _wsService.connect(memberId);
        _setupWebSocketListener();
      } catch (wsError) {
        // 웹소켓 연결 실패해도 HTTP API로 계속 진행
        print('WebSocket connection failed, continuing with HTTP only: $wsError');
      }

      // 환영 메시지 추가
      if (_messages.isEmpty) {
        _addMessage(ChatMessageModel(
          senderType: SenderType.ai,
          content: '안녕하세요! AI 병원 예약 도우미입니다. 어떤 증상으로 문의해주셨나요? 자세히 말씀해 주시면 적절한 진료과를 추천해 드리겠습니다.',
          sequenceNumber: 1,
          createdAt: DateTime.now(),
        ));
      }

    } catch (e) {
      _errorMessage = '채팅 시작에 실패했습니다: $e';
      print('Failed to start chat session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 메시지 전송
  Future<void> sendMessage(String content) async {
    if (_currentSession == null || _memberId == null) {
      _errorMessage = '채팅 세션이 시작되지 않았습니다';
      notifyListeners();
      return;
    }

    // 사용자 메시지 즉시 추가
    final userMessage = ChatMessageModel(
      senderType: SenderType.user,
      content: content,
      sequenceNumber: _messages.length + 1,
      createdAt: DateTime.now(),
    );
    _addMessage(userMessage);

    try {
      _isTyping = true;
      notifyListeners();

      // 웹소켓이 연결되어 있으면 웹소켓으로 전송
      if (_wsService.isConnected) {
        _wsService.sendMessage({
          'type': 'chat_message',
          'sessionId': _currentSession!.sessionId,
          'message': content,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        print('ChatProvider - Using HTTP API for message');
        // HTTP API로 전송
        final response = await _apiService.sendMessage(
          _currentSession!.sessionId!,
          _memberId!,
          content,
        );

        print('ChatProvider - API Response: $response');

        // AI 응답 처리 - ChatApiService는 이미 data 필드를 추출해서 리턴함
        // 1. 직접 AI 메시지인 경우 (현재 API 구조)
        if (response['senderType'] == 'AI') {
          print('ChatProvider - Found direct AI message');
          final aiMessage = ChatMessageModel.fromJson(response);
          _addMessage(aiMessage);
        }
        // 2. aiResponse 키가 있는 경우
        else if (response['aiResponse'] != null) {
          print('ChatProvider - Found aiResponse');
          final aiMessage = ChatMessageModel.fromJson(response['aiResponse']);
          _addMessage(aiMessage);
        }
        // 3. messages 배열에 AI 응답이 있는 경우
        else if (response['messages'] != null && response['messages'] is List) {
          print('ChatProvider - Found messages array');
          final messages = response['messages'] as List;
          for (var msg in messages) {
            if (msg['senderType'] == 'AI') {
              final aiMessage = ChatMessageModel.fromJson(msg);
              _addMessage(aiMessage);
              break;
            }
          }
        }
        // 4. data 필드에 AI 응답이 있는 경우 (서버가 다른 형식으로 응답하는 경우)
        else if (response['data'] != null && response['data']['senderType'] == 'AI') {
          print('ChatProvider - Found AI response in data field');
          final aiMessage = ChatMessageModel.fromJson(response['data']);
          _addMessage(aiMessage);
        }
        // 5. 기본 AI 응답 추가 (응답이 없는 경우)
        else {
          print('ChatProvider - No AI response found, adding default');
          _addMessage(ChatMessageModel(
            senderType: SenderType.ai,
            content: '죄송합니다. 응답을 처리하는 중 문제가 발생했습니다.',
            sequenceNumber: _messages.length + 1,
            createdAt: DateTime.now(),
          ));
        }

        // 분석 결과 업데이트
        if (response['updatedAnalysis'] != null) {
          final analysis = SymptomAnalysisModel.fromJson(response['updatedAnalysis']);
          _updateAnalysis(analysis);
        } else if (response['symptomAnalysis'] != null) {
          final analysis = SymptomAnalysisModel.fromJson(response['symptomAnalysis']);
          _updateAnalysis(analysis);
        }
      }

    } catch (e) {
      _errorMessage = '메시지 전송에 실패했습니다: $e';
      print('Failed to send message: $e');
      
      // 오류 메시지 추가
      _addMessage(ChatMessageModel(
        senderType: SenderType.ai,
        content: '죄송합니다. 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
        sequenceNumber: _messages.length + 1,
        createdAt: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // 웹소켓 리스너 설정
  void _setupWebSocketListener() {
    _wsService.messageStream.listen(
      (data) {
        if (data['type'] == 'chat_message') {
          // AI 응답 메시지 처리
          final message = ChatMessageModel.fromJson(data['message']);
          _addMessage(message);
        } else if (data['type'] == 'analysis_update') {
          // 분석 업데이트 처리
          final analysis = SymptomAnalysisModel.fromJson(data['analysis']);
          _updateAnalysis(analysis);
        } else if (data['type'] == 'typing') {
          // AI 타이핑 상태 처리
          _isTyping = data['isTyping'] ?? false;
          notifyListeners();
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _errorMessage = 'Connection error: $error';
        notifyListeners();
      },
    );
  }

  // 메시지 추가
  void _addMessage(ChatMessage message) {
    _messages.insert(0, message); // 최신 메시지를 앞에 추가
    notifyListeners();
  }

  // 증상 분석 업데이트
  void _updateAnalysis(SymptomAnalysis analysis) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(symptomAnalysis: analysis);
      notifyListeners();
    }
  }

  // 채팅 세션 완료
  Future<void> completeChatSession() async {
    if (_currentSession == null || _memberId == null) return;

    try {
      await _apiService.completeChatSession(_currentSession!.sessionId!, _memberId!);
      _currentSession = _currentSession!.copyWith(status: SessionStatus.completed);
      notifyListeners();
    } catch (e) {
      _errorMessage = '세션 완료에 실패했습니다: $e';
      print('Failed to complete chat session: $e');
      notifyListeners();
    }
  }

  // 채팅 세션 목록 가져오기
  Future<List<ChatSession>> getChatSessions(int memberId) async {
    try {
      final sessions = await _apiService.getChatSessions(memberId);
      return sessions;
    } catch (e) {
      _errorMessage = '채팅 목록을 불러오는데 실패했습니다: $e';
      print('Failed to get chat sessions: $e');
      notifyListeners();
      return [];
    }
  }

  // 예약하기 호출
  void navigateToAppointment(String department) {
    // 진료과 정보와 함께 예약 화면으로 이동
    // 실제 구현은 UI 레벨에서 처리
    notifyListeners();
  }

  // 리셋
  void reset() {
    _currentSession = null;
    _messages = [];
    _isLoading = false;
    _isTyping = false;
    _errorMessage = null;
    _wsService.disconnect();
    notifyListeners();
  }

  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }
}