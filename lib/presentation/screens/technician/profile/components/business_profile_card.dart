// lib/presentation/screens/technician/components/business_profile_card.dart
import 'dart:io';
import 'package:flutter/material.dart';

class BusinessProfileCard extends StatelessWidget {
  final bool isEditing;
  final String businessName;
  final String businessDescription;
  final dynamic businessImage; // File o NetworkImageWithUrl o null
  final String businessAddress;
  final String businessPhone;
  final String businessWebsite;
  final String businessEmail;
  final String businessHours;
  final bool provideHomeService;
  final bool provideOfficeService;
  final VoidCallback onPickImage;
  final Function(String) onBusinessNameChanged;
  final Function(String) onBusinessDescriptionChanged;
  final Function(String) onBusinessAddressChanged;
  final Function(String) onBusinessPhoneChanged;
  final Function(String) onBusinessWebsiteChanged;
  final Function(String) onBusinessEmailChanged;
  final Function(String) onBusinessHoursChanged;
  final Function(bool) onProvideHomeServiceChanged;
  final Function(bool) onProvideOfficeServiceChanged;

  const BusinessProfileCard({
    Key? key,
    required this.isEditing,
    required this.businessName,
    required this.businessDescription,
    this.businessImage,
    required this.businessAddress,
    required this.businessPhone,
    required this.businessWebsite,
    required this.businessEmail,
    required this.businessHours,
    required this.provideHomeService,
    required this.provideOfficeService,
    required this.onPickImage,
    required this.onBusinessNameChanged,
    required this.onBusinessDescriptionChanged,
    required this.onBusinessAddressChanged,
    required this.onBusinessPhoneChanged,
    required this.onBusinessWebsiteChanged,
    required this.onBusinessEmailChanged,
    required this.onBusinessHoursChanged,
    required this.onProvideHomeServiceChanged,
    required this.onProvideOfficeServiceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perfil de empresa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Imagen de negocio
            Center(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      image: _getDecorationImage(),
                    ),
                    child: _getImagePlaceholder(),
                  ),
                  if (isEditing)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: InkWell(
                        onTap: onPickImage,
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

            const SizedBox(height: 16),

            // Nombre del negocio
            isEditing
                ? TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre del negocio',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: businessName),
                  onChanged: onBusinessNameChanged,
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nombre del negocio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessName.isEmpty ? 'No especificado' : businessName,
                    ),
                  ],
                ),

            const SizedBox(height: 16),

            // Descripción del negocio
            isEditing
                ? TextField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción del negocio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(text: businessDescription),
                  onChanged: onBusinessDescriptionChanged,
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descripción del negocio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessDescription.isEmpty
                          ? 'No especificada'
                          : businessDescription,
                    ),
                  ],
                ),

            const SizedBox(height: 16),

            // Dirección adicional del negocio
            isEditing
                ? TextField(
                  decoration: const InputDecoration(
                    labelText: 'Dirección del negocio',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: businessAddress),
                  onChanged: onBusinessAddressChanged,
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dirección del negocio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessAddress.isEmpty
                          ? 'No especificada'
                          : businessAddress,
                    ),
                  ],
                ),

            const SizedBox(height: 16),

            // Horario de atención
            isEditing
                ? TextField(
                  decoration: const InputDecoration(
                    labelText: 'Horario de atención',
                    hintText: 'Ej: Lunes a Viernes 9:00 - 18:00',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: businessHours),
                  onChanged: onBusinessHoursChanged,
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Horario de atención',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessHours.isEmpty ? 'No especificado' : businessHours,
                    ),
                  ],
                ),

            const SizedBox(height: 16),

            // Teléfono del negocio
            isEditing
                ? TextField(
                  decoration: const InputDecoration(
                    labelText: 'Teléfono del negocio',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: businessPhone),
                  keyboardType: TextInputType.phone,
                  onChanged: onBusinessPhoneChanged,
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teléfono del negocio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessPhone.isEmpty ? 'No especificado' : businessPhone,
                    ),
                  ],
                ),

            const SizedBox(height: 16),

            // Email del negocio
            isEditing
                ? TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email del negocio',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: businessEmail),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: onBusinessEmailChanged,
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email del negocio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessEmail.isEmpty ? 'No especificado' : businessEmail,
                    ),
                  ],
                ),

            const SizedBox(height: 16),

            // Sitio web del negocio
            isEditing
                ? TextField(
                  decoration: const InputDecoration(
                    labelText: 'Sitio web o redes sociales',
                    hintText: 'www.ejemplo.com o @nombre_instagram',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: businessWebsite),
                  onChanged: onBusinessWebsiteChanged,
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sitio web o redes sociales',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessWebsite.isEmpty
                          ? 'No especificado'
                          : businessWebsite,
                    ),
                  ],
                ),

            const SizedBox(height: 16),

            // Tipo de servicio
            const Text(
              'Tipo de servicio',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),

            // Servicio a domicilio
            SwitchListTile(
              title: const Text('Servicio a domicilio'),
              subtitle: const Text('Atención en el domicilio del cliente'),
              value: provideHomeService,
              onChanged: isEditing ? onProvideHomeServiceChanged : null,
              dense: true,
              activeColor: Colors.green,
            ),

            // Servicio en local
            SwitchListTile(
              title: const Text('Servicio en local'),
              subtitle: const Text('Atención en la dirección del negocio'),
              value: provideOfficeService,
              onChanged: isEditing ? onProvideOfficeServiceChanged : null,
              dense: true,
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Obtener la imagen de decoración
  DecorationImage? _getDecorationImage() {
    if (businessImage == null) {
      return null;
    }

    if (businessImage is File) {
      return DecorationImage(
        image: FileImage(businessImage as File),
        fit: BoxFit.cover,
      );
    }

    if (businessImage is NetworkImageWithUrl) {
      return DecorationImage(
        image: NetworkImage((businessImage as NetworkImageWithUrl).url),
        fit: BoxFit.cover,
      );
    }

    return null;
  }

  // Obtener placeholder para la imagen
  Widget? _getImagePlaceholder() {
    if (businessImage == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Imagen del negocio', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return null;
  }
}

// Clase auxiliar para manejar imágenes de red
class NetworkImageWithUrl {
  final String url;
  NetworkImageWithUrl(this.url);
}
