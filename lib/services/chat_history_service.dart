import 'package:flutter/foundation.dart';
import '../components/chat_message.dart';
import '../models/history.dart';
import '../helpers/database_helper.dart';

class ChatHistoryService extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<History> _histories = [];
  bool _isLoading = false;

  List<History> get histories => _histories;
  bool get isLoading => _isLoading;

  // Initialize the service and load histories
  Future<void> initialize() async {
    await loadAllHistories();
  }

  // Load all chat histories from database
  Future<void> loadAllHistories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _histories = await _databaseHelper.getAllHistory();
    } catch (e) {
      debugPrint('Error loading histories: $e');
      _histories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save current chat session to database
  Future<int?> saveChatSession(List<ChatMessage> messages) async {
    if (messages.isEmpty) return null;

    try {
      final history = History(messages: messages);
      final id = await _databaseHelper.insertHistory(history);
      await loadAllHistories(); // Refresh the list
      return id;
    } catch (e) {
      debugPrint('Error saving chat session: $e');
      return null;
    }
  }

  // Update an existing chat session
  Future<bool> updateChatSession(int historyId, List<ChatMessage> messages) async {
    try {
      final existingHistory = await _databaseHelper.getHistory(historyId);
      if (existingHistory == null) return false;

      final updatedHistory = existingHistory.copyWith(messages: messages);
      final result = await _databaseHelper.updateHistory(updatedHistory);
      
      if (result > 0) {
        await loadAllHistories(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating chat session: $e');
      return false;
    }
  }

  // Delete a specific chat history
  Future<bool> deleteHistory(int historyId) async {
    try {
      final result = await _databaseHelper.deleteHistory(historyId);
      if (result > 0) {
        await loadAllHistories(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting history: $e');
      return false;
    }
  }

  // Clear all chat histories
  Future<bool> clearAllHistories() async {
    try {
      final result = await _databaseHelper.deleteAllHistory();
      _histories.clear();
      notifyListeners();
      return result >= 0;
    } catch (e) {
      debugPrint('Error clearing all histories: $e');
      return false;
    }
  }

  // Get a specific history by ID
  Future<History?> getHistory(int historyId) async {
    try {
      return await _databaseHelper.getHistory(historyId);
    } catch (e) {
      debugPrint('Error getting history: $e');
      return null;
    }
  }

  // Search histories by text content
  Future<List<History>> searchHistories(String searchTerm) async {
    if (searchTerm.isEmpty) return _histories;

    try {
      return await _databaseHelper.searchHistory(searchTerm);
    } catch (e) {
      debugPrint('Error searching histories: $e');
      return [];
    }
  }

  // Get recent chat histories
  Future<List<History>> getRecentHistories(int limit) async {
    try {
      return await _databaseHelper.getRecentHistory(limit);
    } catch (e) {
      debugPrint('Error getting recent histories: $e');
      return [];
    }
  }

  // Get total count of chat histories
  Future<int> getHistoryCount() async {
    try {
      return await _databaseHelper.getHistoryCount();
    } catch (e) {
      debugPrint('Error getting history count: $e');
      return 0;
    }
  }

  // Get the first few words of the first user message for display
  String getHistoryTitle(History history) {
    if (history.messages.isEmpty) return 'Empty Chat';

    final firstUserMessage = history.messages.firstWhere(
      (msg) => msg.isUser,
      orElse: () => history.messages.first,
    );

    final words = firstUserMessage.text.trim().split(' ');
    if (words.length <= 6) {
      return firstUserMessage.text.trim();
    }
    return '${words.take(6).join(' ')}...';
  }

  // Get formatted date for history display
  String getFormattedDate(History history) {
    final now = DateTime.now();
    final difference = now.difference(history.updatedAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${history.updatedAt.day}/${history.updatedAt.month}/${history.updatedAt.year}';
    }
  }

  @override
  void dispose() {
    _databaseHelper.closeDatabase();
    super.dispose();
  }
}