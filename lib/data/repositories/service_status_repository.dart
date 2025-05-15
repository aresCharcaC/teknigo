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
      print('ServiceStatusRepository: Getting service by chatId: $chatId');
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        print('ServiceStatusRepository: Chat not found: $chatId');
        return null;
      }

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final requestId = chatData['requestId'] as String?;

      if (requestId == null || requestId.isEmpty) {
        print('ServiceStatusRepository: No requestId found in chat: $chatId');
        return null;
      }

      print('ServiceStatusRepository: Found requestId: $requestId');
      final serviceDoc =
          await _firestore.collection('service_requests').doc(requestId).get();

      if (!serviceDoc.exists) {
        print('ServiceStatusRepository: Service not found: $requestId');
        return null;
      }

      final serviceData = serviceDoc.data() as Map<String, dynamic>;

      // Add the chatId to the service data for reference
      serviceData['chatId'] = chatId;

      print(
        'ServiceStatusRepository: Service found with status: ${serviceData['status']}',
      );
      return ServiceModel.fromMap(serviceData, serviceDoc.id);
    } catch (e) {
      print('ServiceStatusRepository: Error getting service by chatId: $e');
      return null;
    }
  }

  // Method to accept a service (transition from offered to accepted)
  Future<bool> acceptService(String serviceId, double agreedPrice) async {
    try {
      print(
        'ServiceStatusRepository: Accepting service: $serviceId with price: $agreedPrice',
      );
      final user = _auth.currentUser;
      if (user == null) {
        print('ServiceStatusRepository: No authenticated user');
        return false;
      }

      // Check if the user is the client
      final serviceDoc =
          await _firestore.collection('service_requests').doc(serviceId).get();
      if (!serviceDoc.exists) {
        print('ServiceStatusRepository: Service not found: $serviceId');
        return false;
      }

      final serviceData = serviceDoc.data() as Map<String, dynamic>;
      if (serviceData['clientId'] != user.uid) {
        print(
          'ServiceStatusRepository: User is not the client of this service',
        );
        return false;
      }

      // Update service status
      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.accepted.value,
        'acceptedAt': FieldValue.serverTimestamp(),
        'agreedPrice': agreedPrice,
      });

      print('ServiceStatusRepository: Service accepted successfully');
      return true;
    } catch (e) {
      print('ServiceStatusRepository: Error accepting service: $e');
      return false;
    }
  }

  // Method to mark a service as in progress
  Future<bool> startService(String serviceId) async {
    try {
      print('ServiceStatusRepository: Starting service: $serviceId');
      final user = _auth.currentUser;
      if (user == null) {
        print('ServiceStatusRepository: No authenticated user');
        return false;
      }

      final doc =
          await _firestore.collection('service_requests').doc(serviceId).get();
      if (!doc.exists) {
        print('ServiceStatusRepository: Service not found: $serviceId');
        return false;
      }

      final serviceData = doc.data() as Map<String, dynamic>;

      // Check that current user is the assigned technician
      if (serviceData['technicianId'] != user.uid) {
        print(
          'ServiceStatusRepository: User is not the technician of this service',
        );
        return false;
      }

      // Update service status
      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.inProgress.value,
        'inProgressAt': FieldValue.serverTimestamp(),
      });

      print('ServiceStatusRepository: Service started successfully');
      return true;
    } catch (e) {
      print('ServiceStatusRepository: Error starting service: $e');
      return false;
    }
  }

  // Method to mark a service as completed (by technician)
  Future<bool> completeService(String serviceId) async {
    try {
      print('ServiceStatusRepository: Completing service: $serviceId');
      final user = _auth.currentUser;
      if (user == null) {
        print('ServiceStatusRepository: No authenticated user');
        return false;
      }

      final doc =
          await _firestore.collection('service_requests').doc(serviceId).get();
      if (!doc.exists) {
        print('ServiceStatusRepository: Service not found: $serviceId');
        return false;
      }

      final serviceData = doc.data() as Map<String, dynamic>;

      // Check that current user is the assigned technician
      if (serviceData['technicianId'] != user.uid) {
        print(
          'ServiceStatusRepository: User is not the technician of this service',
        );
        return false;
      }

      // Update service status
      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.completed.value,
        'completedAt': FieldValue.serverTimestamp(),
      });

      print('ServiceStatusRepository: Service completed successfully');
      return true;
    } catch (e) {
      print('ServiceStatusRepository: Error completing service: $e');
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
      print(
        'ServiceStatusRepository: Rating service: $serviceId with rating: $rating',
      );
      final user = _auth.currentUser;
      if (user == null) {
        print('ServiceStatusRepository: No authenticated user');
        return false;
      }

      final doc =
          await _firestore.collection('service_requests').doc(serviceId).get();
      if (!doc.exists) {
        print('ServiceStatusRepository: Service not found: $serviceId');
        return false;
      }

      final serviceData = doc.data() as Map<String, dynamic>;

      // Check that current user is the client
      if (serviceData['clientId'] != user.uid) {
        print(
          'ServiceStatusRepository: User is not the client of this service',
        );
        return false;
      }

      final technicianId = serviceData['technicianId'];
      if (technicianId == null) {
        print(
          'ServiceStatusRepository: No technician assigned to this service',
        );
        return false;
      }

      // Update the service
      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.rated.value,
        'finishedAt': FieldValue.serverTimestamp(),
        'technicianRating': rating,
        'technicianReview': comment,
      });

      print('ServiceStatusRepository: Service rated successfully');

      // Create review
      await _firestore.collection('reviews').add({
        'serviceId': serviceId,
        'reviewerId': user.uid,
        'reviewedId': technicianId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('ServiceStatusRepository: Review created successfully');

      // Update technician's average rating
      await _updateTechnicianRating(technicianId);

      return true;
    } catch (e) {
      print('ServiceStatusRepository: Error rating service: $e');
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

      if (reviewsSnapshot.docs.isEmpty) {
        print(
          'ServiceStatusRepository: No reviews found for technician: $technicianId',
        );
        return;
      }

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

      print(
        'ServiceStatusRepository: Technician rating updated to: $averageRating from $reviewCount reviews',
      );
    } catch (e) {
      print('ServiceStatusRepository: Error updating technician rating: $e');
    }
  }

  Future<bool> revertToInProgress(String serviceId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Verificar que el usuario es el cliente
      final doc =
          await _firestore.collection('service_requests').doc(serviceId).get();
      if (!doc.exists) return false;

      final serviceData = doc.data() as Map<String, dynamic>;
      if (serviceData['clientId'] != user.uid) return false;

      // Actualizar estado
      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.inProgress.value,
        'completedAt': null, // Eliminar fecha de completado
      });

      return true;
    } catch (e) {
      print('Error al revertir servicio a en progreso: $e');
      return false;
    }
  }

  Future<bool> updateServiceStatus(
    String serviceId,
    ServiceStatus newStatus,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': newStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error al actualizar estado del servicio: $e');
      return false;
    }
  }
}
