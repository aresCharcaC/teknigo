// lib/presentation/screens/chat/chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/pending_confirmation_model.dart';
import '../../../core/enums/service_enums.dart';
import '../../view_models/chat_detail_view_model.dart';
import '../../view_models/service_status_view_model.dart';
import 'components/chat_app_bar.dart';
import 'components/chat_input.dart';
import 'components/message_bubble.dart';
import 'components/service_status_card.dart';
import 'components/service_rating_dialog.dart';

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
  bool _checkedService = false;

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

      // Start message listening
      chatViewModel.startListeningToMessages(widget.chatId);

      // Load service info for this chat
      serviceViewModel.loadServiceByChatId(widget.chatId).then((_) {
        // Después de cargar el servicio, verificar si necesita confirmación
        _checkServiceNeedsConfirmation();
      });

      // Get technician ID
      _getTechnicianId();
    });
  }

  // Método para verificar directamente si el servicio necesita confirmación
  void _checkServiceNeedsConfirmation() async {
    if (_checkedService) return;

    final serviceViewModel = Provider.of<ServiceStatusViewModel>(
      context,
      listen: false,
    );

    print("Verificando si el servicio necesita confirmación...");
    print("Usuario actual ID: $currentUserId");

    // Verificar si hay un servicio y si está en estado completado
    if (serviceViewModel.currentService != null &&
        serviceViewModel.currentService!.status == ServiceStatus.completed) {
      print("Servicio encontrado: ${serviceViewModel.currentService!.id}");
      print("Estado del servicio: ${serviceViewModel.currentService!.status}");
      print("ClientId: ${serviceViewModel.currentService!.clientId}");
      print("TechnicianId: ${serviceViewModel.currentService!.technicianId}");

      // SOLUCIÓN ESPECIAL: Como el clientId está vacío, necesitamos obtenerlo del chat
      if (serviceViewModel.currentService!.clientId.isEmpty) {
        print("ClientId está vacío, verificando ID del cliente en el chat...");

        try {
          // Obtener el documento del chat
          final chatDoc =
              await FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .get();

          if (chatDoc.exists) {
            final chatData = chatDoc.data() as Map<String, dynamic>?;
            final chatClientId = chatData?['clientId'] as String?;

            print("ClientId del chat: $chatClientId");

            // Verificar si el usuario actual es el cliente según el chat
            bool isClient = currentUserId == chatClientId;
            print("¿El usuario actual es el cliente según el chat? $isClient");

            if (isClient && chatClientId != null && chatClientId.isNotEmpty) {
              print(
                "¡Se detectó un servicio completado que necesita confirmación!",
              );
              _checkedService = true;

              // Mostrar diálogo directamente
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showConfirmationDialogDirect(serviceViewModel.currentService!);
              });
              return;
            }
          }
        } catch (e) {
          print("Error al obtener el chat: $e");
        }
      } else if (currentUserId == serviceViewModel.currentService!.clientId) {
        // Si el clientId no está vacío, verificar normalmente
        print("¡Se detectó un servicio completado que necesita confirmación!");
        _checkedService = true;

        // Mostrar diálogo directamente
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showConfirmationDialogDirect(serviceViewModel.currentService!);
        });
        return;
      }
    }

    // Si llegamos aquí, no se necesita mostrar el diálogo
    _checkedService = true;
    print("No se requiere confirmación o el usuario no es el cliente");
  }

  // Método para mostrar el diálogo directamente
  void _showConfirmationDialogDirect(dynamic service) {
    print("Mostrando diálogo de confirmación directamente");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text('Confirmación de Servicio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'El técnico ha marcado el siguiente servicio como completado:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // Información del servicio
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '¿Confirmas que el trabajo ha sido completado correctamente?',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  Text(
                    'Debes confirmar si el trabajo está terminado para continuar.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              actions: [
                // Botón de rechazar
                OutlinedButton.icon(
                  onPressed: () => _handleConfirmationResponse(false),
                  icon: Icon(Icons.close, color: Colors.red),
                  label: Text('NO, FALTA TRABAJO'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                ),

                // Botón de confirmar
                ElevatedButton.icon(
                  onPressed: () => _handleConfirmationResponse(true),
                  icon: Icon(Icons.check),
                  label: Text('SÍ, ESTÁ COMPLETADO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Manejar la respuesta del usuario
  void _handleConfirmationResponse(bool isAccepted) async {
    print("Respuesta del usuario: ${isAccepted ? 'ACEPTAR' : 'RECHAZAR'}");

    // Cerrar el diálogo
    Navigator.of(context).pop();

    // Obtener el ViewModel
    final serviceViewModel = Provider.of<ServiceStatusViewModel>(
      context,
      listen: false,
    );

    try {
      // Si el clientId está vacío en el service, obtenerlo del chat
      if (serviceViewModel.currentService != null &&
          serviceViewModel.currentService!.clientId.isEmpty) {
        try {
          // Obtener el documento del chat
          final chatDoc =
              await FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .get();

          if (chatDoc.exists) {
            final chatData = chatDoc.data() as Map<String, dynamic>?;
            final chatClientId = chatData?['clientId'] as String?;

            if (chatClientId != null && chatClientId.isNotEmpty) {
              // Actualizar el clientId en el servicio
              await FirebaseFirestore.instance
                  .collection('service_requests')
                  .doc(serviceViewModel.currentService!.id)
                  .update({'clientId': chatClientId});

              print("ClientId actualizado en el servicio: $chatClientId");
            }
          }
        } catch (e) {
          print("Error al actualizar clientId: $e");
        }
      }

      if (isAccepted) {
        print(
          "Usuario aceptó la confirmación, mostrando diálogo de calificación",
        );

        // Obtener información del técnico para la calificación
        final technicianId =
            serviceViewModel.currentService?.technicianId ?? '';
        final technicianDoc =
            await FirebaseFirestore.instance
                .collection(AppConstants.techniciansCollection)
                .doc(technicianId)
                .get();

        String technicianName = 'Técnico';
        if (technicianDoc.exists) {
          final techData = technicianDoc.data() as Map<String, dynamic>?;
          technicianName = techData?['name'] ?? 'Técnico';
        }

        // Mostrar diálogo de calificación
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => ServiceRatingDialog(
                  onSubmit: (rating, comment) {
                    print(
                      "Usuario calificó con $rating estrellas y comentario: $comment",
                    );

                    // Calificar el servicio
                    serviceViewModel.rateService(rating, comment).then((
                      result,
                    ) {
                      if (result.isSuccess) {
                        // Mostrar mensaje de éxito
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '¡Gracias por calificar a $technicianName!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // Mostrar mensaje de error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error al calificar: ${result.error}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    });
                  },
                ),
          );
        }
      } else {
        print("Usuario rechazó la confirmación, revirtiendo a 'en progreso'");

        // Revertir a "en progreso"
        final result = await serviceViewModel.rejectCompletion("");

        if (mounted) {
          // Mostrar mensaje informativo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.isSuccess
                    ? 'Has indicado que el trabajo aún no está completado'
                    : 'Error: ${result.error}',
              ),
              backgroundColor: result.isSuccess ? Colors.orange : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error al procesar respuesta: $e');

      if (mounted) {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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

          // Botón de verificación manual (temporal para debug)
          ElevatedButton.icon(
            onPressed: () {
              _checkedService = false; // Reiniciar bandera
              _checkServiceNeedsConfirmation(); // Verificar de nuevo
            },
            icon: Icon(Icons.refresh),
            label: Text('Verificar confirmación pendiente'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),

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
