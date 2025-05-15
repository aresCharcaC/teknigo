// lib/core/enums/service_enums.dart
enum ServiceStatus {
  pending, // Solicitud pendiente
  offered, // Oferta enviada al cliente
  accepted, // Oferta aceptada, servicio a punto de iniciarse
  inProgress, // Técnico realizando el trabajo
  completed, // Técnico marcó como completado (esperando confirmación)
  rated, // Servicio completado y calificado
  cancelled, // Servicio cancelado
  rejected, // Oferta rechazada
}

enum ServiceType {
  immediate, // Servicio inmediato
  scheduled, // Servicio programado
}

enum ServiceLocation {
  clientHome, // A domicilio
  techOffice, // En local del técnico
}

// Extensiones para facilitar la conversión entre strings y enums
extension ServiceStatusExtension on ServiceStatus {
  String get value => toString().split('.').last;

  static ServiceStatus fromString(String value) {
    return ServiceStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ServiceStatus.pending,
    );
  }
}

extension ServiceTypeExtension on ServiceType {
  String get value => toString().split('.').last;

  static ServiceType fromString(String value) {
    return ServiceType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ServiceType.immediate,
    );
  }
}

extension ServiceLocationExtension on ServiceLocation {
  String get value => toString().split('.').last;

  static ServiceLocation fromString(String value) {
    return ServiceLocation.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ServiceLocation.clientHome,
    );
  }
}
