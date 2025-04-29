class Validators {
  // Validador de correo electrónico
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }

    // Expresión regular para validar email
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null; // Sin errores
  }

  // Validador de contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null; // Sin errores
  }

  // Validador de nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es obligatorio';
    }

    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    return null; // Sin errores
  }

  // Validador de teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Teléfono opcional
    }

    // Expresión regular para validar un número de teléfono (números y +)
    final phoneRegExp = RegExp(r'^\+?[0-9]{8,15}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Ingresa un número de teléfono válido';
    }

    return null; // Sin errores
  }

  // Validador para confirmación de contraseña
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null; // Sin errores
  }
}
