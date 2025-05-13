// lib/presentation/view_models/chat_list_view_model.dart (ACTUALIZADO)
import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/models/chat_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../common/base_view_model.dart';

class ChatListViewModel extends BaseViewModel {
  final ChatRepository _repository = ChatRepository();

  List<ChatModel> _chats = [];
  List<ChatModel> get chats => _chats;

  StreamSubscription? _clientChatsSubscription;
  StreamSubscription? _technicianChatsSubscription;

  // Iniciar escucha de chats
  void startListeningToChats() {
    try {
      setLoading();

      // Cancelar subscripciones anteriores si existen
      _clientChatsSubscription?.cancel();
      _technicianChatsSubscription?.cancel();

      // Lista local para almacenar temporalmente los chats
      final List<ChatModel> allChats = [];

      // Flag para saber cuando se han cargado ambos tipos de chats
      bool clientChatsLoaded = false;
      bool technicianChatsLoaded = false;

      // Función para verificar si todos los chats se han cargado
      void checkAllLoaded() {
        if (clientChatsLoaded && technicianChatsLoaded) {
          // Ordenar por última actividad
          allChats.sort(
            (a, b) => (b.lastMessageTime ?? DateTime(2000)).compareTo(
              a.lastMessageTime ?? DateTime(2000),
            ),
          );

          _chats = List.from(allChats);
          setLoaded();
        }
      }

      // Subscribirse a chats como cliente
      _clientChatsSubscription = _repository.getUserChatsStream().listen(
        (clientChats) {
          // Reemplazar los chats de cliente en la lista
          allChats.removeWhere(
            (chat) => clientChats.any((c) => c.id == chat.id),
          );
          allChats.addAll(clientChats);

          clientChatsLoaded = true;
          checkAllLoaded();
        },
        onError: (e) {
          print('Error en stream de chats de cliente: $e');
          clientChatsLoaded = true;
          checkAllLoaded();
        },
      );

      // Subscribirse a chats como técnico
      _technicianChatsSubscription = _repository
          .getTechnicianChatsStream()
          .listen(
            (technicianChats) {
              // Reemplazar los chats de técnico en la lista
              allChats.removeWhere(
                (chat) => technicianChats.any((c) => c.id == chat.id),
              );
              allChats.addAll(technicianChats);

              technicianChatsLoaded = true;
              checkAllLoaded();
            },
            onError: (e) {
              print('Error en stream de chats de técnico: $e');
              technicianChatsLoaded = true;
              checkAllLoaded();
            },
          );
    } catch (e) {
      print('Error al iniciar escucha de chats: $e');
      setError('Error al iniciar escucha de chats: $e');
    }
  }

  // Eliminar un chat
  Future<bool> deleteChat(String chatId) async {
    try {
      // No cambiamos a estado de carga para evitar flickering
      final result = await _repository.deleteChat(chatId);

      if (result) {
        // La actualización vendrá por el stream, no modificamos manualmente
        return true;
      } else {
        setError('No se pudo eliminar el chat');
        return false;
      }
    } catch (e) {
      setError('Error al eliminar chat: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _clientChatsSubscription?.cancel();
    _technicianChatsSubscription?.cancel();
    super.dispose();
  }
}
