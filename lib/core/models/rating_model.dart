// lib/core/models/rating_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String serviceId;
  final String technicianId;
  final String clientId;
  final double rating;
  final DateTime createdAt;
  final String? comment;

  RatingModel({
    required this.id,
    required this.serviceId,
    required this.technicianId,
    required this.clientId,
    required this.rating,
    required this.createdAt,
    this.comment,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      serviceId: data['serviceId'] ?? '',
      technicianId: data['technicianId'] ?? '',
      clientId: data['clientId'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      comment: data['comment'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'serviceId': serviceId,
      'technicianId': technicianId,
      'clientId': clientId,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'comment': comment,
    };
  }
}
