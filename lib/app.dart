import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_themes.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/view_models/auth_view_model.dart';

/// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode:
          ThemeMode
              .light, // Cambiar a ThemeMode.system para detectar automáticamente
      home: const AuthWrapper(),
    );
  }
}

/// Widget que controla el flujo de autenticación
///
/// Muestra la pantalla de inicio de sesión o la pantalla principal
/// dependiendo del estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenemos el AuthViewModel del contexto
    final authViewModel = Provider.of<AuthViewModel>(context);

    return StreamBuilder<User?>(
      stream: authViewModel.authStateChanges,
      builder: (context, snapshot) {
        // Si hay un error en el stream
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error de autenticación',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Intentar reiniciar la aplicación
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MyApp()),
                      );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Mientras verifica el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Iniciando ${AppConstants.appName}...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Si el usuario está autenticado
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // Si el usuario no está autenticado
        return const LoginScreen();
      },
    );
  }
}
