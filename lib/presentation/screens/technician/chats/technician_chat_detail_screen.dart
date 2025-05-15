import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/chat_model.dart';
import '../../../view_models/chat_detail_view_model.dart';
import '../../../view_models/auth_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../view_models/service_status_view_model.dart';
import '../../../screens/chat/components/chat_app_bar.dart';
import '../../../screens/chat/components/chat_input.dart';
import '../../../screens/chat/components/message_bubble.dart';
import '../../../screens/chat/components/service_status_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TechnicianChatDetailScreen extends StatefulWidget {
  final String chatId;

  const TechnicianChatDetailScreen({Key? key, required this.chatId})
    : super(key: key);

  @override
  _TechnicianChatDetailScreenState createState() =>
      _TechnicianChatDetailScreenState();
}

class _TechnicianChatDetailScreenState
    extends State<TechnicianChatDetailScreen> {
  final _scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _clientId = '';

  @override
  void initState() {
    super.initState();

    // Iniciar la escucha de mensajes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Importante: Obtener el ViewModel después de que se construye el árbol de widgets
      final chatViewModel = Provider.of<ChatDetailViewModel>(
        context,
        listen: false,
      );

      // NUEVO: Obtener el ServiceStatusViewModel
      final serviceViewModel = Provider.of<ServiceStatusViewModel>(
        context,
        listen: false,
      );

      // Iniciar escucha de mensajes
      chatViewModel.startListeningToMessages(widget.chatId);
      print('Escuchando mensajes para chat: ${widget.chatId}');

      // NUEVO: Cargar información del servicio para este chat
      serviceViewModel.loadServiceByChatId(widget.chatId);

      // Obtener el ID del cliente
      _getClientId();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Obtener el ID del cliente en el chat
  Future<void> _getClientId() async {
    try {
      final chatDoc =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatId)
              .get();

      if (chatDoc.exists) {
        final chatData = chatDoc.data() as Map<String, dynamic>;
        final clientId = chatData['clientId'] as String?;

        if (clientId != null) {
          setState(() {
            _clientId = clientId;
          });
        }
      }
    } catch (e) {
      print('Error al obtener id del cliente: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ChatAppBar(userId: _clientId),
      ),
      body: Column(
        children: [
          // Tarjeta de estado del servicio con botones de acción
          ServiceStatusCard(chatId: widget.chatId),

          // Lista de mensajes
          Expanded(
            child: Consumer<ChatDetailViewModel>(
              builder: (context, viewModel, child) {
                // Imprimir estado para debug
                print(
                  'Chat view state: ${viewModel.state}, messages: ${viewModel.messages.length}',
                );

                if (viewModel.isLoading && viewModel.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error al cargar mensajes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            viewModel.errorMessage,
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => viewModel.reloadMessages(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay mensajes aún',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Envía un mensaje para iniciar la conversación',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Desplazar al último mensaje cuando se carguen
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final message = viewModel.messages[index];
                    final isMe = message.senderId == currentUserId;

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
              },
            ),
          ),

          // Área de entrada de mensajes
          Consumer<ChatDetailViewModel>(
            builder: (context, viewModel, _) {
              return ChatInput(
                onSendMessage: (text) {
                  viewModel.sendTextMessage(text);
                  _scrollToBottom();
                },
                onSendImage: () async {
                  final success = await viewModel.sendImageFromGallery();
                  if (success) _scrollToBottom();
                },
                onTakePhoto: () async {
                  final success = await viewModel.sendImageFromCamera();
                  if (success) _scrollToBottom();
                },
                onSendLocation: () async {
                  final success = await viewModel.sendCurrentLocation();
                  if (success) _scrollToBottom();
                },
              );
            },
          ),
        ],
      ),
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
