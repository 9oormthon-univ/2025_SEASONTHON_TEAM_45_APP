import '../../../domain/entities/chat/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    int? messageId,
    required SenderType senderType,
    required String content,
    required int sequenceNumber,
    required DateTime createdAt,
  }) : super(
          messageId: messageId,
          senderType: senderType,
          content: content,
          sequenceNumber: sequenceNumber,
          createdAt: createdAt,
        );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['messageId'] as int?,
      senderType: _parseSenderType(json['senderType'] as String? ?? 'USER'),
      content: json['content'] as String? ?? '',
      sequenceNumber: json['sequenceNumber'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderType': senderType == SenderType.user ? 'USER' : 'AI',
      'content': content,
      'sequenceNumber': sequenceNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static SenderType _parseSenderType(String type) {
    switch (type.toUpperCase()) {
      case 'USER':
        return SenderType.user;
      case 'AI':
        return SenderType.ai;
      default:
        throw Exception('Unknown sender type: $type');
    }
  }
}