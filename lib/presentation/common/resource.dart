/// Clase genérica para manejar el resultado de operaciones asíncronas
///
/// Proporciona un envoltorio para datos, estado de carga y errores
/// Ejemplo de uso:
/// ```
/// Resource<User> userResource = await getUserResource();
///
/// if (userResource.isLoading) {
///   // Mostrar indicador de carga
/// } else if (userResource.isError) {
///   // Mostrar mensaje de error: userResource.error
/// } else {
///   // Acceder a los datos: userResource.data
/// }
/// ```
class Resource<T> {
  final T? data;
  final String? error;
  final Status status;

  Resource._({this.data, this.error, required this.status});

  /// Crea un recurso en estado de éxito con datos
  factory Resource.success(T data) {
    return Resource._(data: data, status: Status.success);
  }

  /// Crea un recurso en estado de error con mensaje
  factory Resource.error(String message, [T? data]) {
    return Resource._(error: message, data: data, status: Status.error);
  }

  /// Crea un recurso en estado de carga
  factory Resource.loading([T? data]) {
    return Resource._(data: data, status: Status.loading);
  }

  /// Crea un recurso en estado inicial (sin datos)
  factory Resource.initial() {
    return Resource._(status: Status.initial);
  }

  /// Verifica si el recurso tiene un error
  bool get isError => status == Status.error;

  /// Verifica si el recurso está cargando
  bool get isLoading => status == Status.loading;

  /// Verifica si el recurso tiene datos
  bool get isSuccess => status == Status.success;

  /// Verifica si el recurso está en estado inicial
  bool get isInitial => status == Status.initial;

  /// Mapea el valor si el recurso tiene datos, o devuelve un valor por defecto
  R map<R>(R Function(T data) onData, {required R Function() orElse}) {
    if (isSuccess && data != null) {
      return onData(data!);
    }
    return orElse();
  }

  /// Maneja todos los estados posibles del recurso
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) error,
    required R Function() loading,
    required R Function() initial,
  }) {
    switch (status) {
      case Status.success:
        return success(data as T);
      case Status.error:
        return error(error.toString());
      case Status.loading:
        return loading();
      case Status.initial:
        return initial();
    }
  }
}

/// Estados posibles para un recurso
enum Status { initial, loading, success, error }
