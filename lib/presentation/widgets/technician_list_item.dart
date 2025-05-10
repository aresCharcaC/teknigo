// lib/presentation/widgets/technician_list_item.dart
import 'package:flutter/material.dart';
import 'package:teknigo/core/models/technician_search_model.dart';

class TechnicianListItem extends StatelessWidget {
  final TechnicianSearchModel technician;
  final VoidCallback? onTap;
  final VoidCallback? onContact;

  const TechnicianListItem({
    Key? key,
    required this.technician,
    this.onTap,
    this.onContact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Auxiliar para convertir ID de categoría a nombre
    String getCategoryName(String categoryId) {
      Map<String, String> categoryNames = {
        '1': 'Electricista',
        '2': 'Técnico en Iluminación',
        '3': 'Plomero',
        '4': 'Técnico en Calefacción',
        '5': 'Técnico PC',
        '6': 'Reparador de Móviles',
        '7': 'Técnico en Redes',
        '8': 'Refrigeración',
        '9': 'Técnico en Ventilación',
        '10': 'Cerrajero',
        '11': 'Técnico en Alarmas',
        '12': 'Carpintero',
        '13': 'Ebanista',
        '14': 'Albañil',
        '15': 'Yesero',
        '16': 'Pintor',
        '17': 'Jardinero',
        '18': 'Otros',
      };
      return categoryNames[categoryId] ?? 'Especialista';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar del técnico
              Stack(
                children: [
                  // Avatar o imagen de perfil
                  technician.profileImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          technician.profileImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey.shade200,
                                child: Icon(
                                  technician.isBusinessAccount
                                      ? Icons.business
                                      : Icons.person,
                                  size: 36,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      )
                      : CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(
                          technician.isBusinessAccount
                              ? Icons.business
                              : Icons.person,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ),

                  // Indicador de disponibilidad
                  if (technician.available)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Información del técnico
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y tipo
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            technician.isBusinessAccount &&
                                    technician.businessName != null
                                ? technician.businessName!
                                : technician.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (technician.isBusinessAccount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EMPRESA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Especialidades
                    Text(
                      technician.categories.isNotEmpty
                          ? getCategoryName(technician.categories.first)
                          : (technician.skills.isNotEmpty
                              ? technician.skills.first
                              : 'Especialista'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Valoración y reseñas
                    Row(
                      children: [
                        // Valoración
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              technician.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${technician.reviewCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Disponibilidad
                        if (technician.available)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Disponible',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón de contacto
              IconButton(
                icon: const Icon(Icons.message, color: Colors.blue),
                onPressed: onContact ?? onTap,
                tooltip: 'Contactar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
