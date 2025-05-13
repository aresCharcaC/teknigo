// lib/presentation/screens/chat/components/chat_app_bar.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;

  const ChatAppBar({Key? key, required this.userId}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ],
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .get(),
      builder: (context, snapshot) {
        // Mientras carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppBar(
            title: const Text('Cargando...'),
            leading: const BackButton(),
          );
        }

        // Si hay error
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return AppBar(
            title: const Text('Chat'),
            leading: const BackButton(),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptions(context),
              ),
            ],
          );
        }

        // Mostrar datos del usuario
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['name'] ?? 'Usuario';
        final profileImage = userData['profileImage'];

        return AppBar(
          titleSpacing: 0,
          leading: const BackButton(),
          title: Row(
            children: [
              CircleAvatar(
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
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(userName, overflow: TextOverflow.ellipsis)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOptions(context, userName),
            ),
          ],
        );
      },
    );
  }

  void _showOptions(BuildContext context, [String? userName]) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (userName != null)
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('Ver perfil de $userName'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navegar al perfil del usuario
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Eliminar chat'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteChat(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Cerrar'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _confirmDeleteChat(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar chat'),
            content: const Text(
              '¿Estás seguro que deseas eliminar este chat? Esta acción eliminará la conversación para ambos usuarios.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Eliminar chat y volver a la pantalla anterior
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('ELIMINAR'),
              ),
            ],
          ),
    );
  }
}
