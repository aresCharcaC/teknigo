// lib/presentation/screens/technician/components/personal_info_section.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../widgets/custom_text_field.dart';
import '../../technician/components/profile_section.dart';

class PersonalInfoSection extends StatelessWidget {
  final bool isIndividual;
  final Map<String, dynamic> userData;
  final bool isEditing;
  final TextEditingController descriptionController;
  final TextEditingController experienceController;
  final TextEditingController businessNameController;
  final TextEditingController businessDescriptionController;
  final Function(File) onImageSelected;

  const PersonalInfoSection({
    Key? key,
    required this.isIndividual,
    required this.userData,
    required this.isEditing,
    required this.descriptionController,
    required this.experienceController,
    required this.businessNameController,
    required this.businessDescriptionController,
    required this.onImageSelected,
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

        // Imagen de la empresa/negocio
        isEditing
            ? Center(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      image:
                          userData['businessImage'] != null
                              ? DecorationImage(
                                image: NetworkImage(userData['businessImage']),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        userData['businessImage'] == null
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.business,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Imagen del negocio',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                            : null,
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: InkWell(
                      onTap: () => _pickImage(context),
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
            )
            : userData['businessImage'] != null
            ? Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(userData['businessImage']),
                  fit: BoxFit.cover,
                ),
              ),
            )
            : const SizedBox.shrink(),
      ],
    );
  }

  // Método para seleccionar imagen
  void _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    // Implementar la funcionalidad de tomar foto aquí
                    // Por ejemplo:
                    // final image = await ImagePicker().pickImage(source: ImageSource.camera);
                    // if (image != null) {
                    //   onImageSelected(File(image.path));
                    // }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    // Implementar la funcionalidad de seleccionar desde galería aquí
                    // Por ejemplo:
                    // final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                    // if (image != null) {
                    //   onImageSelected(File(image.path));
                    // }
                  },
                ),
              ],
            ),
          ),
    );
  }
}
