// lib/presentation/view_models/chat_list_view_model.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/models/chat_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../common/base_view_model.dart';

class ChatListViewModel extends BaseViewModel {
  final ChatRepository _repository = ChatRepository();

  List<ChatModel> _chats = [];
  List<ChatModel> get chats => _chats;

  bool _isTechnicianMode = false; // Track if we're in technician mode
  bool get isTechnicianMode => _isTechnicianMode;

  StreamSubscription? _chatsSubscription;

  // Set the mode (client or technician)
  void setTechnicianMode(bool isTechnician) {
    if (_isTechnicianMode != isTechnician) {
      _isTechnicianMode = isTechnician;
      // Reload chats when mode changes
      startListeningToChats();
    }
  }

  // Start listening to chats based on current mode
  Future<void> startListeningToChats() async {
    try {
      setLoading();

      // Cancel existing subscription if any
      _chatsSubscription?.cancel();

      // Choose the appropriate stream based on mode
      final Stream<List<ChatModel>> stream =
          _isTechnicianMode
              ? _repository.getTechnicianChatsStream()
              : _repository.getUserChatsStream();

      // Subscribe to the stream
      _chatsSubscription = stream.listen(
        (chats) {
          _chats = chats;
          setLoaded();
        },
        onError: (e) {
          print('Error in chat stream: $e');
          setError('Error loading chats: $e');
        },
      );
    } catch (e) {
      print('Error starting chat listener: $e');
      setError('Error starting chat listener: $e');
    }
  }

  // Delete a chat
  Future<bool> deleteChat(String chatId) async {
    try {
      final result = await _repository.deleteChat(chatId);
      return result;
    } catch (e) {
      setError('Error deleting chat: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    super.dispose();
  }
}
