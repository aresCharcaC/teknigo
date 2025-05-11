// lib/presentation/screens/technician/components/availability_section.dart
import 'package:flutter/material.dart';
import '../../../../../core/models/working_hours.dart';
import 'profile_section.dart';
import 'availability_card.dart';

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
      child: AvailabilityCard(
        isEditing: isEditing,
        isServicesActive: isServicesActive,
        isAvailable: isAvailable,
        workingHours: workingHours,
        onToggleServicesActive: onToggleServicesActive,
        onToggleAvailability: onToggleAvailability,
        onUpdateWorkingHours: onUpdateWorkingHours,
      ),
    );
  }
}
