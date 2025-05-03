import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../view_models/chat_view_model.dart';

/// Pantalla que muestra los chats activos del técnico con clientes
class TechnicianChatsScreen extends StatefulWidget {
  const TechnicianChatsScreen({Key? key}) : super(key: key);

  @override
  _TechnicianChatsScreenState createState() => _TechnicianChatsScreenState();
}

class _TechnicianChatsScreenState extends State<TechnicianChatsScreen> {
  @override
  void initState() {
    super.initState();
    // En una implementación real, cargaríamos los chats del técnico aquí
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Buscador de chats
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar chats...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                // Implementar búsqueda de chats
              },
            ),
          ),
        ),

        // Contenido principal
        Expanded(child: _buildChatsList()),
      ],
    );
  }

  Widget _buildChatsList() {
    // Lista simulada de chats para fines de demostración
    final List<ChatItem> chats = [
      ChatItem(
        id: '1',
        userName: 'María González',
        lastMessage:
            'Gracias por resolver el problema eléctrico. ¿Cuándo podrías venir a revisar los enchufes?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        unreadCount: 2,
        userImage: null,
      ),
      ChatItem(
        id: '2',
        userName: 'Pedro Ramírez',
        lastMessage: 'Entendido, estaré esperando a esa hora.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        userImage: null,
      ),
      ChatItem(
        id: '3',
        userName: 'Ana Suárez',
        lastMessage: 'El servicio fue excelente, muchas gracias.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        userImage: null,
      ),
    ];

    if (chats.isEmpty) {
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
              'Los chats con clientes aparecerán aquí',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildChatItem(ChatItem chat) {
    return InkWell(
      onTap: () {
        // Navegar a la pantalla de detalle del chat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abrir chat con ${chat.userName}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          color: chat.unreadCount > 0 ? Colors.blue.shade50 : null,
        ),
        child: Row(
          children: [
            // Avatar del usuario
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                chat.userName.isNotEmpty ? chat.userName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Información del chat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y hora
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatChatTime(chat.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Último mensaje
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            color:
                                chat.unreadCount > 0
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                            fontWeight:
                                chat.unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatChatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'ahora';
    }
  }
}

/// Modelo para un elemento de chat
class ChatItem {
  final String id;
  final String userName;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final String? userImage;

  ChatItem({
    required this.id,
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    this.userImage,
  });
}
