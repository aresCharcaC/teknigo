import 'package:flutter/foundation.dart';

/// Estado base para los view models: inicial, cargando, cargado o error
enum ViewState { initial, loading, loaded, error }

/// Clase base para todos los view models
/// Proporciona gestión de estado y notificación de cambios
class BaseViewModel extends ChangeNotifier {
  // Estado actual del view model
  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  // Mensaje de error
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Saber si el view model está cargando datos
  bool get isLoading => _state == ViewState.loading;

  // Saber si el view model está en estado de error
  bool get hasError => _state == ViewState.error;

  // Saber si el view model ha cargado datos
  bool get isLoaded => _state == ViewState.loaded;

  /// Cambia el estado a cargando
  void setLoading() {
    _state = ViewState.loading;
    notifyListeners();
  }

  /// Cambia el estado a cargado
  void setLoaded() {
    _state = ViewState.loaded;
    notifyListeners();
  }

  /// Cambia el estado a error con un mensaje
  void setError(String message) {
    _errorMessage = message;
    _state = ViewState.error;
    notifyListeners();
  }

  /// Cambia el estado a inicial (resetea el view model)
  void setInitial() {
    _state = ViewState.initial;
    _errorMessage = '';
    notifyListeners();
  }

  /// Método para manejar excepciones y establecer el mensaje de error apropiado
  void handleException(dynamic exception) {
    String errorMessage = 'Ocurrió un error inesperado';

    // Personalizar el mensaje según el tipo de excepción
    if (exception is Exception) {
      errorMessage = exception.toString();
    }

    // Firebase exceptions, network exceptions, etc.
    // Aquí se pueden añadir más casos específicos

    setError(errorMessage);

    // Log del error para depuración
    if (kDebugMode) {
      print('ERROR EN VIEW MODEL: $errorMessage');
      print(exception);
    }
  }

  /// Método para ejecutar una operación asíncrona segura
  /// Automáticamente maneja el estado y los errores
  Future<T?> executeAsync<T>(Future<T> Function() asyncFunction) async {
    try {
      setLoading();
      final result = await asyncFunction();
      setLoaded();
      return result;
    } catch (e) {
      handleException(e);
      return null;
    }
  }

  /// Ejecutar una operación sincrónica segura
  T? executeSync<T>(T Function() syncFunction) {
    try {
      setLoading();
      final result = syncFunction();
      setLoaded();
      return result;
    } catch (e) {
      handleException(e);
      return null;
    }
  }
}
