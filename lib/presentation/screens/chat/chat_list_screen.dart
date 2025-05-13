// lib/presentation/screens/chat/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Iniciar la escucha de chats al cargar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatListViewModel>(
        context,
        listen: false,
      ).startListeningToChats();
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
              return ChatListItem(
                chat: chat,
                onTap: () => _navigateToChatDetail(chat.id),
                onDelete: () => _confirmDeleteChat(chat.id),
              );
            },
          );
        },
      ),
    );
  }

  // Navegar a la pantalla de detalle del chat
  void _navigateToChatDetail(String chatId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailScreen(chatId: chatId)),
    );
  }

  // Confirmar eliminación del chat
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

  // Eliminar chat
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
}
