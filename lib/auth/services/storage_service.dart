// lib/auth/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Seleccionar imagen de la galería
  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Calidad reducida para menor tamaño
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      return null;
    }
  }

  // Seleccionar imagen de la cámara
  Future<File?> pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }

  // Subir imagen a Firebase Storage
  Future<String?> uploadImage(
    File imageFile,
    String folder,
    String userId,
  ) async {
    try {
      // Crear referencia con nombre único basado en timestamp
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.${path.extension(imageFile.path).substring(1)}';
      final ref = _storage.ref().child(folder).child(fileName);

      // Subir archivo
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);

      // Obtener URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  // Eliminar imagen de Firebase Storage por URL
  Future<bool> deleteImageByUrl(String imageUrl) async {
    try {
      // Extraer la referencia de la URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }
}
