// lib/presentation/screens/technician/components/profile_header.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool isEditing;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final File? profileImageFile;
  final Function() onPickProfileImage;

  const ProfileHeader({
    Key? key,
    required this.userData,
    required this.isEditing,
    required this.nameController,
    required this.phoneController,
    this.profileImageFile,
    required this.onPickProfileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar con imagen
        _buildProfileAvatar(context),
        const SizedBox(width: 16),

        // Información del perfil
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isEditing
                  ? TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  )
                  : Text(
                    userData['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              const SizedBox(height: 8),
              Text(
                userData['email'] ?? '',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Valoración
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${userData['rating'] ?? 0}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${userData['reviewCount'] ?? 0} reseñas)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Trabajos completados
              Text(
                '${userData['completedJobs'] ?? 0} trabajos completados',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    const double radius = 50.0;

    // Si hay una imagen temporal seleccionada
    if (profileImageFile != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: FileImage(profileImageFile!),
          ),
          if (isEditing)
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: onPickProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      );
    }

    // Si hay una URL de imagen guardada
    if (userData['profileImage'] != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: CachedNetworkImage(
                imageUrl: userData['profileImage'],
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
                placeholder:
                    (context, url) => const CircularProgressIndicator(),
                errorWidget:
                    (context, url, error) =>
                        Icon(Icons.person, size: radius, color: Colors.grey),
              ),
            ),
          ),
          if (isEditing)
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: onPickProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      );
    }

    // Avatar por defecto si no hay imagen
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, size: radius, color: Colors.blue),
        ),
        if (isEditing)
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: onPickProfileImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
