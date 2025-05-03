// lib/data/repositories/technician_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../auth/services/storage_service.dart';

class TechnicianRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  // Obtener datos del perfil técnico
  Future<Map<String, dynamic>?> getTechnicianProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docRef = _firestore.collection('technicians').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        return doc.data();
      } else {
        // Si no existe el perfil, obtener datos básicos del usuario
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};

          // Crear perfil básico
          final defaultProfile = {
            'name': userData['name'] ?? user.displayName ?? '',
            'email': userData['email'] ?? user.email ?? '',
            'phone': userData['phone'] ?? '',
            'profileImage': userData['photoURL'] ?? user.photoURL ?? '',
            'isIndividual': true,
            'isAvailable': true,
            'isServicesActive': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          await docRef.set(defaultProfile);
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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await docRef.set(minProfile);
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
      await _firestore.collection('technicians').doc(user.uid).update(data);

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
        'technician_profile_images',
        user.uid,
      );

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
        'business_images',
        user.uid,
      );

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
          .collection('technicians')
          .doc(user.uid)
          .update(locationData);

      return true;
    } catch (e) {
      print('Error al actualizar ubicación: $e');
      return false;
    }
  }
}
