import 'package:flutter/material.dart';

/// Modelo de datos para un técnico
class TechnicianItem {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount; // Agregamos conteo de reseñas
  final bool available;
  final String? profileImage;
  final bool isBusinessAccount;

  TechnicianItem({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    this.reviewCount = 0, // Valor por defecto
    this.available = true,
    this.profileImage,
    this.isBusinessAccount = false,
  });
}

/// Widget que muestra un técnico en formato de tarjeta
class TechnicianCard extends StatelessWidget {
  final TechnicianItem technician;
  final VoidCallback? onTap;
  final VoidCallback? onContact;

  const TechnicianCard({
    Key? key,
    required this.technician,
    this.onTap,
    this.onContact,
  }) : super(key: key);

  String _getCategoryNameFromId(String specialty) {
    // Si la especialidad es un número (ID), lo convertimos a nombre
    if (RegExp(r'^\d+$').hasMatch(specialty)) {
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
      return categoryNames[specialty] ?? 'Especialista';
    }

    // Si no es un número o no está en el mapa, devolvemos tal cual
    return specialty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap:
              onTap ??
              () {
                // Por defecto, mostrar un SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ver perfil de ${technician.name}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior con foto y nombre
                Row(
                  children: [
                    // Avatar del técnico
                    Stack(
                      children: [
                        // Foto de perfil o avatar por defecto
                        technician.profileImage != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                technician.profileImage!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.blue,
                                            size: 18,
                                          ),
                                        ),
                              ),
                            )
                            : CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),

                        // Indicador de disponibilidad
                        if (technician.available)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Información del técnico
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre con protección contra desbordamiento
                          Text(
                            technician.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Especialidad con protección contra desbordamiento
                          Text(
                            technician.specialty,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Espacio reducido
                const SizedBox(height: 10),

                // Indicador de disponibilidad
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Disponible ahora',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                // Fila inferior con valoración y distancia
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Valoración
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          technician.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
