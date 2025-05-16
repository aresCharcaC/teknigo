// lib/presentation/screens/chat/components/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/message_model.dart';
import 'proposal_message.dart';
import 'package:provider/provider.dart';
import 'location_message.dart';
import 'confirmation_message_bubble.dart';
import 'service_rating_dialog.dart';
import '../../../view_models/service_status_view_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Diferentes tipos de mensajes
    Widget messageContent;

    switch (message.type) {
      case MessageType.proposal:
        messageContent = ProposalMessage(
          message: message.content,
          price: message.metadata?['price'] ?? 0.0,
          availability: message.metadata?['availability'] ?? 'No especificado',
        );
        break;

      case MessageType.confirmation:
        // Verificar si el mensaje es de confirmación de completado
        if (message.metadata?['confirmationType'] == 'completion') {
          // Verificar si el usuario actual es el cliente
          final isClient =
              FirebaseAuth.instance.currentUser?.uid ==
              message.metadata?['clientId'];

          // Solo el cliente puede responder
          if (isClient) {
            final hasResponded = message.metadata?['responded'] == true;
            final isConfirmed = message.metadata?['isConfirmed'] == true;

            messageContent = ConfirmationMessageBubble(
              message: message.content,
              hasResponded: hasResponded,
              isConfirmed: isConfirmed,
              onConfirm: () {
                // 1. Marcar como confirmado
                Provider.of<ServiceStatusViewModel>(
                  context,
                  listen: false,
                ).confirmCompletionAndRate(message.id);

                // 2. Mostrar diálogo de calificación
                _showRatingDialog(context);
              },
              onReject: () {
                // Llamar a método para rechazar completado
                Provider.of<ServiceStatusViewModel>(
                  context,
                  listen: false,
                ).rejectCompletion(message.id);
              },
            );
          } else {
            // Para el técnico, solo mostrar el mensaje
            messageContent = Text(
              message.content,
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : Colors.black87,
              ),
            );
          }
        } else {
          // Otros tipos de confirmación
          messageContent = Text(message.content);
        }
        break;

      case MessageType.image:
        messageContent = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onTap: () => _showFullScreenImage(context, message.content),
            child: Image.network(
              message.content,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(height: 8),
                      Text(
                        'Error al cargar imagen',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        break;

      case MessageType.location:
        final lat = message.metadata?['latitude'] as double?;
        final lng = message.metadata?['longitude'] as double?;

        if (lat != null && lng != null) {
          messageContent = LocationMessage(
            location: LatLng(lat, lng),
            address: message.content,
          );
        } else {
          messageContent = Text('Ubicación no disponible');
        }
        break;

      case MessageType.text:
      default:
        messageContent = Text(
          message.content,
          style: TextStyle(
            fontSize: 16,
            color: isMe ? Colors.white : Colors.black87,
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar (solo en mensajes de otros usuarios)
          if (!isMe && showAvatar)
            _buildAvatar(message.senderId)
          else if (!isMe && !showAvatar)
            SizedBox(width: 36), // Espacio para alinear los mensajes
          // El mensaje en sí
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: EdgeInsets.only(
                left: isMe ? 50 : 8,
                right: isMe ? 8 : 50,
              ),
              decoration: BoxDecoration(
                color:
                    isMe
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenido del mensaje
                  messageContent,

                  // Hora del mensaje
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isMe
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (isMe)
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo de calificación
  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder:
          (context) => ServiceRatingDialog(
            onSubmit: (rating, comment) {
              // Guardar la calificación
              Provider.of<ServiceStatusViewModel>(
                context,
                listen: false,
              ).rateService(rating, comment);
            },
          ),
    );
  }

  // Construir el avatar del remitente
  Widget _buildAvatar(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, size: 16, color: Colors.grey.shade700),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String userName = userData['name'] ?? 'Usuario';
        final String? profileImage = userData['profileImage'];

        return CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue.shade100,
          backgroundImage:
              profileImage != null ? NetworkImage(profileImage) : null,
          child:
              profileImage == null
                  ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  )
                  : null,
        );
      },
    );
  }

  // Formatear la hora del mensaje
  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  // Mostrar imagen a pantalla completa
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
