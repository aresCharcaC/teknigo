// lib/presentation/screens/chat/chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/message_model.dart';
import '../../view_models/chat_detail_view_model.dart';
import '../../view_models/service_status_view_model.dart';
import '../../view_models/confirmation_view_model.dart'; // Nuevo
import 'components/chat_app_bar.dart';
import 'components/chat_input.dart';
import 'components/message_bubble.dart';
import 'components/service_status_card.dart';
import '../../widgets/confirmation_dialog.dart'; // Nuevo

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _technicianId = '';
  bool _checkedConfirmation = false;

  @override
  void initState() {
    super.initState();

    // Start listening for messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Important: Get ViewModels after widget tree is built
      final chatViewModel = Provider.of<ChatDetailViewModel>(
        context,
        listen: false,
      );

      // Get ServiceStatusViewModel
      final serviceViewModel = Provider.of<ServiceStatusViewModel>(
        context,
        listen: false,
      );

      // Get ConfirmationViewModel (Nuevo)
      final confirmationViewModel = Provider.of<ConfirmationViewModel>(
        context,
        listen: false,
      );

      // Start message listening
      chatViewModel.startListeningToMessages(widget.chatId);

      // Load service info for this chat
      serviceViewModel.loadServiceByChatId(widget.chatId);

      // Get technician ID
      _getTechnicianId();

      // Check for pending confirmations (Nuevo)
      _checkPendingConfirmations();
    });
  }

  // Método para verificar si hay confirmaciones pendientes (Nuevo)
  Future<void> _checkPendingConfirmations() async {
    if (_checkedConfirmation) return;

    final confirmationViewModel = Provider.of<ConfirmationViewModel>(
      context,
      listen: false,
    );

    final hasPendingConfirmation = await confirmationViewModel
        .loadPendingConfirmationForChat(widget.chatId);

    if (hasPendingConfirmation && mounted) {
      _checkedConfirmation = true;

      // Mostrar el diálogo de confirmación
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConfirmationDialog();
      });
    } else {
      _checkedConfirmation = true;
    }
  }

  // Método para mostrar el diálogo de confirmación (Nuevo)
  void _showConfirmationDialog() {
    final confirmationViewModel = Provider.of<ConfirmationViewModel>(
      context,
      listen: false,
    );

    if (confirmationViewModel.pendingConfirmation == null) return;

    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder:
          (context) => ConfirmationDialog(
            confirmation: confirmationViewModel.pendingConfirmation!,
            onConfirm: (isAccepted) async {
              // Procesar la confirmación
              final result = await confirmationViewModel.resolveConfirmation(
                isAccepted,
              );

              if (result.isSuccess && mounted) {
                // Cerrar el diálogo
                Navigator.of(context).pop();

                // Mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAccepted
                          ? 'Has confirmado que el trabajo está completado'
                          : 'Has indicado que el trabajo aún no está completado',
                    ),
                    backgroundColor: isAccepted ? Colors.green : Colors.orange,
                  ),
                );

                // Si se aceptó y es necesario, mostrar diálogo de calificación
                if (isAccepted) {
                  // Opcional: Mostrar diálogo para calificar al técnico
                }
              } else if (result.isError && mounted) {
                // Mostrar error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${result.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Get technician ID from chat
  Future<void> _getTechnicianId() async {
    try {
      final chatDoc =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatId)
              .get();

      if (chatDoc.exists) {
        final chatData = chatDoc.data() as Map<String, dynamic>;
        final technicianId = chatData['technicianId'] as String?;

        if (technicianId != null) {
          setState(() {
            _technicianId = technicianId;
          });
        }
      }
    } catch (e) {
      print('Error getting technician ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ChatAppBar(userId: _technicianId),
      ),
      body: Column(
        children: [
          // Service status card
          ServiceStatusCard(chatId: widget.chatId),

          // Message list
          Expanded(
            child: Consumer<ChatDetailViewModel>(
              builder: (context, viewModel, child) {
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
                          icon: Icon(Icons.refresh),
                          label: Text('Reintentar'),
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
                        Text(
                          'No hay mensajes aún',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Envía el primer mensaje para iniciar la conversación',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Scroll to last message when loaded
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

                    // If it's a consecutive message from the same user, don't show avatar
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

          // Message input area
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

  // Scroll to last message
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        print('Error scrolling: $e');
      }
    }
  }
}
