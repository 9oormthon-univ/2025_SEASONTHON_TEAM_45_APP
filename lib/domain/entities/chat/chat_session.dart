import 'package:equatable/equatable.dart';
import 'chat_message.dart';
import 'symptom_analysis.dart';

enum SessionStatus { active, completed }

class ChatSession extends Equatable {
  final int? sessionId;
  final String title;
  final SessionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final SymptomAnalysis? symptomAnalysis;
  final int? memberId;

  const ChatSession({
    this.sessionId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.symptomAnalysis,
    this.memberId,
  });

  ChatSession copyWith({
    int? sessionId,
    String? title,
    SessionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    SymptomAnalysis? symptomAnalysis,
    int? memberId,
  }) {
    return ChatSession(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      symptomAnalysis: symptomAnalysis ?? this.symptomAnalysis,
      memberId: memberId ?? this.memberId,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        title,
        status,
        createdAt,
        updatedAt,
        messages,
        symptomAnalysis,
        memberId,
      ];
}