// lib/presentation/screens/chat/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/chat_model.dart';
import '../../view_models/chat_list_view_model.dart';
import 'components/chat_list_item.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();

    // Ensure we're in client mode and load chats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ChatListViewModel>(context, listen: false);
      viewModel.setTechnicianMode(false);
      viewModel.startListeningToChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Chats')),
      body: Consumer<ChatListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.startListeningToChats(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes chats activos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los chats aparecerán aquí cuando envíes\no recibas propuestas',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: viewModel.chats.length,
            itemBuilder: (context, index) {
              final chat = viewModel.chats[index];
              return _buildChatListItem(context, chat, viewModel);
            },
          );
        },
      ),
    );
  }

  // Build a chat list item with technician info
  Widget _buildChatListItem(
    BuildContext context,
    ChatModel chat,
    ChatListViewModel viewModel,
  ) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(chat.technicianId)
              .get(),
      builder: (context, snapshot) {
        // Technician name and photo placeholder
        String technicianName = 'Técnico';
        String? technicianPhoto;

        // Extract technician info if available
        if (snapshot.hasData && snapshot.data!.exists) {
          final techData = snapshot.data!.data() as Map<String, dynamic>?;
          if (techData != null) {
            technicianName = techData['name'] ?? 'Técnico';
            technicianPhoto = techData['profileImage'];
          }
        }

        return Dismissible(
          key: Key(chat.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Eliminar chat'),
                    content: const Text(
                      '¿Estás seguro que deseas eliminar este chat?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('CANCELAR'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('ELIMINAR'),
                      ),
                    ],
                  ),
            );
          },
          onDismissed: (direction) => _deleteChat(chat.id),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade100,
              backgroundImage:
                  technicianPhoto != null
                      ? NetworkImage(technicianPhoto)
                      : null,
              child:
                  technicianPhoto == null
                      ? Text(
                        technicianName.isNotEmpty
                            ? technicianName[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                      : null,
            ),
            title: Text(
              technicianName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              chat.lastMessage ?? 'Sin mensajes',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (chat.lastMessageTime != null)
                  Text(
                    _formatTime(chat.lastMessageTime!),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                const SizedBox(height: 4),
                if (chat.requestId.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Servicio',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () => _navigateToChatDetail(chat.id),
            onLongPress: () => _confirmDeleteChat(chat.id),
          ),
        );
      },
    );
  }

  // Navigate to chat detail screen
  void _navigateToChatDetail(String chatId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailScreen(chatId: chatId)),
    );
  }

  // Confirm chat deletion
  void _confirmDeleteChat(String chatId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar chat'),
            content: const Text(
              '¿Estás seguro que deseas eliminar este chat? Esta acción eliminará la conversación para ambos usuarios.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteChat(chatId);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('ELIMINAR'),
              ),
            ],
          ),
    );
  }

  // Delete chat
  Future<void> _deleteChat(String chatId) async {
    final viewModel = Provider.of<ChatListViewModel>(context, listen: false);
    final result = await viewModel.deleteChat(chatId);

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Format time
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}
