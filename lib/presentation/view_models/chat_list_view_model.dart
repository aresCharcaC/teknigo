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

  bool _isTechnicianMode = false;
  bool get isTechnicianMode => _isTechnicianMode;

  StreamSubscription? _chatsSubscription;

  // Set the mode (client or technician)
  void setTechnicianMode(bool isTechnician) {
    if (_isTechnicianMode != isTechnician) {
      _isTechnicianMode = isTechnician;
      print('ChatListViewModel: Setting technician mode to $isTechnician');
      // Reload chats when mode changes
      startListeningToChats();
    }
  }

  // Start listening to chats based on current mode
  void startListeningToChats() {
    try {
      print(
        'ChatListViewModel: Starting to listen for chats in ${_isTechnicianMode ? "technician" : "client"} mode',
      );
      setLoading();

      // Cancel existing subscription if any
      if (_chatsSubscription != null) {
        print('ChatListViewModel: Cancelling existing subscription');
        _chatsSubscription!.cancel();
        _chatsSubscription = null;
      }

      // Choose the appropriate stream based on mode
      final Stream<List<ChatModel>> stream =
          _isTechnicianMode
              ? _repository.getTechnicianChatsStream()
              : _repository.getUserChatsStream();

      // Subscribe to the stream
      _chatsSubscription = stream.listen(
        (chats) {
          print('ChatListViewModel: Received ${chats.length} chats');
          _chats = chats;
          setLoaded();
        },
        onError: (e) {
          print('ChatListViewModel: Error in chat stream: $e');
          setError('Error loading chats: $e');
        },
      );
    } catch (e) {
      print('ChatListViewModel: Error starting chat listener: $e');
      setError('Error starting chat listener: $e');
    }
  }

  // Delete a chat
  Future<bool> deleteChat(String chatId) async {
    try {
      print('ChatListViewModel: Deleting chat: $chatId');
      final result = await _repository.deleteChat(chatId);
      return result;
    } catch (e) {
      print('ChatListViewModel: Error deleting chat: $e');
      setError('Error deleting chat: $e');
      return false;
    }
  }

  @override
  void dispose() {
    print('ChatListViewModel: Disposing');
    if (_chatsSubscription != null) {
      _chatsSubscription!.cancel();
      _chatsSubscription = null;
    }
    super.dispose();
  }
}
