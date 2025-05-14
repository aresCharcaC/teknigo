// lib/data/repositories/service_status_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/service_model.dart';
import '../../core/enums/service_enums.dart';

class ServiceStatusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para obtener el servicio actual por chatId
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

      return ServiceModel.fromMap(
        serviceDoc.data() as Map<String, dynamic>,
        serviceDoc.id,
      );
    } catch (e) {
      print('Error obteniendo servicio por chatId: $e');
      return null;
    }
  }

  // Método para aceptar un servicio (transición de offered a accepted)
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
      print('Error aceptando servicio: $e');
      return false;
    }
  }

  // Método para marcar un servicio como en progreso
  Future<bool> startService(String serviceId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc =
          await _firestore.collection('service_requests').doc(serviceId).get();

      if (!doc.exists) return false;

      final serviceData = doc.data() as Map<String, dynamic>;

      // Verificar que el técnico es el asignado al servicio
      if (serviceData['technicianId'] != user.uid) return false;

      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.inProgress.value,
        'inProgressAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error iniciando servicio: $e');
      return false;
    }
  }

  // Método para marcar un servicio como completado (por el técnico)
  Future<bool> completeService(String serviceId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc =
          await _firestore.collection('service_requests').doc(serviceId).get();

      if (!doc.exists) return false;

      final serviceData = doc.data() as Map<String, dynamic>;

      // Verificar que el técnico es el asignado al servicio
      if (serviceData['technicianId'] != user.uid) return false;

      await _firestore.collection('service_requests').doc(serviceId).update({
        'status': ServiceStatus.completed.value,
        'completedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error completando servicio: $e');
      return false;
    }
  }
}
