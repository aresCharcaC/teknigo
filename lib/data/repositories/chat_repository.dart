import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../presentation/view_models/chat_view_model.dart';

/// Repositorio para manejar las operaciones relacionadas con chats
class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtener todos los chats del técnico actual
  Future<List<Chat>> getChats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // En una implementación real, obtendríamos los chats de Firestore
      // Por ahora, devolvemos datos de muestra

      return [
        Chat(
          id: '1',
          userId: 'client1',
          userName: 'María González',
          lastMessage:
              'Gracias por resolver el problema eléctrico. ¿Cuándo podrías venir a revisar los enchufes?',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
          unreadCount: 2,
        ),
        Chat(
          id: '2',
          userId: 'client2',
          userName: 'Pedro Ramírez',
          lastMessage: 'Entendido, estaré esperando a esa hora.',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Chat(
          id: '3',
          userId: 'client3',
          userName: 'Ana Suárez',
          lastMessage: 'El servicio fue excelente, muchas gracias.',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    } catch (e) {
      print('Error al obtener chats: $e');
      return [];
    }
  }

  /// Obtener mensajes de un chat específico
  Future<List<Message>> getMessages(String chatId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // En una implementación real, obtendríamos los mensajes de Firestore
      // Por ahora, devolvemos datos de muestra según el ID del chat

      switch (chatId) {
        case '1':
          return [
            Message(
              id: '1.1',
              senderId: 'client1',
              text:
                  'Hola, necesito ayuda con un problema eléctrico en mi casa.',
              timestamp: DateTime.now().subtract(
                const Duration(days: 1, hours: 2),
              ),
              isRead: true,
            ),
            Message(
              id: '1.2',
              senderId: user.uid,
              text: 'Claro, cuéntame más detalles del problema.',
              timestamp: DateTime.now().subtract(
                const Duration(days: 1, hours: 1),
              ),
              isRead: true,
            ),
            Message(
              id: '1.3',
              senderId: 'client1',
              text:
                  'Se trata de un cortocircuito en el dormitorio principal. Cuando enciendo la luz, salta el disyuntor.',
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              isRead: true,
            ),
            Message(
              id: '1.4',
              senderId: user.uid,
              text:
                  'Entendido. Puedo visitarte mañana para revisar el problema. ¿Te parece bien a las 10am?',
              timestamp: DateTime.now().subtract(const Duration(hours: 23)),
              isRead: true,
            ),
            Message(
              id: '1.5',
              senderId: 'client1',
              text: '¡Perfecto! Te espero mañana a las 10am.',
              timestamp: DateTime.now().subtract(const Duration(hours: 22)),
              isRead: true,
            ),
            Message(
              id: '1.6',
              senderId: user.uid,
              text:
                  'Ya resolví el problema del cortocircuito. Era un cable dañado en la instalación.',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              isRead: true,
            ),
            Message(
              id: '1.7',
              senderId: 'client1',
              text:
                  'Gracias por resolver el problema eléctrico. ¿Cuándo podrías venir a revisar los enchufes?',
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
              isRead: false,
            ),
          ];
        case '2':
          return [
            Message(
              id: '2.1',
              senderId: 'client2',
              text: 'Hola, ¿puedes ayudarme con mi computadora? No enciende.',
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              isRead: true,
            ),
            Message(
              id: '2.2',
              senderId: user.uid,
              text:
                  'Hola Pedro. Claro que puedo ayudarte. ¿Has verificado que esté conectada correctamente?',
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              isRead: true,
            ),
            Message(
              id: '2.3',
              senderId: 'client2',
              text: 'Sí, está bien conectada, pero sigue sin encender.',
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              isRead: true,
            ),
            Message(
              id: '2.4',
              senderId: user.uid,
              text: 'Puedo ir a revisarla mañana a las 3pm. ¿Te parece bien?',
              timestamp: DateTime.now().subtract(const Duration(hours: 4)),
              isRead: true,
            ),
            Message(
              id: '2.5',
              senderId: 'client2',
              text: 'Entendido, estaré esperando a esa hora.',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              isRead: true,
            ),
          ];
        case '3':
          return [
            Message(
              id: '3.1',
              senderId: 'client3',
              text:
                  'Necesito ayuda con mi aire acondicionado, no enfría correctamente.',
              timestamp: DateTime.now().subtract(const Duration(days: 4)),
              isRead: true,
            ),
            Message(
              id: '3.2',
              senderId: user.uid,
              text:
                  'Hola Ana. Puedo ir a revisarlo mañana por la tarde. ¿Te parece bien?',
              timestamp: DateTime.now().subtract(const Duration(days: 4)),
              isRead: true,
            ),
            Message(
              id: '3.3',
              senderId: 'client3',
              text: 'Sí, perfecto. Te espero mañana.',
              timestamp: DateTime.now().subtract(const Duration(days: 4)),
              isRead: true,
            ),
            Message(
              id: '3.4',
              senderId: user.uid,
              text:
                  'Ya revisé el equipo. Necesitaba recarga de gas refrigerante. Ahora debería funcionar correctamente.',
              timestamp: DateTime.now().subtract(const Duration(days: 3)),
              isRead: true,
            ),
            Message(
              id: '3.5',
              senderId: 'client3',
              text: 'El servicio fue excelente, muchas gracias.',
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              isRead: true,
            ),
          ];
        default:
          return [];
      }
    } catch (e) {
      print('Error al obtener mensajes: $e');
      return [];
    }
  }

  /// Marcar un chat como leído
  Future<bool> markChatAsRead(String chatId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // En una implementación real, actualizaríamos el estado de los mensajes en Firestore
      // Por ahora, simplemente devolvemos éxito

      return true;
    } catch (e) {
      print('Error al marcar chat como leído: $e');
      return false;
    }
  }

  /// Enviar un mensaje en un chat
  Future<bool> sendMessage(String chatId, String text) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // En una implementación real, guardaríamos el mensaje en Firestore
      // Por ahora, simplemente devolvemos éxito

      return true;
    } catch (e) {
      print('Error al enviar mensaje: $e');
      return false;
    }
  }

  /// Crear un nuevo chat con un cliente
  Future<String?> createChat(String clientId, String initialMessage) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // En una implementación real, crearíamos un nuevo chat en Firestore
      // Por ahora, devolvemos un ID simulado

      return 'new_chat_id';
    } catch (e) {
      print('Error al crear chat: $e');
      return null;
    }
  }
}
