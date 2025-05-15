// lib/data/repositories/chat_repository.dart (ACTUALIZADO)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/chat_model.dart';
import '../../core/models/message_model.dart';
import '../../core/constants/app_constants.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear un nuevo chat a partir de una propuesta
  Future<String?> createChatWithProposal({
    required String requestId,
    required String clientId,
    required String message,
    required double price,
    required String availability,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Obtener el documento del servicio
      final serviceDoc =
          await _firestore.collection('service_requests').doc(requestId).get();

      if (!serviceDoc.exists) {
        print('Servicio no encontrado: $requestId');
        return null;
      }

      // Obtener datos del servicio
      final serviceData = serviceDoc.data() as Map<String, dynamic>;

      // Actualizar el servicio con el técnico asignado y nuevo estado
      await _firestore.collection('service_requests').doc(requestId).update({
        'technicianId': user.uid,
        'status': 'offered',
        'price': price,
      });

      // Crear el chat
      final chatRef = _firestore.collection('chats').doc();

      final chat = ChatModel(
        id: chatRef.id,
        requestId: requestId,
        clientId: clientId,
        technicianId: user.uid,
        createdAt: DateTime.now(),
        lastMessage: 'Propuesta: S/ ${price.toStringAsFixed(2)}',
        lastMessageTime: DateTime.now(),
        isActive: true,
      );

      // Guardar el chat
      await chatRef.set(chat.toFirestore());

      // Crear el mensaje de propuesta
      final messageRef = _firestore.collection('messages').doc();

      final proposal = MessageModel(
        id: messageRef.id,
        chatId: chatRef.id,
        senderId: user.uid,
        type: MessageType.proposal,
        content: message,
        metadata: {'price': price, 'availability': availability},
        timestamp: DateTime.now(),
      );

      // Guardar el mensaje
      await messageRef.set(proposal.toFirestore());

      return chatRef.id;
    } catch (e) {
      print('Error creating chat with proposal: $e');
      return null;
    }
  }

  // Obtener todos los chats del usuario - SIMPLIFICADO
  Stream<List<ChatModel>> getUserChatsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    print('ChatRepository: Getting client chats for user: ${user.uid}');

    return _firestore
        .collection('chats')
        .where('clientId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          try {
            final List<ChatModel> chats = [];
            for (var doc in snapshot.docs) {
              try {
                final chat = ChatModel.fromFirestore(doc);
                chats.add(chat);
              } catch (e) {
                print('ChatRepository: Error converting chat document: $e');
              }
            }
            print('ChatRepository: Returning ${chats.length} client chats');
            return chats;
          } catch (e) {
            print('ChatRepository: Error processing client chats: $e');
            return <ChatModel>[];
          }
        });
  }

  // También vamos a crear un método adicional para obtener chats donde el usuario es técnico
  Stream<List<ChatModel>> getTechnicianChatsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    print('ChatRepository: Getting technician chats for user: ${user.uid}');

    return _firestore
        .collection('chats')
        .where('technicianId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          try {
            final List<ChatModel> chats = [];
            for (var doc in snapshot.docs) {
              try {
                final chat = ChatModel.fromFirestore(doc);
                chats.add(chat);
              } catch (e) {
                print('ChatRepository: Error converting chat document: $e');
              }
            }
            print('ChatRepository: Returning ${chats.length} technician chats');
            return chats;
          } catch (e) {
            print('ChatRepository: Error processing technician chats: $e');
            return <ChatModel>[];
          }
        });
  }

  // Obtener mensajes de un chat
  Stream<List<MessageModel>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => MessageModel.fromFirestore(doc))
                .toList();
          } catch (e) {
            print('Error processing messages: $e');
            return <MessageModel>[];
          }
        });
  }

  // Enviar mensaje de confirmación de completado
  Future<bool> sendCompletionConfirmationMessage({
    required String chatId,
    required String clientId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Crear referencia para el nuevo mensaje
      final messageRef = _firestore.collection('messages').doc();

      // Crear el mensaje
      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: user.uid,
        type: MessageType.confirmation,
        content:
            "El técnico ha marcado el trabajo como completado. ¿Confirmas que el trabajo está terminado?",
        metadata: {
          'confirmationType': 'completion',
          'clientId': clientId,
          'responded': false,
        },
        timestamp: DateTime.now(),
      );

      // Guardar el mensaje
      await messageRef.set(message.toFirestore());

      // Actualizar el último mensaje del chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': "✅ Confirmación de trabajo completado",
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error al enviar mensaje de confirmación: $e');
      return false;
    }
  }

  // Método para actualizar un mensaje de confirmación como respondido
  Future<bool> updateConfirmationMessageAsResponded(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'metadata.responded': true,
      });
      return true;
    } catch (e) {
      print('Error al actualizar mensaje de confirmación: $e');
      return false;
    }
  }

  // Enviar un mensaje de texto
  Future<bool> sendTextMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Crear referencia para el nuevo mensaje
      final messageRef = _firestore.collection('messages').doc();

      // Crear el mensaje
      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: user.uid,
        type: MessageType.text,
        content: content,
        timestamp: DateTime.now(),
      );

      // Guardar el mensaje
      await messageRef.set(message.toFirestore());

      // Actualizar el último mensaje del chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Resto del código se mantiene igual...

  // Enviar mensaje de imagen
  Future<bool> sendImageMessage({
    required String chatId,
    required String imageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Crear referencia para el nuevo mensaje
      final messageRef = _firestore.collection('messages').doc();

      // Crear el mensaje
      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: user.uid,
        type: MessageType.image,
        content: imageUrl,
        timestamp: DateTime.now(),
      );

      // Guardar el mensaje
      await messageRef.set(message.toFirestore());

      // Actualizar el último mensaje del chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': 'Imagen',
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error sending image message: $e');
      return false;
    }
  }

  // Enviar mensaje de ubicación
  Future<bool> sendLocationMessage({
    required String chatId,
    required double latitude,
    required double longitude,
    String address = '',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Crear referencia para el nuevo mensaje
      final messageRef = _firestore.collection('messages').doc();

      // Crear el mensaje
      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: user.uid,
        type: MessageType.location,
        content: address,
        metadata: {'latitude': latitude, 'longitude': longitude},
        timestamp: DateTime.now(),
      );

      // Guardar el mensaje
      await messageRef.set(message.toFirestore());

      // Actualizar el último mensaje del chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': 'Ubicación',
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error sending location message: $e');
      return false;
    }
  }

  // Marcar mensajes como leídos
  Future<bool> markMessagesAsRead(String chatId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Obtener mensajes no leídos que no fueron enviados por el usuario actual
      final snapshot =
          await _firestore
              .collection('messages')
              .where('chatId', isEqualTo: chatId)
              .where('senderId', isNotEqualTo: user.uid)
              .where('isRead', isEqualTo: false)
              .get();

      // Si no hay mensajes no leídos
      if (snapshot.docs.isEmpty) return true;

      // Usar batch para eficiencia
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  // Obtener mensajes sin depender del índice compuesto
  Future<List<MessageModel>> getChatMessagesAlternative(String chatId) async {
    try {
      final snapshot =
          await _firestore
              .collection('messages')
              .where('chatId', isEqualTo: chatId)
              .get();

      List<MessageModel> messages =
          snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();

      // Ordenamos los mensajes por timestamp manualmente
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return messages;
    } catch (e) {
      print('Error obteniendo mensajes (alternativa): $e');
      return [];
    }
  }

  // Eliminar un chat (marcar como inactivo)
  Future<bool> deleteChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isActive': false,
      });
      return true;
    } catch (e) {
      print('Error deleting chat: $e');
      return false;
    }
  }
}
