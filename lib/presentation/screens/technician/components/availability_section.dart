import 'package:flutter/material.dart';
import '../../../../core/models/working_hours.dart';
import '../components/profile_section.dart';

class AvailabilitySection extends StatelessWidget {
  final bool isEditing;
  final bool isServicesActive;
  final bool isAvailable;
  final List<WorkingHours> workingHours;
  final Function(bool) onToggleServicesActive;
  final Function(bool) onToggleAvailability;
  final Function(List<WorkingHours>) onUpdateWorkingHours;

  const AvailabilitySection({
    Key? key,
    required this.isEditing,
    required this.isServicesActive,
    required this.isAvailable,
    required this.workingHours,
    required this.onToggleServicesActive,
    required this.onToggleAvailability,
    required this.onUpdateWorkingHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'Disponibilidad',
      icon: Icons.access_time,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activar servicios
          SwitchListTile(
            title: const Text(
              'Activar servicios',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Cuando está activado, aparecerás en el buscador para que los clientes te encuentren',
            ),
            value: isServicesActive,
            activeColor: Theme.of(context).primaryColor,
            onChanged: isEditing ? onToggleServicesActive : null,
            contentPadding: EdgeInsets.zero,
          ),

          const Divider(),

          // Disponible ahora
          SwitchListTile(
            title: const Text(
              'Disponible para trabajos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Indica si estás disponible para aceptar trabajos en este momento',
            ),
            value: isAvailable,
            activeColor: Theme.of(context).primaryColor,
            onChanged: isEditing ? onToggleAvailability : null,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 16),

          // Indicador de estado (solo cuando no está en edición)
          if (!isEditing)
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

          const SizedBox(height: 24),

          // Horario de disponibilidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Horario de disponibilidad:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (isEditing)
                TextButton.icon(
                  onPressed: () => _showWorkingHoursDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Lista de horarios
          workingHours.isEmpty
              ? Text(
                'No has configurado un horario de disponibilidad',
                style: TextStyle(color: Colors.grey.shade600),
              )
              : Column(
                children:
                    workingHours.map((hours) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(hours.day),
                        subtitle:
                            hours.isAvailable
                                ? Text(
                                  hours.timeRange.isNotEmpty
                                      ? hours.timeRange
                                      : 'Horario no especificado',
                                )
                                : const Text(
                                  'No disponible',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        trailing:
                            isEditing
                                ? IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed:
                                      () => _editWorkingDay(
                                        context,
                                        hours,
                                        workingHours.indexOf(hours),
                                      ),
                                )
                                : null,
                      );
                    }).toList(),
              ),
        ],
      ),
    );
  }

  void _showWorkingHoursDialog(BuildContext context) {
    if (workingHours.isEmpty) {
      // Crear horario por defecto y mostrar
      final defaultHours = [
        WorkingHours(
          day: 'Lunes',
          timeRange: '8:00 - 18:00',
          isAvailable: true,
        ),
        WorkingHours(
          day: 'Martes',
          timeRange: '8:00 - 18:00',
          isAvailable: true,
        ),
        WorkingHours(
          day: 'Miércoles',
          timeRange: '8:00 - 18:00',
          isAvailable: true,
        ),
        WorkingHours(
          day: 'Jueves',
          timeRange: '8:00 - 18:00',
          isAvailable: true,
        ),
        WorkingHours(
          day: 'Viernes',
          timeRange: '8:00 - 18:00',
          isAvailable: true,
        ),
        WorkingHours(
          day: 'Sábado',
          timeRange: '9:00 - 13:00',
          isAvailable: true,
        ),
        WorkingHours(day: 'Domingo', timeRange: '', isAvailable: false),
      ];
      onUpdateWorkingHours(defaultHours);
    }
  }

  void _editWorkingDay(BuildContext context, WorkingHours day, int index) {
    bool isAvailable = day.isAvailable;
    final TextEditingController timeRangeController = TextEditingController(
      text: day.timeRange,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Editar horario: ${day.day}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Disponible este día'),
                  value: isAvailable,
                  onChanged: (value) {
                    isAvailable = value;
                    (context as Element).markNeedsBuild();
                  },
                ),
                const SizedBox(height: 8),
                if (isAvailable)
                  TextField(
                    controller: timeRangeController,
                    decoration: const InputDecoration(
                      labelText: 'Horario (ej: 8:00 - 18:00)',
                      border: OutlineInputBorder(),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  final updatedDay = WorkingHours(
                    day: day.day,
                    timeRange: isAvailable ? timeRangeController.text : '',
                    isAvailable: isAvailable,
                  );

                  // Actualizar la lista completa con el día modificado
                  final updatedHours = List<WorkingHours>.from(workingHours);
                  updatedHours[index] = updatedDay;
                  onUpdateWorkingHours(updatedHours);

                  Navigator.pop(context);
                },
                child: const Text('GUARDAR'),
              ),
            ],
          ),
    );
  }
}
