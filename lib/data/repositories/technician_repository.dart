import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../services/storage_service.dart';

/// Repositorio para manejar todas las operaciones relacionadas con técnicos
///
/// Este repositorio encapsula toda la lógica de acceso a Firestore
/// para los datos de técnicos.
class TechnicianRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  // Obtener datos del perfil técnico
  Future<Map<String, dynamic>?> getTechnicianProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docRef = _firestore
          .collection(AppConstants.techniciansCollection)
          .doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        return doc.data();
      } else {
        // Si no existe el perfil, obtener datos básicos del usuario
        final userDoc =
            await _firestore
                .collection(AppConstants.usersCollection)
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};

          // Crear perfil básico
          final defaultProfile = {
            'name': userData['name'] ?? user.displayName ?? '',
            'email': userData['email'] ?? user.email ?? '',
            'phone': userData['phone'] ?? '',
            'profileImage': userData['profileImage'] ?? user.photoURL ?? '',
            'isIndividual': true,
            'isAvailable': true,
            'isServicesActive': false,
            'categories': [],
            'skills': [],
            'description': '',
            'experience': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          await docRef.set(defaultProfile);

          // Convertir el FieldValue en DateTime para poder usarlo en la app
          final dateNow = DateTime.now();
          defaultProfile['createdAt'] = dateNow;
          defaultProfile['updatedAt'] = dateNow;

          return defaultProfile;
        }

        // Si no hay datos de usuario, crear perfil mínimo
        final minProfile = {
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'profileImage': user.photoURL ?? '',
          'isIndividual': true,
          'isAvailable': true,
          'isServicesActive': false,
          'categories': [],
          'skills': [],
          'description': '',
          'experience': '',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };

        await docRef.set({
          ...minProfile,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return minProfile;
      }
    } catch (e) {
      print('Error al obtener perfil de técnico: $e');
      return null;
    }
  }

  // Actualizar perfil técnico
  Future<bool> updateTechnicianProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Añadir timestamp de actualización
      data['updatedAt'] = FieldValue.serverTimestamp();

      // Actualizar documento
      await _firestore
          .collection(AppConstants.techniciansCollection)
          .doc(user.uid)
          .update(data);

      return true;
    } catch (e) {
      print('Error al actualizar perfil técnico: $e');
      return false;
    }
  }

  // Subir imagen de perfil
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Subir imagen a Storage
      final url = await _storageService.uploadImage(
        imageFile,
        AppConstants.profileImagesPath,
        user.uid,
      );

      // Si la subida fue exitosa, actualizar el perfil
      if (url != null) {
        await updateTechnicianProfile({'profileImage': url});
      }

      return url;
    } catch (e) {
      print('Error al subir imagen de perfil: $e');
      return null;
    }
  }

  // Subir imagen de negocio
  Future<String?> uploadBusinessImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Subir imagen a Storage
      final url = await _storageService.uploadImage(
        imageFile,
        AppConstants.businessImagesPath,
        user.uid,
      );

      // Si la subida fue exitosa, actualizar el perfil
      if (url != null) {
        await updateTechnicianProfile({'businessImage': url});
      }

      return url;
    } catch (e) {
      print('Error al subir imagen de negocio: $e');
      return null;
    }
  }

  // Actualizar ubicación
  Future<bool> updateLocation(
    LatLng location,
    String address,
    double radius,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final locationData = {
        'location': GeoPoint(location.latitude, location.longitude),
        'address': address,
        'coverageRadius': radius,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(AppConstants.techniciansCollection)
          .doc(user.uid)
          .update(locationData);

      return true;
    } catch (e) {
      print('Error al actualizar ubicación: $e');
      return false;
    }
  }

  // Obtener solicitudes pendientes
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Aquí implementaríamos la lógica para obtener las solicitudes pendientes
      // Por ahora, retornamos una lista vacía
      return [];
    } catch (e) {
      print('Error al obtener solicitudes pendientes: $e');
      return [];
    }
  }

  // Obtener servicios aceptados
  Future<List<Map<String, dynamic>>> getAcceptedServices() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Aquí implementaríamos la lógica para obtener los servicios aceptados
      // Por ahora, retornamos una lista vacía
      return [];
    } catch (e) {
      print('Error al obtener servicios aceptados: $e');
      return [];
    }
  }

  // Obtener servicios completados
  Future<List<Map<String, dynamic>>> getCompletedServices() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Aquí implementaríamos la lógica para obtener los servicios completados
      // Por ahora, retornamos una lista vacía
      return [];
    } catch (e) {
      print('Error al obtener servicios completados: $e');
      return [];
    }
  }

  // Obtener chats activos
  Future<List<Map<String, dynamic>>> getActiveChats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Aquí implementaríamos la lógica para obtener los chats activos
      // Por ahora, retornamos una lista vacía
      return [];
    } catch (e) {
      print('Error al obtener chats activos: $e');
      return [];
    }
  }
}
