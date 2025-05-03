import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

/// Servicio para manejo de almacenamiento y archivos
///
/// Proporciona métodos para seleccionar, subir y eliminar imágenes
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Seleccionar imagen de la galería
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

  /// Seleccionar imagen de la cámara
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
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

  /// Subir imagen a Firebase Storage
  ///
  /// Retorna la URL de la imagen subida o null si hubo un error
  Future<String?> uploadImage(
    File imageFile,
    String folder,
    String userId,
  ) async {
    try {
      // Crear nombre único para la imagen basado en timestamp
      final String fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Crear referencia en Firebase Storage
      final Reference ref = _storage.ref().child(folder).child(fileName);

      // Iniciar la subida
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Esperar a que termine la subida
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(
        () => null,
      );

      // Obtener URL de descarga
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print('Imagen subida correctamente: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  /// Eliminar imagen de Firebase Storage por URL
  Future<bool> deleteImageByUrl(String imageUrl) async {
    try {
      // Extraer la referencia de la URL
      final Reference ref = _storage.refFromURL(imageUrl);

      // Eliminar archivo
      await ref.delete();

      print('Imagen eliminada correctamente');
      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }

  /// Eliminar imagen por ruta
  Future<bool> deleteImageByPath(String folder, String fileName) async {
    try {
      // Crear referencia
      final Reference ref = _storage.ref().child(folder).child(fileName);

      // Eliminar archivo
      await ref.delete();

      print('Imagen eliminada correctamente');
      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }
}
