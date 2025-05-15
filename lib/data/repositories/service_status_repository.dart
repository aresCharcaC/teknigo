// lib/data/repositories/service_status_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/service_model.dart';
import '../../core/enums/service_enums.dart';

class ServiceStatusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current service by chatId
  Future<ServiceModel?> getServiceByChatId(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) return null;

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final requestId = chatData['requestId'] as String?;

      if (requestId == null) return null;

      final serviceDoc =
          await _firestore.collection('service_requests').doc(requestId).get();

      if (!serviceDoc.exists) return null;

      final serviceData = serviceDoc.data() as Map<String, dynamic>;

      // Add the chatId to the service data for reference
      serviceData['chatId'] = chatId;

      return ServiceModel.fromMap(serviceData, serviceDoc.id);
    } catch (e) {
      print('Error getting service by chatId: $e');
      return null;
    }
  }

  // Method to accept a service (transition from offered to accepted)
  Future<bool> acceptService(String serviceId, double agreedPrice) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.accepted.value,
        'acceptedAt': FieldValue.serverTimestamp(),
        'agreedPrice': agreedPrice,
      });

      return true;
    } catch (e) {
      print('Error accepting service: $e');
      return false;
    }
  }

  // Method to mark a service as in progress
  Future<bool> startService(String serviceId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc =
          await _firestore.collection('service_requests').doc(serviceId).get();

      if (!doc.exists) return false;

      final serviceData = doc.data() as Map<String, dynamic>;

      // Check that current user is the assigned technician
      if (serviceData['technicianId'] != user.uid) return false;

      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.inProgress.value,
        'inProgressAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error starting service: $e');
      return false;
    }
  }

  // Method to mark a service as completed (by technician)
  Future<bool> completeService(String serviceId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc =
          await _firestore.collection('service_requests').doc(serviceId).get();

      if (!doc.exists) return false;

      final serviceData = doc.data() as Map<String, dynamic>;

      // Check that current user is the assigned technician
      if (serviceData['technicianId'] != user.uid) return false;

      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.completed.value,
        'completedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error completing service: $e');
      return false;
    }
  }

  // Method for client to rate and finish the service
  Future<bool> rateService(
    String serviceId,
    double rating,
    String? comment,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc =
          await _firestore.collection('service_requests').doc(serviceId).get();

      if (!doc.exists) return false;

      final serviceData = doc.data() as Map<String, dynamic>;

      // Check that current user is the client
      if (serviceData['clientId'] != user.uid) return false;

      final technicianId = serviceData['technicianId'];
      if (technicianId == null) return false;

      // Update the service
      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.rated.value,
        'finishedAt': FieldValue.serverTimestamp(),
        'technicianRating': rating,
        'technicianReview': comment,
      });

      // Create review
      await _firestore.collection('reviews').add({
        'serviceId': serviceId,
        'reviewerId': user.uid,
        'reviewedId': technicianId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update technician's average rating
      await _updateTechnicianRating(technicianId);

      return true;
    } catch (e) {
      print('Error rating service: $e');
      return false;
    }
  }

  // Helper method to update technician's average rating
  Future<void> _updateTechnicianRating(String technicianId) async {
    try {
      // Get all reviews for this technician
      final reviewsSnapshot =
          await _firestore
              .collection('reviews')
              .where('reviewedId', isEqualTo: technicianId)
              .get();

      if (reviewsSnapshot.docs.isEmpty) return;

      // Calculate average rating
      double totalRating = 0;
      int reviewCount = 0;

      for (var doc in reviewsSnapshot.docs) {
        final reviewData = doc.data();
        if (reviewData.containsKey('rating')) {
          totalRating += (reviewData['rating'] as num).toDouble();
          reviewCount++;
        }
      }

      final averageRating = totalRating / reviewCount;

      // Update technician's profile
      await _firestore
          .collection(AppConstants.techniciansCollection)
          .doc(technicianId)
          .update({'rating': averageRating, 'reviewCount': reviewCount});
    } catch (e) {
      print('Error updating technician rating: $e');
    }
  }
}
