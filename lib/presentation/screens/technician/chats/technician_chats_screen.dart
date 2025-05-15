// lib/presentation/screens/technician/chats/technician_chats_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/chat_model.dart';
import '../../../view_models/chat_list_view_model.dart';
import 'technician_chat_detail_screen.dart';

class TechnicianChatsScreen extends StatefulWidget {
  const TechnicianChatsScreen({Key? key}) : super(key: key);

  @override
  _TechnicianChatsScreenState createState() => _TechnicianChatsScreenState();
}

class _TechnicianChatsScreenState extends State<TechnicianChatsScreen> {
  @override
  void initState() {
    super.initState();

    // Ensure we're in technician mode and load chats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ChatListViewModel>(context, listen: false);
      viewModel.setTechnicianMode(true);
      viewModel.startListeningToChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatListViewModel>(
      builder: (context, viewModel, child) {
        // Show loading indicator
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error if any
        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error loading chats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.errorMessage,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => viewModel.startListeningToChats(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Show empty state if no chats
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
                  'No active chats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Send proposals to clients to start conversations',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => viewModel.startListeningToChats(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        // Show chat list
        return RefreshIndicator(
          onRefresh: () async {
            viewModel.startListeningToChats();
          },
          child: ListView.builder(
            itemCount: viewModel.chats.length,
            itemBuilder: (context, index) {
              final chat = viewModel.chats[index];
              return _buildChatItem(context, chat, viewModel);
            },
          ),
        );
      },
    );
  }

  // Build a chat list item with client info
  Widget _buildChatItem(
    BuildContext context,
    ChatModel chat,
    ChatListViewModel viewModel,
  ) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(chat.clientId)
              .get(),
      builder: (context, snapshot) {
        // Client name and photo placeholder
        String clientName = 'Cliente';
        String? clientPhoto;

        // Extract client info if available
        if (snapshot.hasData && snapshot.data!.exists) {
          final clientData = snapshot.data!.data() as Map<String, dynamic>?;
          if (clientData != null) {
            clientName = clientData['name'] ?? 'Cliente';
            clientPhoto = clientData['profileImage'];
          }
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            backgroundImage:
                clientPhoto != null ? NetworkImage(clientPhoto) : null,
            child:
                clientPhoto == null
                    ? Text(
                      clientName.isNotEmpty ? clientName[0].toUpperCase() : 'C',
                    )
                    : null,
          ),
          title: Text(
            clientName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            chat.lastMessage ?? 'No messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDateTime(chat.lastMessageTime ?? chat.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
          onTap: () {
            // Navigate to chat detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TechnicianChatDetailScreen(chatId: chat.id),
              ),
            );
          },
        );
      },
    );
  }

  // Format date/time
  String _formatDateTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'just now';
    }
  }
}
