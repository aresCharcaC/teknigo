// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teknigo/presentation/view_models/chat_detail_view_model.dart';
import 'package:teknigo/presentation/view_models/chat_list_view_model.dart';
import 'package:teknigo/presentation/view_models/proposal_view_model.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'presentation/view_models/auth_view_model.dart';
import 'presentation/view_models/search_view_model.dart';
import 'presentation/view_models/profile_view_model.dart';
import 'presentation/view_models/category_view_model.dart';
import 'presentation/view_models/technician_view_model.dart';
import 'presentation/view_models/home_view_model.dart';
import 'presentation/view_models/confirmation_view_model.dart';
import 'presentation/view_models/service_request_view_model.dart';
import 'presentation/view_models/service_status_view_model.dart';
import 'presentation/view_models/chat_view_model.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  // Asegurar que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con las opciones configuradas
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar Firebase AppCheck
  await FirebaseAppCheck.instance.activate(
    // Para pruebas de depuración, usa esto:
    // webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // Para Android en depuración, usa el proveedor de depuración
    androidProvider: AndroidProvider.debug,
    // Para iOS, usa DeviceCheck o AppAttest según corresponda
    appleProvider: AppleProvider.deviceCheck,
  );

  // Ejecutar la aplicación con MultiProvider para gestión de estado
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => TechnicianViewModel()),
        ChangeNotifierProvider(create: (_) => ServiceRequestViewModel()),
        ChangeNotifierProvider(create: (_) => ChatDetailViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => ChatListViewModel()),
        ChangeNotifierProvider(create: (_) => ProposalViewModel()),
        ChangeNotifierProvider(create: (_) => ServiceStatusViewModel()),
        ChangeNotifierProvider(create: (_) => ConfirmationViewModel()),

        // Agregar más providers a medida que desarrolles nuevas funciones
      ],
      child: const MyApp(),
    ),
  );
}
