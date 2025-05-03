// lib/presentation/screens/technician/components/availability_card.dart
import 'package:flutter/material.dart';

class AvailabilityCard extends StatelessWidget {
  final bool isEditing;
  final bool isServicesActive;
  final bool isAvailable;
  final Function(bool) onChangeServicesActive;
  final Function(bool) onChangeAvailability;

  const AvailabilityCard({
    Key? key,
    required this.isEditing,
    required this.isServicesActive,
    required this.isAvailable,
    required this.onChangeServicesActive,
    required this.onChangeAvailability,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado de servicios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Activar/desactivar servicios (disponible en buscador)
            SwitchListTile(
              title: const Text(
                'Activar servicios',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Cuando está activado, aparecerás en el buscador para que los clientes te encuentren',
              ),
              value: isServicesActive,
              activeColor: Colors.green,
              onChanged: isEditing ? onChangeServicesActive : null,
            ),

            const Divider(),

            // Disponibilidad para trabajos
            SwitchListTile(
              title: const Text(
                'Disponible para trabajos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Indica si estás disponible para aceptar trabajos en este momento',
              ),
              value: isAvailable,
              activeColor: Colors.green,
              onChanged: isEditing ? onChangeAvailability : null,
            ),

            if (!isEditing) ...[
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isServicesActive
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isServicesActive
                        ? 'Servicios activados'
                        : 'Servicios desactivados',
                    style: TextStyle(
                      color:
                          isServicesActive
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
