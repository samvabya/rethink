import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rethink/components/chat_message.dart';

class ChatApi extends ChangeNotifier {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<ChatMessage> messages = [];
  bool isLoading = false;

  static final String? apiKey = dotenv.env['OPENROUTER_API_KEY'];
  static const String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> streamResponse({required String userMessage, required String model}) async {
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'X-Title': 'rethink', // Optional: for OpenRouter
    };

    final body = jsonEncode({
      'model': model, // Free model on OpenRouter
      'messages': [
        ...(messages
            .where((m) => !m.isError)
            .map(
              (m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              },
            )
            .toList()),
        {'role': 'user', 'content': userMessage},
      ],
      'stream': true,
      'max_tokens': 1000,
      'temperature': 0.7,
    });

    final request = http.Request('POST', Uri.parse(baseUrl));
    request.headers.addAll(headers);
    request.body = body;

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode != 200) {
      final errorResponse = await streamedResponse.stream.bytesToString();
      throw Exception('HTTP ${streamedResponse.statusCode}: $errorResponse');
    }

    // Add initial AI message

    messages.add(ChatMessage(text: '', isUser: false));
    notifyListeners();

    final stream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    String currentResponse = '';

    await for (final line in stream) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6);

        if (data == '[DONE]') {
          break;
        }

        try {
          final jsonData = jsonDecode(data);
          final choices = jsonData['choices'] as List?;

          if (choices != null && choices.isNotEmpty) {
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;

            if (content != null) {
              currentResponse += content;

              messages.last = ChatMessage(text: currentResponse, isUser: false);
              notifyListeners();

              // Auto-scroll during streaming
              WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollToBottom();
              });
            }
          }
        } catch (e) {
          // Skip malformed JSON lines
          continue;
        }
      }
    }
  }

  Future<void> sendMessage({required String model}) async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;

    messages.add(ChatMessage(text: message, isUser: true));
    isLoading = true;
    notifyListeners();

    messageController.clear();
    scrollToBottom();

    try {
      await streamResponse(userMessage: message, model: model);
    } catch (e) {
      messages.add(
        ChatMessage(
          text: 'Error: ${e.toString()}',
          isUser: false,
          isError: true,
        ),
      );
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
      scrollToBottom();
    }
  }

  void clearMessages() {
    messages.clear();
    notifyListeners();
  }
}
