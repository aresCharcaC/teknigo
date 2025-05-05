// lib/presentation/screens/technician/components/personal_info_section.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../widgets/custom_text_field.dart';
import '../../technician/components/profile_section.dart';

class PersonalInfoSection extends StatelessWidget {
  final bool isIndividual;
  final Map<String, dynamic> userData;
  final bool isEditing;
  final Function(File) onImageSelected;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessDescriptionController =
      TextEditingController();

  PersonalInfoSection({
    Key? key,
    required this.isIndividual,
    required this.userData,
    required this.isEditing,
    required this.onImageSelected,
  }) : super(key: key) {
    // Inicializar controladores con datos existentes
    _descriptionController.text = userData['description'] ?? '';
    _experienceController.text = userData['experience'] ?? '';
    _businessNameController.text = userData['businessName'] ?? '';
    _businessDescriptionController.text = userData['businessDescription'] ?? '';
  }

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
              controller: _descriptionController,
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
                  _descriptionController.text.isNotEmpty
                      ? _descriptionController.text
                      : 'Sin descripción',
                  style: TextStyle(
                    color:
                        _descriptionController.text.isEmpty
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
              controller: _experienceController,
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
                  _experienceController.text.isNotEmpty
                      ? _experienceController.text
                      : 'Sin información de experiencia',
                  style: TextStyle(
                    color:
                        _experienceController.text.isEmpty
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
              controller: _businessNameController,
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
                  _businessNameController.text.isNotEmpty
                      ? _businessNameController.text
                      : 'Sin nombre de empresa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        _businessNameController.text.isEmpty
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
              controller: _businessDescriptionController,
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
                  _businessDescriptionController.text.isNotEmpty
                      ? _businessDescriptionController.text
                      : 'Sin descripción de empresa',
                  style: TextStyle(
                    color:
                        _businessDescriptionController.text.isEmpty
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
  void _pickImage(BuildContext context) {
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
                  onTap: () {
                    Navigator.pop(context);
                    // Implementar toma de foto
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implementar selección de galería
                  },
                ),
              ],
            ),
          ),
    );
  }
}
