import '../constants/app_constants.dart';

/// Clase que contiene métodos para validar entrada del usuario
///
/// Proporciona validación para email, contraseña, nombre, teléfono, etc.
class Validators {
  /// Valida un correo electrónico
  ///
  /// Retorna un mensaje de error si es inválido o null si es válido
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emailRequiredError;
    }

    // Expresión regular para validar email
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return AppConstants.invalidEmailError;
    }

    return null; // Sin errores
  }

  /// Valida una contraseña
  ///
  /// Retorna un mensaje de error si es inválida o null si es válida
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequiredError;
    }

    if (value.length < AppConstants.minPasswordLength) {
      return AppConstants.passwordLengthError;
    }

    return null; // Sin errores
  }

  /// Valida un nombre
  ///
  /// Retorna un mensaje de error si es inválido o null si es válido
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.nameRequiredError;
    }

    if (value.length < AppConstants.minNameLength) {
      return AppConstants.nameLengthError;
    }

    return null; // Sin errores
  }

  /// Valida un número de teléfono (opcional)
  ///
  /// Retorna un mensaje de error si es inválido o null si es válido
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Teléfono opcional
    }

    // Expresión regular para validar un número de teléfono (números y +)
    final phoneRegExp = RegExp(
      r'^\+?[0-9]{' +
          AppConstants.phoneMinLength.toString() +
          ',' +
          AppConstants.phoneMaxLength.toString() +
          r'}$',
    );

    if (!phoneRegExp.hasMatch(value)) {
      return AppConstants.invalidPhoneError;
    }

    return null; // Sin errores
  }

  /// Valida que la contraseña de confirmación coincida con la original
  ///
  /// Retorna un mensaje de error si no coinciden o null si son iguales
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return AppConstants.passwordsDoNotMatchError;
    }

    return null; // Sin errores
  }

  /// Valida una dirección
  ///
  /// Retorna un mensaje de error si está vacía o null si es válida
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'La dirección es obligatoria';
    }

    if (value.length < 5) {
      return 'Ingresa una dirección válida';
    }

    return null; // Sin errores
  }

  /// Valida un código postal
  ///
  /// Retorna un mensaje de error si es inválido o null si es válido
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Código postal opcional
    }

    // Expresión regular básica para códigos postales (entre 4-10 dígitos)
    final postalCodeRegExp = RegExp(r'^\d{4,10}$');

    if (!postalCodeRegExp.hasMatch(value)) {
      return 'Ingresa un código postal válido';
    }

    return null; // Sin errores
  }

  /// Valida un título de servicio
  ///
  /// Retorna un mensaje de error si es inválido o null si es válido
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'El título es obligatorio';
    }

    if (value.length < 5) {
      return 'El título debe tener al menos 5 caracteres';
    }

    if (value.length > AppConstants.maxTitleLength) {
      return 'El título no puede superar ${AppConstants.maxTitleLength} caracteres';
    }

    return null; // Sin errores
  }

  /// Valida una descripción
  ///
  /// Retorna un mensaje de error si es inválida o null si es válida
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'La descripción es obligatoria';
    }

    if (value.length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }

    if (value.length > AppConstants.maxDescriptionLength) {
      return 'La descripción no puede superar ${AppConstants.maxDescriptionLength} caracteres';
    }

    return null; // Sin errores
  }

  /// Valida un precio
  ///
  /// Retorna un mensaje de error si es inválido o null si es válido
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Precio opcional
    }

    // Eliminar cualquier símbolo de moneda y comas
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');

    try {
      final price = double.parse(cleanValue);

      if (price < 0) {
        return 'El precio no puede ser negativo';
      }
    } catch (e) {
      return 'Ingresa un precio válido';
    }

    return null; // Sin errores
  }

  /// Valida una URL
  ///
  /// Retorna un mensaje de error si es inválida o null si es válida
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL opcional
    }

    // Expresión regular para validar URL
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegExp.hasMatch(value)) {
      return 'Ingresa una URL válida';
    }

    return null; // Sin errores
  }

  /// Valida una fecha
  ///
  /// Retorna un mensaje de error si es inválida o null si es válida
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'La fecha es obligatoria';
    }

    final now = DateTime.now();

    if (value.isBefore(now)) {
      return 'La fecha no puede ser en el pasado';
    }

    return null; // Sin errores
  }
}
