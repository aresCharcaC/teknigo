// lib/presentation/screens/technician/technician_chats_screen.dart
import 'package:flutter/material.dart';

class TechnicianChatsScreen extends StatefulWidget {
  const TechnicianChatsScreen({Key? key}) : super(key: key);

  @override
  _TechnicianChatsScreenState createState() => _TechnicianChatsScreenState();
}

class _TechnicianChatsScreenState extends State<TechnicianChatsScreen> {
  bool _isLoading = false;

  // Lista de chats (datos simulados)
  final List<ChatItem> _chats = [
    ChatItem(
      id: '1',
      clientName: 'Laura Torres',
      lastMessage: '¿A qué hora llegarías mañana?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      serviceTitle: 'Reparación de computadora',
      profileImage: null,
    ),
    ChatItem(
      id: '2',
      clientName: 'Pedro Ramírez',
      lastMessage: 'Ok, gracias por la información',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      serviceTitle: 'Instalación eléctrica',
      profileImage: null,
    ),
    ChatItem(
      id: '3',
      clientName: 'María González',
      lastMessage: 'Necesito que me ayudes con un problema',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      serviceTitle: 'Mantenimiento de aire acondicionado',
      profileImage: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildChatsContent();
  }

  // Construir el contenido de chats
  Widget _buildChatsContent() {
    if (_chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No tienes conversaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Las conversaciones con clientes aparecerán aquí',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return _buildChatItem(chat);
      },
    );
  }

  // Construir un elemento de chat
  Widget _buildChatItem(ChatItem chat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar a la conversación individual
          _navigateToChat(chat);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar del cliente
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage:
                        chat.profileImage != null
                            ? NetworkImage(chat.profileImage!)
                            : null,
                    child:
                        chat.profileImage == null
                            ? Text(
                              chat.clientName.isNotEmpty
                                  ? chat.clientName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            )
                            : null,
                  ),
                  if (chat.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${chat.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Información del chat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nombre del cliente
                        Expanded(
                          child: Text(
                            chat.clientName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  chat.unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Hora del último mensaje
                        Text(
                          _formatTimestamp(chat.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight:
                                chat.unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Título del servicio
                    Text(
                      chat.serviceTitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Último mensaje
                    Text(
                      chat.lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            chat.unreadCount > 0
                                ? Colors.black
                                : Colors.grey.shade600,
                        fontWeight:
                            chat.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Formatear la hora del mensaje
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  // Navegar a la conversación individual
  void _navigateToChat(ChatItem chat) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChatDetailScreen(chat: chat)),
    );
  }
}

// Clase para elementos de chat
class ChatItem {
  final String id;
  final String clientName;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final String serviceTitle;
  final String? profileImage;

  ChatItem({
    required this.id,
    required this.clientName,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.serviceTitle,
    this.profileImage,
  });
}

// Pantalla de detalle de chat
class ChatDetailScreen extends StatefulWidget {
  final ChatItem chat;

  const ChatDetailScreen({Key? key, required this.chat}) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Lista de mensajes (datos simulados)
  late List<MessageItem> _messages;

  @override
  void initState() {
    super.initState();
    // Inicializar con mensajes simulados
    _messages = [
      MessageItem(
        id: '1',
        senderId: 'client',
        text: 'Hola, necesito ayuda con ${widget.chat.serviceTitle}',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        isSeen: true,
      ),
      MessageItem(
        id: '2',
        senderId: 'me',
        text: 'Hola, ¿en qué puedo ayudarte específicamente?',
        timestamp: DateTime.now().subtract(
          const Duration(days: 1, hours: 1, minutes: 45),
        ),
        isSeen: true,
      ),
      MessageItem(
        id: '3',
        senderId: 'client',
        text:
            'Tengo un problema con ${widget.chat.serviceTitle.toLowerCase()}. ¿Podrías venir a revisarlo?',
        timestamp: DateTime.now().subtract(
          const Duration(days: 1, hours: 1, minutes: 30),
        ),
        isSeen: true,
      ),
      MessageItem(
        id: '4',
        senderId: 'me',
        text: 'Claro, podría ir mañana en la tarde. ¿Te parece bien?',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        isSeen: true,
      ),
      MessageItem(
        id: '5',
        senderId: 'client',
        text: '¿A qué hora llegarías mañana?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isSeen: false,
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Enviar un nuevo mensaje
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        MessageItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'me',
          text: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isSeen: false,
        ),
      );
      _messageController.clear();
    });

    // Desplazar hacia el último mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chat.clientName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.chat.serviceTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Detalles del servicio'),
                ),
              );
            },
            tooltip: 'Detalles del servicio',
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == 'me';

                return _buildMessageBubble(message, isMe);
              },
            ),
          ),

          // Barra de composición de mensajes
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente: Adjuntar archivos'),
                      ),
                    );
                  },
                  tooltip: 'Adjuntar',
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: _sendMessage,
                  tooltip: 'Enviar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construir burbuja de mensaje
  Widget _buildMessageBubble(MessageItem message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatChatTimestamp(message.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isSeen ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isSeen ? Colors.blue : Colors.grey.shade600,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Formatear la hora para el mensaje
  String _formatChatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

// Clase para mensajes
class MessageItem {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isSeen;

  MessageItem({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isSeen,
  });
}
