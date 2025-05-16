import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/pending_confirmation_model.dart';
import '../../core/enums/service_enums.dart';

class ConfirmationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear una confirmación pendiente cuando el técnico marca un trabajo como completado
  Future<String?> createPendingConfirmation({
    required String serviceId,
    required String chatId,
    required String technicianId,
    required String clientId,
    required String serviceTitle,
  }) async {
    try {
      print('Creando confirmación pendiente:');
      print('- serviceId: $serviceId');
      print('- chatId: $chatId');
      print('- technicianId: $technicianId');
      print('- clientId: $clientId');
      print('- serviceTitle: $serviceTitle');

      final confirmationRef =
          _firestore.collection('pending_confirmations').doc();

      final confirmation = PendingConfirmationModel(
        id: confirmationRef.id,
        serviceId: serviceId,
        chatId: chatId,
        technicianId: technicianId,
        clientId: clientId,
        serviceTitle: serviceTitle,
        createdAt: DateTime.now(),
      );

      await confirmationRef.set(confirmation.toFirestore());
      print('Confirmación pendiente creada con ID: ${confirmationRef.id}');
      return confirmationRef.id;
    } catch (e) {
      print('Error al crear confirmación pendiente: $e');
      return null;
    }
  }

  // Verificar si hay confirmaciones pendientes para un chat específico
  Future<PendingConfirmationModel?> getPendingConfirmationForChat(
    String chatId,
  ) async {
    try {
      print('Buscando confirmaciones pendientes para chat: $chatId');
      final user = _auth.currentUser;
      if (user == null) {
        print('No hay usuario autenticado');
        return null;
      }

      print('Usuario actual: ${user.uid}');

      final snapshot =
          await _firestore
              .collection('pending_confirmations')
              .where('chatId', isEqualTo: chatId)
              .where('clientId', isEqualTo: user.uid)
              .where('isResolved', isEqualTo: false)
              .get();

      print('Documentos encontrados: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('No hay confirmaciones pendientes');
        return null;
      }

      // Devolvemos la confirmación pendiente más antigua
      final doc = snapshot.docs.first;
      print('Documento encontrado: ${doc.id}');
      return PendingConfirmationModel.fromFirestore(doc);
    } catch (e) {
      print('Error al obtener confirmaciones pendientes: $e');
      return null;
    }
  }

  // Resolver una confirmación pendiente
  Future<bool> resolveConfirmation({
    required String confirmationId,
    required bool isAccepted,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Obtener la confirmación primero para verificar permiso
      final confirmationDoc =
          await _firestore
              .collection('pending_confirmations')
              .doc(confirmationId)
              .get();

      if (!confirmationDoc.exists) return false;

      final confirmation = PendingConfirmationModel.fromFirestore(
        confirmationDoc,
      );

      // Verificar que el usuario actual es el cliente
      if (confirmation.clientId != user.uid) return false;

      // Actualizar la confirmación
      await _firestore
          .collection('pending_confirmations')
          .doc(confirmationId)
          .update({
            'isResolved': true,
            'resolution': isAccepted ? 'accepted' : 'rejected',
            'resolvedAt': FieldValue.serverTimestamp(),
          });

      // Actualizar el estado del servicio
      await _firestore
          .collection('service_requests')
          .doc(confirmation.serviceId)
          .update({
            'status':
                isAccepted
                    ? ServiceStatus.completed.value
                    : ServiceStatus.inProgress.value,
            'completedAt': isAccepted ? FieldValue.serverTimestamp() : null,
          });

      return true;
    } catch (e) {
      print('Error al resolver confirmación: $e');
      return false;
    }
  }
}
