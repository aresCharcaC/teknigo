// lib/data/repositories/service_request_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../core/constants/app_constants.dart';
import '../../core/models/service_request_model.dart';

class ServiceRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Crear una nueva solicitud de servicio
  Future<String?> createServiceRequest(
    ServiceRequestModel request,
    List<File>? photos,
  ) async {
    try {
      // Obtener usuario actual
      final user = _auth.currentUser;
      if (user == null) return null;

      // Preparar datos base para la solicitud
      Map<String, dynamic> requestData = request.toFirestore();

      // Asegurarse de que el ID de usuario sea el correcto
      requestData['userId'] = user.uid;

      // Si hay fotos, subirlas primero
      if (photos != null && photos.isNotEmpty) {
        final photoUrls = await _uploadPhotos(user.uid, photos);
        if (photoUrls.isNotEmpty) {
          requestData['photos'] = photoUrls;
        }
      }

      // Crear la solicitud en Firestore
      final docRef = await _firestore.collection('services').add(requestData);
      print('Solicitud creada con ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      print('Error al crear solicitud: $e');
      return null;
    }
  }

  // Subir fotos al Storage
  Future<List<String>> _uploadPhotos(String userId, List<File> photos) async {
    List<String> photoUrls = [];

    try {
      for (var i = 0; i < photos.length; i++) {
        final file = photos[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = 'service_images/$userId/$timestamp-$i.jpg';

        // Subir archivo
        final uploadTask = _storage.ref().child(path).putFile(file);

        // Mostrar progreso si lo necesitas
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print(
            'Progreso de subida $i: ${(progress * 100).toStringAsFixed(2)}%',
          );
        });

        // Esperar a que termine la subida
        final snapshot = await uploadTask;

        // Obtener URL
        final url = await snapshot.ref.getDownloadURL();
        photoUrls.add(url);

        print('Foto $i subida exitosamente: $url');
      }
    } catch (e) {
      print('Error al subir fotos: $e');
    }

    return photoUrls;
  }

  // Obtener solicitudes del usuario actual
  Future<List<ServiceRequestModel>> getUserRequests() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No hay usuario autenticado para obtener solicitudes');
        return [];
      }

      print('Obteniendo solicitudes para el usuario: ${user.uid}');

      // Buscar en la colección 'services'
      final snapshot =
          await _firestore
              .collection('services')
              .where('userId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .get();

      print('Solicitudes encontradas: ${snapshot.docs.length}');

      final requests =
          snapshot.docs
              .map((doc) {
                try {
                  return ServiceRequestModel.fromFirestore(doc);
                } catch (e) {
                  print('Error al convertir documento ${doc.id}: $e');
                  return null;
                }
              })
              .where((request) => request != null)
              .cast<ServiceRequestModel>()
              .toList();

      print('Solicitudes procesadas correctamente: ${requests.length}');
      return requests;
    } catch (e) {
      print('Error al obtener solicitudes del usuario: $e');
      return [];
    }
  }

  // Escuchar cambios en las solicitudes del usuario actual (en tiempo real)
  Stream<List<ServiceRequestModel>> getUserRequestsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('services')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return ServiceRequestModel.fromFirestore(doc);
                } catch (e) {
                  print('Error al convertir documento en stream ${doc.id}: $e');
                  return null;
                }
              })
              .where((request) => request != null)
              .cast<ServiceRequestModel>()
              .toList();
        });
  }

  // Cancelar una solicitud
  Future<bool> cancelRequest(String requestId) async {
    try {
      await _firestore.collection('services').doc(requestId).update({
        'status': 'cancelled',
      });
      print('Solicitud cancelada correctamente: $requestId');
      return true;
    } catch (e) {
      print('Error al cancelar solicitud: $e');
      return false;
    }
  }

  // Obtener una solicitud específica
  Future<ServiceRequestModel?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore.collection('services').doc(requestId).get();

      if (doc.exists) {
        return ServiceRequestModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener solicitud: $e');
      return null;
    }
  }
}
