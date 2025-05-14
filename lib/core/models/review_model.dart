// lib/core/models/review_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String serviceId;
  final String reviewerId; // ID del usuario que hace la reseña
  final String reviewedId; // ID del usuario que recibe la reseña
  final double rating; // Calificación de 1 a 5
  final String? comment; // Comentario opcional
  final DateTime createdAt;
  final List<String>? photos; // Fotos opcionales del trabajo

  ReviewModel({
    required this.id,
    required this.serviceId,
    required this.reviewerId,
    required this.reviewedId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.photos,
  });

  // Constructor desde Firestore
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      serviceId: data['serviceId'] ?? '',
      reviewerId: data['reviewerId'] ?? '',
      reviewedId: data['reviewedId'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photos: data['photos'] != null ? List<String>.from(data['photos']) : null,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'serviceId': serviceId,
      'reviewerId': reviewerId,
      'reviewedId': reviewedId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'photos': photos,
    };
  }
}
