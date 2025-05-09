// lib/data/repositories/technician_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../services/storage_service.dart';

/// Repositorio para manejar todas las operaciones relacionadas con técnicos
class TechnicianRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  // Obtener datos del perfil técnico
  Future<Map<String, dynamic>?> getTechnicianProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No hay usuario autenticado');
        return null;
      }

      final docRef = _firestore
          .collection(AppConstants.techniciansCollection)
          .doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        // Si el perfil ya existe, devolver los datos
        print('Perfil de técnico encontrado');
        return doc.data();
      } else {
        // Si no existe el perfil, obtener datos básicos del usuario
        print('Creando perfil de técnico nuevo');
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
            'rating': 0.0,
            'reviewCount': 0,
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
          'rating': 0.0,
          'reviewCount': 0,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };

        await docRef.set({
          ...minProfile,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('Perfil mínimo creado');
        return minProfile;
      }
    } catch (e) {
      print('Error al obtener perfil de técnico: $e');
      return null;
    }
  }

  Future<bool> syncUserProfileImage(String imageUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Actualizar en la colección de usuarios
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'profileImage': imageUrl});

      return true;
    } catch (e) {
      print('Error al sincronizar imagen de perfil: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getTechniciansInCity(
    String userCity, {
    int limit = 10,
  }) async {
    try {
      print('Buscando técnicos en ciudad: $userCity');

      // Obtener todos los técnicos con servicios activos
      final query = _firestore
          .collection(AppConstants.techniciansCollection)
          .where('isServicesActive', isEqualTo: true)
          .limit(30); // Obtenemos más porque luego filtraremos

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print('No se encontraron técnicos con servicios activos');
        return [];
      }

      // Lista para almacenar los técnicos con sus datos completos
      List<Map<String, dynamic>> techniciansWithUserData = [];

      // Para cada técnico, obtenemos sus datos de usuario
      for (var techDoc in snapshot.docs) {
        final techId = techDoc.id;
        final techData = techDoc.data();

        // Obtener datos del usuario correspondiente
        try {
          final userDoc =
              await _firestore
                  .collection(AppConstants.usersCollection)
                  .doc(techId) // Mismo ID entre técnico y usuario
                  .get();

          if (userDoc.exists) {
            // Combinar datos de técnico y usuario
            final userData = userDoc.data() ?? {};
            final combinedData = {...techData, ...userData, 'id': techId};

            // Verificar si la ciudad coincide
            final techCity = userData['city'];
            if (techCity != null &&
                techCity.toString().toLowerCase() == userCity.toLowerCase()) {
              techniciansWithUserData.add(combinedData);
            }
          }
        } catch (e) {
          print('Error al obtener datos de usuario para técnico $techId: $e');
        }

        // Si ya tenemos suficientes técnicos, salimos del bucle
        if (techniciansWithUserData.length >= limit) {
          break;
        }
      }

      print(
        'Técnicos encontrados en $userCity: ${techniciansWithUserData.length}',
      );
      return techniciansWithUserData;
    } catch (e) {
      print('Error al obtener técnicos: $e');
      return [];
    }
  }

  // Actualizar perfil técnico
  Future<bool> updateTechnicianProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No hay usuario autenticado para actualizar perfil');
        return false;
      }

      // Añadir timestamp de actualización
      data['updatedAt'] = FieldValue.serverTimestamp();

      // Manejar location si está presente pero en formato LatLng
      if (data.containsKey('location') &&
          data['location'] is Map<String, dynamic>) {
        final locationMap = data['location'] as Map<String, dynamic>;
        if (locationMap.containsKey('latitude') &&
            locationMap.containsKey('longitude')) {
          data['location'] = GeoPoint(
            locationMap['latitude'] as double,
            locationMap['longitude'] as double,
          );
        }
      }

      // Actualizar documento
      await _firestore
          .collection(AppConstants.techniciansCollection)
          .doc(user.uid)
          .update(data);

      print('Perfil de técnico actualizado correctamente');
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

      // Si la subida fue exitosa, actualizar perfil de técnico
      if (url != null) {
        await updateTechnicianProfile({'profileImage': url});

        // También actualizar el perfil de Firebase Auth
        await user.updatePhotoURL(url);

        // Y actualizar en la colección de usuarios
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({'profileImage': url});
      }

      return url;
    } catch (e) {
      print('Error al subir imagen de perfil: $e');
      return null;
    }
  }

  // Eliminar imagen de perfil
  Future<bool> removeProfileImage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Obtener perfil actual para conseguir la URL de la imagen
      final docRef = _firestore
          .collection(AppConstants.techniciansCollection)
          .doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists && doc.data()!.containsKey('profileImage')) {
        final profileImageUrl = doc.data()!['profileImage'];

        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          // Eliminar imagen de Storage
          await _storageService.deleteImageByUrl(profileImageUrl);

          // Actualizar perfil de técnico
          await updateTechnicianProfile({'profileImage': null});

          // Actualizar perfil de Firebase Auth
          await user.updatePhotoURL(null);

          // Actualizar en la colección de usuarios
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .update({'profileImage': null});

          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error al eliminar imagen de perfil: $e');
      return false;
    }
  }

  // Subir imagen de negocio
  Future<String?> uploadBusinessImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No hay usuario autenticado para subir imagen');
        return null;
      }

      // Subir imagen a Storage
      final url = await _storageService.uploadImage(
        imageFile,
        AppConstants.businessImagesPath,
        user.uid,
      );

      // Si la subida fue exitosa, actualizar el perfil
      if (url != null) {
        await updateTechnicianProfile({'businessImage': url});
        print('Imagen de negocio subida y actualizada: $url');
      }

      return url;
    } catch (e) {
      print('Error al subir imagen de negocio: $e');
      return null;
    }
  }

  // Eliminar imagen de negocio
  Future<bool> removeBusinessImage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No hay usuario autenticado para eliminar imagen');
        return false;
      }

      // Obtener perfil actual para conseguir la URL de la imagen
      final docRef = _firestore
          .collection(AppConstants.techniciansCollection)
          .doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists && doc.data()!.containsKey('businessImage')) {
        final businessImageUrl = doc.data()!['businessImage'];

        if (businessImageUrl != null && businessImageUrl.isNotEmpty) {
          try {
            // Eliminar imagen de Storage
            await _storageService.deleteImageByUrl(businessImageUrl);

            // Actualizar perfil
            await updateTechnicianProfile({'businessImage': null});
            print('Imagen de negocio eliminada correctamente');
            return true;
          } catch (e) {
            print('Error al eliminar imagen de Storage: $e');
            // Aún así, actualizamos el perfil para quitar la referencia
            await updateTechnicianProfile({'businessImage': null});
            return true;
          }
        }
      }
      print('No se encontró imagen de negocio para eliminar');
      return false;
    } catch (e) {
      print('Error al eliminar imagen de negocio: $e');
      return false;
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
      if (user == null) {
        print('No hay usuario autenticado para actualizar ubicación');
        return false;
      }

      // Convertir a GeoPoint para Firestore
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

      print('Ubicación actualizada correctamente: $address');
      return true;
    } catch (e) {
      print('Error al actualizar ubicación: $e');
      return false;
    }
  }
}
