import '../../../domain/entities/chat/chat_session.dart';
import '../../../domain/entities/chat/chat_message.dart';
import '../../../domain/entities/chat/symptom_analysis.dart';
import 'chat_message_model.dart';
import 'symptom_analysis_model.dart';

class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    int? sessionId,
    required String title,
    required SessionStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<ChatMessage> messages,
    SymptomAnalysis? symptomAnalysis,
    int? memberId,
  }) : super(
          sessionId: sessionId,
          title: title,
          status: status,
          createdAt: createdAt,
          updatedAt: updatedAt,
          messages: messages,
          symptomAnalysis: symptomAnalysis,
          memberId: memberId,
        );

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      sessionId: json['sessionId'] as int?,
      title: json['title'] as String? ?? '증상 상담',
      status: _parseSessionStatus(json['status'] as String? ?? 'ACTIVE'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      symptomAnalysis: json['symptomAnalysis'] != null
          ? SymptomAnalysisModel.fromJson(
              json['symptomAnalysis'] as Map<String, dynamic>)
          : null,
      memberId: json['memberId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'title': title,
      'status': status == SessionStatus.active ? 'ACTIVE' : 'COMPLETED',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages
          .map((e) => ChatMessageModel(
                messageId: e.messageId,
                senderType: e.senderType,
                content: e.content,
                sequenceNumber: e.sequenceNumber,
                createdAt: e.createdAt,
              ).toJson())
          .toList(),
      'symptomAnalysis': symptomAnalysis != null
          ? SymptomAnalysisModel(
              analysisId: symptomAnalysis!.analysisId,
              extractedSymptoms: symptomAnalysis!.extractedSymptoms,
              recommendedDepartment: symptomAnalysis!.recommendedDepartment,
              confidenceScore: symptomAnalysis!.confidenceScore,
              analysisSummary: symptomAnalysis!.analysisSummary,
              additionalQuestions: symptomAnalysis!.additionalQuestions,
            ).toJson()
          : null,
      'memberId': memberId,
    };
  }

  static SessionStatus _parseSessionStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return SessionStatus.active;
      case 'COMPLETED':
        return SessionStatus.completed;
      default:
        throw Exception('Unknown session status: $status');
    }
  }
}