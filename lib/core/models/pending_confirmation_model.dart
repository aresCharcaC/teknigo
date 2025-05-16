import 'package:cloud_firestore/cloud_firestore.dart';

class PendingConfirmationModel {
  final String id;
  final String serviceId;
  final String chatId;
  final String technicianId;
  final String clientId;
  final DateTime createdAt;
  final String serviceTitle;
  final bool isResolved;
  final String? resolution; // 'accepted' or 'rejected'
  final DateTime? resolvedAt;

  PendingConfirmationModel({
    required this.id,
    required this.serviceId,
    required this.chatId,
    required this.technicianId,
    required this.clientId,
    required this.createdAt,
    required this.serviceTitle,
    this.isResolved = false,
    this.resolution,
    this.resolvedAt,
  });

  factory PendingConfirmationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PendingConfirmationModel(
      id: doc.id,
      serviceId: data['serviceId'] ?? '',
      chatId: data['chatId'] ?? '',
      technicianId: data['technicianId'] ?? '',
      clientId: data['clientId'] ?? '',
      serviceTitle: data['serviceTitle'] ?? 'Servicio',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isResolved: data['isResolved'] ?? false,
      resolution: data['resolution'],
      resolvedAt:
          data['resolvedAt'] != null
              ? (data['resolvedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'serviceId': serviceId,
      'chatId': chatId,
      'technicianId': technicianId,
      'clientId': clientId,
      'serviceTitle': serviceTitle,
      'createdAt': Timestamp.fromDate(createdAt),
      'isResolved': isResolved,
      'resolution': resolution,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }
}
