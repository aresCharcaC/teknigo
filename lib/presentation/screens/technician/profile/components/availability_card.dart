// lib/presentation/screens/technician/components/availability_card.dart
import 'package:flutter/material.dart';
import '../../../../../core/models/working_hours.dart';

class AvailabilityCard extends StatefulWidget {
  final bool isEditing;
  final bool isServicesActive;
  final bool isAvailable;
  final List<WorkingHours> workingHours;
  final Function(bool) onToggleServicesActive;
  final Function(bool) onToggleAvailability;
  final Function(List<WorkingHours>) onUpdateWorkingHours;

  const AvailabilityCard({
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
  _AvailabilityCardState createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> {
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
              'Disponibilidad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Activar servicios
            SwitchListTile(
              title: const Text(
                'Activar servicios',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Cuando está activado, aparecerás en el buscador para que los clientes te encuentren',
              ),
              value: widget.isServicesActive,
              activeColor: Theme.of(context).primaryColor,
              onChanged:
                  widget.isEditing ? widget.onToggleServicesActive : null,
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
              value: widget.isAvailable,
              activeColor: Theme.of(context).primaryColor,
              onChanged: widget.isEditing ? widget.onToggleAvailability : null,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            // Indicador de estado (solo cuando no está en edición)
            if (!widget.isEditing)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.isServicesActive
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.isServicesActive
                        ? 'Servicios activados'
                        : 'Servicios desactivados',
                    style: TextStyle(
                      color:
                          widget.isServicesActive
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
                if (widget.isEditing)
                  TextButton.icon(
                    onPressed: () => _showWorkingHoursDialog(context),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Lista de horarios
            widget.workingHours.isEmpty
                ? Text(
                  'No has configurado un horario de disponibilidad',
                  style: TextStyle(color: Colors.grey.shade600),
                )
                : Column(
                  children:
                      widget.workingHours.map((hours) {
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
                              widget.isEditing
                                  ? IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed:
                                        () => _editWorkingDay(
                                          context,
                                          hours,
                                          widget.workingHours.indexOf(hours),
                                        ),
                                  )
                                  : null,
                        );
                      }).toList(),
                ),
          ],
        ),
      ),
    );
  }

  void _showWorkingHoursDialog(BuildContext context) {
    if (widget.workingHours.isEmpty) {
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
      widget.onUpdateWorkingHours(defaultHours);
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
                    setState(() {
                      isAvailable = value;
                    });
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
                  final updatedHours = List<WorkingHours>.from(
                    widget.workingHours,
                  );
                  updatedHours[index] = updatedDay;
                  widget.onUpdateWorkingHours(updatedHours);

                  Navigator.pop(context);
                },
                child: const Text('GUARDAR'),
              ),
            ],
          ),
    );
  }
}
