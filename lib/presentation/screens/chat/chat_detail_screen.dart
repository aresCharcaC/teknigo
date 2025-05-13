// lib/presentation/screens/chat/chat_detail_screen.dart (CORREGIDO)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/message_model.dart';
import '../../view_models/chat_detail_view_model.dart';
import 'components/chat_app_bar.dart';
import 'components/chat_input.dart';
import 'components/message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _otherUserId = '';

  @override
  void initState() {
    super.initState();

    // Iniciar la escucha de mensajes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Importante: Obtener el ViewModel después de que se construye el árbol de widgets
      final viewModel = Provider.of<ChatDetailViewModel>(
        context,
        listen: false,
      );

      // Iniciar escucha - importante: verificar que este método se ejecuta
      viewModel.startListeningToMessages(widget.chatId);
      print('Escuchando mensajes para chat: ${widget.chatId}');

      // Obtener el ID del otro usuario
      _getOtherUserId();
    });
  }

  Future<void> _testSendMessage() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;

      if (auth.currentUser == null) {
        print('No hay usuario autenticado');
        return;
      }

      print('Enviando mensaje de prueba a Firestore...');

      // Crear documento de mensaje directamente
      await firestore.collection('messages').add({
        'chatId': widget.chatId,
        'senderId': auth.currentUser!.uid,
        'type': 'text',
        'content': 'Mensaje de prueba directo ${DateTime.now().toString()}',
        'timestamp': Timestamp.now(),
        'isRead': false,
      });

      // Actualizar último mensaje
      await firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': 'Mensaje de prueba',
        'lastMessageTime': Timestamp.now(),
      });

      print('Mensaje de prueba enviado correctamente');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mensaje de prueba enviado')));
    } catch (e) {
      print('Error al enviar mensaje de prueba: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Obtener el ID del otro usuario en el chat
  Future<void> _getOtherUserId() async {
    try {
      final chatDoc =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatId)
              .get();

      if (chatDoc.exists) {
        final chatData = chatDoc.data() as Map<String, dynamic>;
        final clientId = chatData['clientId'] as String?;
        final technicianId = chatData['technicianId'] as String?;

        if (clientId != null && technicianId != null) {
          setState(() {
            _otherUserId = currentUserId == clientId ? technicianId : clientId;
          });
          print('Otro usuario en el chat: $_otherUserId');
        }
      }
    } catch (e) {
      print('Error al obtener el otro usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ChatAppBar(userId: _otherUserId),
      ),
      body: Consumer<ChatDetailViewModel>(
        builder: (context, viewModel, child) {
          print(
            'Chat view state: ${viewModel.state}, messages: ${viewModel.messages.length}',
          );

          return Column(
            children: [
              Expanded(child: _buildMessagesList(viewModel)),

              if (viewModel.isLoading) LinearProgressIndicator(),

              ChatInput(
                onSendMessage: (text) {
                  print('Enviando mensaje: $text');
                  viewModel.sendTextMessage(text);
                  _scrollToBottom();
                },
                onSendImage: () async {
                  print('Intentando enviar imagen...');
                  final success = await viewModel.sendImageFromGallery();
                  print('Resultado envío imagen: $success');
                  if (success) _scrollToBottom();
                },
                onTakePhoto: () async {
                  print('Intentando tomar foto...');
                  final success = await viewModel.sendImageFromCamera();
                  print('Resultado envío foto: $success');
                  if (success) _scrollToBottom();
                },
                onSendLocation: () async {
                  print('Intentando enviar ubicación...');
                  final success = await viewModel.sendCurrentLocation();
                  print('Resultado envío ubicación: $success');
                  if (success) _scrollToBottom();
                },
              ),
            ],
          );
        },
      ),
      // 👇 Aquí agregas correctamente tu botón flotante
      floatingActionButton: FloatingActionButton(
        onPressed: _testSendMessage,
        child: const Icon(Icons.science),
        tooltip: 'Prueba Firestore',
      ),
    );
  }

  // Construir la lista de mensajes
  Widget _buildMessagesList(ChatDetailViewModel viewModel) {
    if (viewModel.isLoading && viewModel.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error: ${viewModel.errorMessage}',
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () => viewModel.startListeningToMessages(widget.chatId),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (viewModel.messages.isEmpty) {
      return Center(
        child: Text(
          'No hay mensajes aún',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    // Importante: Desplazar al último mensaje cuando se carguen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = viewModel.messages[index];
        final isMe = message.senderId == currentUserId;

        // Si es un mensaje consecutivo del mismo usuario, no mostrar avatar
        bool showAvatar = true;
        if (index > 0) {
          final prevMessage = viewModel.messages[index - 1];
          if (prevMessage.senderId == message.senderId) {
            showAvatar = false;
          }
        }

        return MessageBubble(
          message: message,
          isMe: isMe,
          showAvatar: showAvatar,
        );
      },
    );
  }

  // Desplazar al último mensaje
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        print('Error al desplazar: $e');
      }
    }
  }
}
