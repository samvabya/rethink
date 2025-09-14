import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rethink/components/chat_message.dart';
import 'package:rethink/models/history.dart';

class ChatApi extends ChangeNotifier {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<ChatMessage> messages = [];
  bool isLoading = false;
  
  // Current chat session ID (null for new chats)
  int? _currentHistoryId;
  
  // Auto-save functionality
  bool _autoSaveEnabled = true;
  DateTime? _lastSaveTime;
  static const Duration _autoSaveInterval = Duration(seconds: 30);

  static final String? apiKey = dotenv.env['OPENROUTER_API_KEY'];
  static const String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  int? get currentHistoryId => _currentHistoryId;
  bool get autoSaveEnabled => _autoSaveEnabled;

  void setAutoSave(bool enabled) {
    _autoSaveEnabled = enabled;
    notifyListeners();
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Auto-save functionality
  void _triggerAutoSave() {
    if (!_autoSaveEnabled || messages.isEmpty) return;
    
    final now = DateTime.now();
    if (_lastSaveTime == null || 
        now.difference(_lastSaveTime!) >= _autoSaveInterval) {
      _saveCurrentChat();
      _lastSaveTime = now;
    }
  }

  Future<void> _saveCurrentChat() async {
    // This will be called by the UI to inject the history service
    // We'll use a callback pattern to avoid circular dependencies
    _onSaveRequested?.call();
  }

  // Callback for saving - set by the UI
  VoidCallback? _onSaveRequested;

  void setSaveCallback(VoidCallback callback) {
    _onSaveRequested = callback;
  }

  Future<void> streamResponse({required String userMessage, required String model}) async {
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'X-Title': 'rethink',
    };

    final body = jsonEncode({
      'model': model,
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
      
      // Trigger auto-save after successful message
      _triggerAutoSave();
      
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

  // Load a chat history into the current session
  void loadChatHistory(History history) {
    // Save current chat before loading new one
    if (messages.isNotEmpty && _autoSaveEnabled) {
      _saveCurrentChat();
    }
    
    messages.clear();
    messages.addAll(history.messages);
    _currentHistoryId = history.id;
    
    notifyListeners();
    
    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  // Start a new chat session
  void startNewChat() {
    // Save current chat before starting new one
    if (messages.isNotEmpty && _autoSaveEnabled) {
      _saveCurrentChat();
    }
    
    clearMessages();
    _currentHistoryId = null;
  }

  // Clear messages (used for new chat)
  void clearMessages() {
    messages.clear();
    _currentHistoryId = null;
    _lastSaveTime = null;
    notifyListeners();
  }

  // Get a summary of the current chat for display
  String getCurrentChatSummary() {
    if (messages.isEmpty) return 'New Chat';
    
    final firstUserMessage = messages.firstWhere(
      (msg) => msg.isUser && msg.text.isNotEmpty,
      orElse: () => messages.first,
    );
    
    final words = firstUserMessage.text.trim().split(' ');
    if (words.length <= 4) {
      return firstUserMessage.text.trim();
    }
    return '${words.take(4).join(' ')}...';
  }

  // Check if current chat has unsaved changes
  bool hasUnsavedChanges() {
    if (messages.isEmpty) return false;
    if (_currentHistoryId == null) return true; // New chat with messages
    
    // Check if there have been new messages since last save
    return _lastSaveTime == null || 
           messages.isNotEmpty && 
           messages.last.timestamp.isAfter(_lastSaveTime!);
  }

  // Manual save method
  Future<void> saveCurrentChat() async {
    if (messages.isNotEmpty) {
      _saveCurrentChat();
    }
  }

  // Update the current history ID after saving
  void updateCurrentHistoryId(int historyId) {
    _currentHistoryId = historyId;
    _lastSaveTime = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}