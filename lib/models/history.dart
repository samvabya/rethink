import 'dart:convert';
import '../components/chat_message.dart';

class History {
  final int? id;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  History({
    this.id,
    required this.messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Convert History to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'messages': jsonEncode(messages.map((msg) => msg.toMap()).toList()),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create History from Map (database row)
  factory History.fromMap(Map<String, dynamic> map) {
    List<dynamic> messagesJson = jsonDecode(map['messages']);
    List<ChatMessage> messages = messagesJson
        .map((msgMap) => ChatMessage.fromMap(msgMap))
        .toList();

    return History(
      id: map['id'],
      messages: messages,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Create a copy with updated values
  History copyWith({
    int? id,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return History(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'History{id: $id, messages: ${messages.length}, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}