import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert ChatMessage to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'isError': isError,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create ChatMessage from Map (JSON deserialization)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      isError: map['isError'] ?? false,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  // Create a copy with updated values
  ChatMessage copyWith({
    String? text,
    bool? isUser,
    bool? isError,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isError: isError ?? this.isError,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'ChatMessage{text: $text, isUser: $isUser, isError: $isError, timestamp: $timestamp}';
  }
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : message.isError
                    ? Colors.red.shade100
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SelectableRegion(
                selectionControls: MaterialTextSelectionControls(),
                child: GptMarkdown(
                  message.text.isEmpty ? '...' : message.text,
                  style: TextStyle(
                    color: message.isUser
                        ? Theme.of(context).colorScheme.onPrimary
                        : message.isError
                        ? Colors.red.shade800
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
