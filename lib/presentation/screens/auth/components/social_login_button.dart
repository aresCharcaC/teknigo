import 'package:flutter/material.dart';

/// Tipos de inicio de sesión social soportados
enum SocialLoginType { google, apple }

/// Widget personalizado para botones de inicio de sesión social
///
/// Proporciona un diseño consistente para los botones de Google y Apple
class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    Key? key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configurar colores y textos según el tipo de botón
    late final Color backgroundColor;
    late final Color textColor;
    late final String text;
    late final IconData icon;

    switch (type) {
      case SocialLoginType.google:
        backgroundColor = Colors.white;
        textColor = Colors.black87;
        text = 'Continuar con Google';
        icon = Icons.g_mobiledata;
        break;
      case SocialLoginType.apple:
        backgroundColor = Colors.black;
        textColor = Colors.white;
        text = 'Continuar con Apple';
        icon = Icons.apple;
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side:
                type == SocialLoginType.google
                    ? const BorderSide(color: Colors.grey, width: 1)
                    : BorderSide.none,
          ),
          elevation: 0,
        ),
        icon:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
                : Icon(icon, color: textColor),
        label: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
