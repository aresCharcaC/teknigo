import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Clase que define los temas de la aplicación.
/// Contiene tanto el tema claro como el oscuro.
class AppThemes {
  // Tema principal (claro)
  static ThemeData get lightTheme {
    return ThemeData(
      // Colores principales
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryLight,
      primaryColorDark: AppColors.primaryDark,

      // Esquema de color
      colorScheme: ColorScheme(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      ),

      // Configuración de AppBar
      appBarTheme: const AppBarTheme(
        color: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Configuración de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Configuración de botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Configuración de botones outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Configuración de campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textHint),
      ),

      // Configuración de tarjetas
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.surface,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),

      // Configuración de chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryExtraLight,
        disabledColor: AppColors.divider,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: AppColors.textOnSecondary),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Botón flotante
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Configuración de checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Configuración de Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight.withOpacity(0.5);
          }
          return Colors.grey.shade300;
        }),
      ),

      // Configuración de Radio
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),

      // Sliders
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryExtraLight,
        thumbColor: AppColors.primary,
        overlayColor: Color(0x292196F3),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: TextStyle(color: Colors.white),
      ),

      // Tipografía
      textTheme: const TextTheme(
        // Títulos grandes
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),

        // Títulos de sección
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),

        // Subtítulos
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),

        // Texto de cuerpo
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),

        // Texto pequeño
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),

      // Configuración de la navegación inferior
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),

      // Configuración de diálogos
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.surface,
        elevation: 8,
      ),

      // Configuración de divisores
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Configuración de SnackBar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // Configuración general
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.background,
      brightness: Brightness.light,
    );
  }

  // Tema oscuro (para futuras implementaciones)
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      // Aquí puedes personalizar el tema oscuro en el futuro
      // Por ahora, solo se proporciona un esqueleto básico
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: const Color(0xFF121212),

      // Esquema de color para modo oscuro
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryDark,
        surface: Color(0xFF1E1E1E),
        background: Color.fromARGB(255, 6, 6, 6),
        error: Color(0xFFCF6679),
      ),

      // Configuración de AppBar para modo oscuro
      appBarTheme: const AppBarTheme(
        color: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
