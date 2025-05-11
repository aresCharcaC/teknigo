// lib/presentation/screens/technician/components/schedule_card.dart
import 'package:flutter/material.dart';

class ScheduleDay {
  final String day;
  bool isOpen;
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  ScheduleDay({
    required this.day,
    this.isOpen = false,
    this.openTime,
    this.closeTime,
  });

  // Convertir a mapa para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'isOpen': isOpen,
      'openTime':
          openTime != null ? '${openTime!.hour}:${openTime!.minute}' : null,
      'closeTime':
          closeTime != null ? '${closeTime!.hour}:${closeTime!.minute}' : null,
    };
  }

  // Crear desde mapa de Firestore
  factory ScheduleDay.fromMap(String day, Map<String, dynamic>? data) {
    if (data == null) {
      return ScheduleDay(day: day);
    }

    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }

    return ScheduleDay(
      day: day,
      isOpen: data['isOpen'] ?? false,
      openTime: parseTime(data['openTime']),
      closeTime: parseTime(data['closeTime']),
    );
  }
}

class ScheduleCard extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic> schedule;
  final Function(Map<String, dynamic>) onUpdateSchedule;

  const ScheduleCard({
    Key? key,
    required this.isEditing,
    required this.schedule,
    required this.onUpdateSchedule,
  }) : super(key: key);

  @override
  _ScheduleCardState createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  late List<ScheduleDay> _schedule;
  final List<String> _weekDays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    _initSchedule();
  }

  @override
  void didUpdateWidget(ScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedule != widget.schedule) {
      _initSchedule();
    }
  }

  // Inicializar el horario desde los datos del modelo
  void _initSchedule() {
    _schedule =
        _weekDays.map((day) {
          return ScheduleDay.fromMap(day, widget.schedule[day.toLowerCase()]);
        }).toList();
  }

  // Aplicar cambios al horario
  void _applyScheduleChanges() {
    final Map<String, dynamic> updatedSchedule = {};
    for (final day in _schedule) {
      updatedSchedule[day.day.toLowerCase()] = day.toMap();
    }
    widget.onUpdateSchedule(updatedSchedule);
  }

  // Seleccionar hora
  Future<TimeOfDay?> _selectTime(
    BuildContext context,
    TimeOfDay? initialTime,
  ) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay(hour: 9, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
  }

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
              'Horario de atención',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configura los días y horas en que ofreces tus servicios',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Lista de días de la semana
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _schedule.length,
              itemBuilder: (context, index) {
                final day = _schedule[index];
                return _buildDayItem(context, day);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Construir el ítem de un día
  Widget _buildDayItem(BuildContext context, ScheduleDay day) {
    final bool canEdit = widget.isEditing;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Nombre del día
          SizedBox(
            width: 100,
            child: Text(
              day.day,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Switch para activar/desactivar
          Switch(
            value: day.isOpen,
            onChanged:
                canEdit
                    ? (value) {
                      setState(() {
                        day.isOpen = value;
                        if (value && day.openTime == null) {
                          day.openTime = const TimeOfDay(hour: 9, minute: 0);
                        }
                        if (value && day.closeTime == null) {
                          day.closeTime = const TimeOfDay(hour: 18, minute: 0);
                        }
                      });
                      _applyScheduleChanges();
                    }
                    : null,
            activeColor: Theme.of(context).primaryColor,
          ),

          // Hora de apertura
          Expanded(
            child: InkWell(
              onTap:
                  canEdit && day.isOpen
                      ? () async {
                        final time = await _selectTime(context, day.openTime);
                        if (time != null) {
                          setState(() {
                            day.openTime = time;
                          });
                          _applyScheduleChanges();
                        }
                      }
                      : null,
              child: Text(
                day.isOpen && day.openTime != null
                    ? '${day.openTime!.hour.toString().padLeft(2, '0')}:${day.openTime!.minute.toString().padLeft(2, '0')}'
                    : 'Cerrado',
                style: TextStyle(
                  color: day.isOpen ? Colors.black : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Separador
          Text(
            day.isOpen ? '-' : '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          // Hora de cierre
          Expanded(
            child: InkWell(
              onTap:
                  canEdit && day.isOpen
                      ? () async {
                        final time = await _selectTime(context, day.closeTime);
                        if (time != null) {
                          setState(() {
                            day.closeTime = time;
                          });
                          _applyScheduleChanges();
                        }
                      }
                      : null,
              child: Text(
                day.isOpen && day.closeTime != null
                    ? '${day.closeTime!.hour.toString().padLeft(2, '0')}:${day.closeTime!.minute.toString().padLeft(2, '0')}'
                    : '',
                style: TextStyle(
                  color: day.isOpen ? Colors.black : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
