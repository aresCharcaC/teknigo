// lib/data/repositories/review_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener reseñas de un técnico
  Future<List<ReviewModel>> getTechnicianReviews(String technicianId) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('reviewedId', isEqualTo: technicianId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al obtener reseñas: $e');
      return [];
    }
  }

  // Crear una reseña
  Future<String?> createReview({
    required String serviceId,
    required String reviewedId,
    required double rating,
    String? comment,
    List<String>? photos,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final reviewRef = _firestore.collection('reviews').doc();

      final review = ReviewModel(
        id: reviewRef.id,
        serviceId: serviceId,
        reviewerId: user.uid,
        reviewedId: reviewedId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        photos: photos,
      );

      await reviewRef.set(review.toFirestore());
      return reviewRef.id;
    } catch (e) {
      print('Error al crear reseña: $e');
      return null;
    }
  }

  // Obtener la calificación promedio de un técnico
  Future<double> getTechnicianAverageRating(String technicianId) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('reviewedId', isEqualTo: technicianId)
              .get();

      if (snapshot.docs.isEmpty) {
        return 0.0;
      }

      double totalRating = 0.0;
      for (var doc in snapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }

      return totalRating / snapshot.docs.length;
    } catch (e) {
      print('Error al obtener calificación promedio: $e');
      return 0.0;
    }
  }
}
