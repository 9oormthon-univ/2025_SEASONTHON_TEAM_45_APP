import 'package:equatable/equatable.dart';

enum SenderType { user, ai }

class ChatMessage extends Equatable {
  final int? messageId;
  final SenderType senderType;
  final String content;
  final int sequenceNumber;
  final DateTime createdAt;

  const ChatMessage({
    this.messageId,
    required this.senderType,
    required this.content,
    required this.sequenceNumber,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        messageId,
        senderType,
        content,
        sequenceNumber,
        createdAt,
      ];
}