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
          // if (!message.isUser) ...[
          //   CircleAvatar(
          //     radius: 16,
          //     backgroundColor: message.isError
          //         ? Colors.red
          //         : Theme.of(context).colorScheme.secondary,
          //     child: Icon(
          //       message.isError ? Icons.error : Icons.auto_awesome,
          //       size: 16,
          //       color: Theme.of(context).colorScheme.onSecondary,
          //     ),
          //   ),
          //   const SizedBox(width: 8),
          // ],
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
              // child: MarkdownWidget(
              //   data: message.text.isEmpty ? '...' : message.text,
              // ),
            ),
          ),
          // if (message.isUser) ...[
          //   const SizedBox(width: 8),
          //   CircleAvatar(
          //     radius: 16,
          //     backgroundColor: Theme.of(context).colorScheme.primary,
          //     child: Icon(
          //       Icons.person,
          //       size: 16,
          //       color: Theme.of(context).colorScheme.onPrimary,
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
}
