// lib/presentation/view_models/chat_detail_view_model.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/services/storage_service.dart';
import '../common/base_view_model.dart';

class ChatDetailViewModel extends BaseViewModel {
  final ChatRepository _repository = ChatRepository();
  final StorageService _storageService = StorageService();

  String _chatId = '';
  String get chatId => _chatId;

  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  // Iniciar escucha de mensajes de un chat
  void startListeningToMessages(String chatId) {
    try {
      print('ViewModel: Iniciando escucha de mensajes para chat: $chatId');
      _chatId = chatId;
      setLoading();

      _repository
          .getChatMessagesStream(chatId)
          .listen(
            (messagesList) {
              print('ViewModel: Recibidos ${messagesList.length} mensajes');
              _messages = messagesList;
              setLoaded();

              // Marcar mensajes como leídos
              _repository.markMessagesAsRead(chatId);
            },
            onError: (e) {
              print('ViewModel: Error al cargar mensajes: $e');
              setError('Error al cargar mensajes: $e');
            },
          );
    } catch (e) {
      print('ViewModel: Error al iniciar escucha de mensajes: $e');
      setError('Error al iniciar escucha de mensajes: $e');
    }
  }

  // Enviar mensaje de texto
  Future<bool> sendTextMessage(String content) async {
    try {
      print('ViewModel: Enviando mensaje de texto: $content');
      if (_chatId.isEmpty) {
        print('ViewModel: Chat ID vacío');
        return false;
      }

      final result = await _repository.sendTextMessage(
        chatId: _chatId,
        content: content,
      );

      print('ViewModel: Resultado de envío: $result');
      return result;
    } catch (e) {
      print('ViewModel: Error al enviar mensaje: $e');
      setError('Error al enviar mensaje: $e');
      return false;
    }
  }

  // Seleccionar y enviar imagen
  Future<bool> sendImageFromGallery() async {
    try {
      if (_chatId.isEmpty) return false;

      // Seleccionar imagen
      final imageFile = await _storageService.pickImageFromGallery();
      if (imageFile == null) return false;

      // Mostrar indicador de carga
      setLoading();

      // Subir imagen
      final imageUrl = await _storageService.uploadImage(
        imageFile,
        'chat_images',
        _chatId,
      );

      if (imageUrl == null) {
        setError('Error al subir imagen');
        return false;
      }

      // Enviar mensaje con la URL de la imagen
      final result = await _repository.sendImageMessage(
        chatId: _chatId,
        imageUrl: imageUrl,
      );

      setLoaded();
      return result;
    } catch (e) {
      setError('Error al enviar imagen: $e');
      return false;
    }
  }

  // Tomar y enviar foto desde la cámara
  Future<bool> sendImageFromCamera() async {
    try {
      if (_chatId.isEmpty) return false;

      // Tomar foto
      final imageFile = await _storageService.pickImageFromCamera();
      if (imageFile == null) return false;

      // Mostrar indicador de carga
      setLoading();

      // Subir imagen
      final imageUrl = await _storageService.uploadImage(
        imageFile,
        'chat_images',
        _chatId,
      );

      if (imageUrl == null) {
        setError('Error al subir imagen');
        return false;
      }

      // Enviar mensaje con la URL de la imagen
      final result = await _repository.sendImageMessage(
        chatId: _chatId,
        imageUrl: imageUrl,
      );

      setLoaded();
      return result;
    } catch (e) {
      setError('Error al enviar imagen: $e');
      return false;
    }
  }

  // Enviar ubicación actual
  Future<bool> sendCurrentLocation() async {
    try {
      if (_chatId.isEmpty) return false;

      // TODO: Implementar obtención de ubicación actual
      // Puedes usar el LocationService que ya tienes
      // Por ahora, usamos ubicación de ejemplo
      const latitude = -16.409047;
      const longitude = -71.537452;

      final result = await _repository.sendLocationMessage(
        chatId: _chatId,
        latitude: latitude,
        longitude: longitude,
        address: 'Mi ubicación actual',
      );

      return result;
    } catch (e) {
      setError('Error al enviar ubicación: $e');
      return false;
    }
  }
}
