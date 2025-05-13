// lib/core/models/chat_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String requestId;
  final String clientId;
  final String technicianId;
  final DateTime createdAt;
  final DateTime? lastMessageTime;
  final String? lastMessage;
  final bool isActive;

  ChatModel({
    required this.id,
    required this.requestId,
    required this.clientId,
    required this.technicianId,
    required this.createdAt,
    this.lastMessageTime,
    this.lastMessage,
    this.isActive = true,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      requestId: data['requestId'] ?? '',
      clientId: data['clientId'] ?? '',
      technicianId: data['technicianId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessageTime:
          data['lastMessageTime'] != null
              ? (data['lastMessageTime'] as Timestamp).toDate()
              : null,
      lastMessage: data['lastMessage'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requestId': requestId,
      'clientId': clientId,
      'technicianId': technicianId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessage': lastMessage,
      'isActive': isActive,
    };
  }
}
