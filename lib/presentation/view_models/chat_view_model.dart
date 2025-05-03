import 'package:flutter/material.dart';
import '../../data/repositories/chat_repository.dart';
import '../common/base_view_model.dart';
import '../common/resource.dart';

/// Clase para representar un mensaje
class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });
}

/// Clase para representar un chat
class Chat {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<Message> messages;

  Chat({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.messages = const [],
  });
}

/// ViewModel para gestionar los chats
class ChatViewModel extends BaseViewModel {
  final ChatRepository _repository = ChatRepository();

  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  List<Chat> _filteredChats = [];
  List<Chat> get filteredChats => _filteredChats;

  String _currentChatId = '';
  String get currentChatId => _currentChatId;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Cargar todos los chats
  Future<void> loadChats() async {
    return executeAsync<void>(() async {
      final result = await _repository.getChats();
      _chats = result;
      _filterChats();
    });
  }

  /// Cargar mensajes de un chat específico
  Future<void> loadMessages(String chatId) async {
    return executeAsync<void>(() async {
      _currentChatId = chatId;
      final result = await _repository.getMessages(chatId);

      // Actualizar los mensajes en el chat correspondiente
      final index = _chats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        final chat = _chats[index];
        _chats[index] = Chat(
          id: chat.id,
          userId: chat.userId,
          userName: chat.userName,
          userImage: chat.userImage,
          lastMessage: chat.lastMessage,
          lastMessageTime: chat.lastMessageTime,
          unreadCount: 0, // Marcar como leídos
          messages: result,
        );

        // También actualizar en filteredChats si es necesario
        final filteredIndex = _filteredChats.indexWhere(
          (chat) => chat.id == chatId,
        );
        if (filteredIndex != -1) {
          _filteredChats[filteredIndex] = _chats[index];
        }
      }

      // Marcar mensajes como leídos
      await _repository.markChatAsRead(chatId);
    });
  }

  /// Enviar un mensaje
  Future<Resource<bool>> sendMessage(String chatId, String text) async {
    try {
      setLoading();

      final success = await _repository.sendMessage(chatId, text);

      if (success) {
        // Recargar mensajes para actualizar la UI
        await loadMessages(chatId);
      }

      setLoaded();
      return Resource.success(success);
    } catch (e) {
      final errorMessage = 'Error al enviar mensaje: $e';
      setError(errorMessage);
      return Resource.error(errorMessage);
    }
  }

  /// Buscar en los chats
  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    _filterChats();
    notifyListeners();
  }

  /// Limpiar búsqueda
  void clearSearch() {
    _searchQuery = '';
    _filterChats();
    notifyListeners();
  }

  /// Filtrar chats basado en la búsqueda
  void _filterChats() {
    if (_searchQuery.isEmpty) {
      _filteredChats = List<Chat>.from(_chats);
    } else {
      _filteredChats =
          _chats.where((chat) {
            return chat.userName.toLowerCase().contains(_searchQuery);
          }).toList();
    }
  }
}
