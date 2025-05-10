// lib/presentation/screens/home/components/request_utils.dart
import 'package:flutter/material.dart';

/// Clase de utilidades para Solicitudes
/// Contiene métodos estáticos para formatear fechas y obtener colores según el estado
class RequestUtils {
  // Obtener color según el estado de la solicitud
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Obtener texto según el estado de la solicitud
  static String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'accepted':
        return 'ACEPTADO';
      case 'completed':
        return 'COMPLETADO';
      case 'cancelled':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }

  // Formatear fecha como tiempo relativo
  static String formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  // Formatear fecha completa
  static String formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
