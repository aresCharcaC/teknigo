// lib/presentation/screens/technician/chats/technician_chats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/chat_model.dart';
import '../../../view_models/chat_list_view_model.dart';
import 'technician_chat_detail_screen.dart'; // Importamos la nueva pantalla

class TechnicianChatsScreen extends StatefulWidget {
  const TechnicianChatsScreen({Key? key}) : super(key: key);

  @override
  _TechnicianChatsScreenState createState() => _TechnicianChatsScreenState();
}

class _TechnicianChatsScreenState extends State<TechnicianChatsScreen> {
  @override
  void initState() {
    super.initState();

    // Cargar los chats al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatListViewModel>(
        context,
        listen: false,
      ).startListeningToChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatListViewModel>(
      builder: (context, viewModel, child) {
        // Mostrar indicador de carga
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si hay error al cargar chats
        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar chats',
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
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Si no hay chats
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
                const Text(
                  'Envía propuestas a clientes para iniciar conversaciones',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => viewModel.startListeningToChats(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualizar'),
                ),
              ],
            ),
          );
        }

        // Mostrar lista de chats
        return RefreshIndicator(
          onRefresh: () async {
            viewModel.startListeningToChats();
          },
          child: ListView.builder(
            itemCount: viewModel.chats.length,
            itemBuilder: (context, index) {
              final chat = viewModel.chats[index];
              return _buildChatItem(context, chat, index, viewModel);
            },
          ),
        );
      },
    );
  }

  // Construir un elemento de chat
  Widget _buildChatItem(
    BuildContext context,
    ChatModel chat,
    int index,
    ChatListViewModel viewModel,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.person, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        'Cliente #${index + 1}', // Reemplazar con nombre real cuando esté disponible
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage ?? 'No hay mensajes aún',
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Servicio',
                style: TextStyle(color: Colors.green.shade700, fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: () {
        // Navegar a la pantalla de detalle del chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TechnicianChatDetailScreen(chatId: chat.id),
          ),
        );
      },
    );
  }

  // Formatear fecha/hora
  String _formatDateTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

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
