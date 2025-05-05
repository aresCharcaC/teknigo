import 'package:flutter/material.dart';

class WorkingHours {
  final String day;
  final String timeRange;
  final bool isAvailable;

  WorkingHours({
    required this.day,
    this.timeRange = '',
    this.isAvailable = true,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {'day': day, 'timeRange': timeRange, 'isAvailable': isAvailable};
  }

  // Crear desde Map
  factory WorkingHours.fromMap(Map<String, dynamic> map) {
    return WorkingHours(
      day: map['day'],
      timeRange: map['timeRange'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
