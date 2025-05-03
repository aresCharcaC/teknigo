import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/storage_service.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

/// ViewModel para la pantalla de perfil de usuario
class ProfileViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = StorageService();

  // Datos del usuario
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  // Cargar datos del perfil del usuario
  Future<void> loadUserProfile() async {
    return executeAsync<void>(() async {
      final result = await _authRepository.getUserData();

      if (result != null) {
        _userData = result;
      } else {
        _userData = {};
      }
    });
  }

  // Actualizar perfil de usuario
  Future<Resource<void>> updateUserProfile(Map<String, dynamic> data) async {
    try {
      setLoading();

      await _authRepository.updateUserProfile(data);

      // Actualizar datos locales
      _userData = {..._userData, ...data};

      setLoaded();
      return Resource.success(null);
    } catch (e) {
      final errorMessage = 'Error al actualizar perfil: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Seleccionar imagen de la galería
  Future<File?> pickImageFromGallery() async {
    try {
      return await _storageService.pickImageFromGallery();
    } catch (e) {
      setError('Error al seleccionar imagen: $e');
      return null;
    }
  }

  // Seleccionar imagen de la cámara
  Future<File?> pickImageFromCamera() async {
    try {
      return await _storageService.pickImageFromCamera();
    } catch (e) {
      setError('Error al tomar foto: $e');
      return null;
    }
  }

  // Subir imagen de perfil
  Future<Resource<String?>> uploadProfileImage(File imageFile) async {
    try {
      setLoading();

      final userId = _authRepository.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Subir la imagen a Storage
      final imageUrl = await _storageService.uploadImage(
        imageFile,
        AppConstants.profileImagesPath,
        userId,
      );

      if (imageUrl != null) {
        // Actualizar URL en Firestore
        await _authRepository.updateUserProfile({'profileImage': imageUrl});

        // Actualizar datos locales
        _userData['profileImage'] = imageUrl;
      }

      setLoaded();
      return Resource.success(imageUrl);
    } catch (e) {
      final errorMessage = 'Error al subir imagen de perfil: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  // Eliminar imagen de perfil
  Future<Resource<bool>> removeProfileImage() async {
    try {
      setLoading();

      final imageUrl = _userData['profileImage'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Eliminar imagen de Storage
        await _storageService.deleteImageByUrl(imageUrl);

        // Actualizar en Firestore
        await _authRepository.updateUserProfile({'profileImage': null});

        // Actualizar datos locales
        _userData['profileImage'] = null;
      }

      setLoaded();
      return Resource.success(true);
    } catch (e) {
      final errorMessage = 'Error al eliminar imagen de perfil: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }
}
