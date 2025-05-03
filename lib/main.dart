import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'presentation/view_models/auth_view_model.dart';

void main() async {
  // Asegurar que los widgets Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con las opciones configuradas
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ejecutar la aplicación con el MultiProvider para gestión de estado
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // Aquí puedes añadir más providers según vayas desarrollando nuevas funcionalidades
      ],
      child: const MyApp(),
    ),
  );
}
