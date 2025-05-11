// lib/presentation/screens/technician/components/personal_info_section.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../auth/components/custom_text_field.dart';
import 'profile_section.dart';

class PersonalInfoSection extends StatelessWidget {
  final bool isIndividual;
  final Map<String, dynamic> userData;
  final bool isEditing;
  final File? profileImageFile;
  final Function() onPickProfileImage;
  final TextEditingController descriptionController;
  final TextEditingController experienceController;
  final TextEditingController businessNameController;
  final TextEditingController businessDescriptionController;
  final File? businessImageFile;
  final Function() onPickBusinessImage;

  const PersonalInfoSection({
    Key? key,
    required this.isIndividual,
    required this.userData,
    required this.isEditing,
    required this.descriptionController,
    required this.experienceController,
    required this.businessNameController,
    required this.businessDescriptionController,
    this.profileImageFile,
    required this.onPickProfileImage,
    this.businessImageFile,
    required this.onPickBusinessImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: isIndividual ? 'Información personal' : 'Información de empresa',
      icon: isIndividual ? Icons.person_outline : Icons.business,
      initiallyExpanded: true,
      child:
          isIndividual
              ? _buildPersonalInfo(context)
              : _buildBusinessInfo(context),
    );
  }

  Widget _buildPersonalInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Descripción personal
        isEditing
            ? CustomTextField(
              controller: descriptionController,
              label: 'Descripción profesional',
              prefixIcon: Icons.description,
              maxLines: 3,
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Descripción:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : 'Sin descripción',
                  style: TextStyle(
                    color:
                        descriptionController.text.isEmpty
                            ? Colors.grey
                            : Colors.black,
                  ),
                ),
              ],
            ),

        const SizedBox(height: 16),

        // Experiencia
        isEditing
            ? CustomTextField(
              controller: experienceController,
              label: 'Experiencia',
              prefixIcon: Icons.work,
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Experiencia:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  experienceController.text.isNotEmpty
                      ? experienceController.text
                      : 'Sin información de experiencia',
                  style: TextStyle(
                    color:
                        experienceController.text.isEmpty
                            ? Colors.grey
                            : Colors.black,
                  ),
                ),
              ],
            ),

        const SizedBox(height: 16),

        // Imagen profesional
        const Text(
          'Imagen profesional:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        Center(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: _getBusinessImageDecoration(),
                ),
                child: _getBusinessImagePlaceholder('Imagen profesional'),
              ),
              if (isEditing)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: InkWell(
                    onTap: onPickBusinessImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre de empresa
        isEditing
            ? CustomTextField(
              controller: businessNameController,
              label: 'Nombre de la empresa',
              prefixIcon: Icons.business,
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nombre de la empresa:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  businessNameController.text.isNotEmpty
                      ? businessNameController.text
                      : 'Sin nombre de empresa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        businessNameController.text.isEmpty
                            ? Colors.grey
                            : Colors.black,
                  ),
                ),
              ],
            ),

        const SizedBox(height: 16),

        // Descripción de la empresa
        isEditing
            ? CustomTextField(
              controller: businessDescriptionController,
              label: 'Descripción de la empresa',
              prefixIcon: Icons.description,
              maxLines: 3,
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Descripción de la empresa:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  businessDescriptionController.text.isNotEmpty
                      ? businessDescriptionController.text
                      : 'Sin descripción de empresa',
                  style: TextStyle(
                    color:
                        businessDescriptionController.text.isEmpty
                            ? Colors.grey
                            : Colors.black,
                  ),
                ),
              ],
            ),

        const SizedBox(height: 16),

        // Logo/Imagen de la empresa
        const Text(
          'Logo/Imagen de empresa:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        Center(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: _getBusinessImageDecoration(),
                ),
                child: _getBusinessImagePlaceholder('Logo/Imagen de empresa'),
              ),
              if (isEditing)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: InkWell(
                    onTap: onPickBusinessImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Obtener la imagen de decoración para negocio
  DecorationImage? _getBusinessImageDecoration() {
    if (businessImageFile != null) {
      return DecorationImage(
        image: FileImage(businessImageFile!),
        fit: BoxFit.cover,
      );
    }

    if (userData['businessImage'] != null) {
      return DecorationImage(
        image: NetworkImage(userData['businessImage']),
        fit: BoxFit.cover,
      );
    }

    return null;
  }

  // Obtener placeholder para la imagen de negocio
  Widget? _getBusinessImagePlaceholder(String label) {
    if (businessImageFile == null && userData['businessImage'] == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isIndividual ? Icons.person_outline : Icons.business,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return null;
  }
}
