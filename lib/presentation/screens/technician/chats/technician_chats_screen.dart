// lib/presentation/screens/technician/chats/technician_chats_screen.dart (corregido)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/chat_model.dart'; // Importar el modelo de chat
import '../../../view_models/chat_list_view_model.dart';
import '../../chat/chat_detail_screen.dart';

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
          return Center(child: CircularProgressIndicator());
        }

        // Si hay error al cargar chats
        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                SizedBox(height: 16),
                Text(
                  'Error al cargar chats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  viewModel.errorMessage,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => viewModel.startListeningToChats(),
                  icon: Icon(Icons.refresh),
                  label: Text('Reintentar'),
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
                SizedBox(height: 16),
                Text(
                  'No tienes chats activos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Envía propuestas a clientes para iniciar conversaciones',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => viewModel.startListeningToChats(),
                  icon: Icon(Icons.refresh),
                  label: Text('Actualizar'),
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

  // Corregido: agregamos el parámetro del chat y el índice
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
        style: TextStyle(fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 4),
          if (chat.requestId != null && chat.requestId!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        // Navegar al detalle del chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(chatId: chat.id),
          ),
        );
      },
    );
  }

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
