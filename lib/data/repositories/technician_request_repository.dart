// lib/data/repositories/technician_request_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/service_request_model.dart';

class TechnicianRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ServiceRequestModel?> getRequestById(String requestId) async {
    try {
      final doc =
          await _firestore.collection('service_requests').doc(requestId).get();

      if (!doc.exists) {
        return null;
      }

      return ServiceRequestModel.fromFirestore(doc);
    } catch (e) {
      print('Error al obtener solicitud por ID: $e');
      return null;
    }
  }

  // Obtener solicitudes disponibles para el técnico actual
  Future<List<ServiceRequestModel>> getAvailableRequests() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      // Obtener perfil del técnico para filtrar por ciudad y categorías
      final techDoc =
          await _firestore
              .collection(AppConstants.techniciansCollection)
              .doc(user.uid)
              .get();

      if (!techDoc.exists) {
        return [];
      }

      final techData = techDoc.data() as Map<String, dynamic>;

      // Obtener ubicación del técnico
      String? techCity;

      // Intentar obtener ciudad del técnico desde el perfil de usuario
      final userDoc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        techCity = userData['city'] as String?;
      }

      // Si no hay ciudad, no podemos filtrar
      if (techCity == null) {
        return [];
      }

      // Obtener categorías del técnico
      List<String> techCategories = [];
      if (techData.containsKey('categories') &&
          techData['categories'] is List) {
        techCategories = List<String>.from(techData['categories']);
      }

      // Consultar solicitudes pendientes
      final querySnapshot =
          await _firestore
              .collection('service_requests')
              .where('status', isEqualTo: 'pending')
              .get();

      // Lista para almacenar solicitudes coincidentes
      List<ServiceRequestModel> matchingRequests = [];

      // Filtrar solicitudes por ciudad y categorías
      for (var doc in querySnapshot.docs) {
        try {
          final request = ServiceRequestModel.fromFirestore(doc);

          // Obtener ciudad del cliente
          final clientDoc =
              await _firestore
                  .collection(AppConstants.usersCollection)
                  .doc(request.userId)
                  .get();

          if (!clientDoc.exists) {
            continue;
          }

          final clientData = clientDoc.data() as Map<String, dynamic>;
          final clientCity = clientData['city'] as String?;

          // Verificar si coincide la ciudad
          if (clientCity != null &&
              clientCity.toLowerCase() == techCity.toLowerCase()) {
            // Verificar si hay categorías coincidentes
            bool hasMatchingCategory = false;

            if (techCategories.isEmpty) {
              // Si el técnico no tiene categorías, mostrar todas las solicitudes de la ciudad
              hasMatchingCategory = true;
            } else {
              // Buscar categorías coincidentes
              for (var requestCategory in request.categoryIds) {
                if (techCategories.contains(requestCategory)) {
                  hasMatchingCategory = true;
                  break;
                }
              }
            }

            if (hasMatchingCategory) {
              matchingRequests.add(request);
            }
          }
        } catch (e) {
          print('Error procesando solicitud: $e');
        }
      }

      // Ordenar por urgencia y fecha
      matchingRequests.sort((a, b) {
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      return matchingRequests;
    } catch (e) {
      print('Error obteniendo solicitudes disponibles: $e');
      return [];
    }
  }
}
