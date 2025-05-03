import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'presentation/view_models/auth_view_model.dart';
import 'presentation/view_models/search_view_model.dart';
import 'presentation/view_models/profile_view_model.dart';
import 'presentation/view_models/technician_view_model.dart';
import 'presentation/view_models/service_request_view_model.dart';
import 'presentation/view_models/chat_view_model.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with configured options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app with MultiProvider for state management
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => TechnicianViewModel()),
        ChangeNotifierProvider(create: (_) => ServiceRequestViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        // Add more providers as you develop new features
      ],
      child: const MyApp(),
    ),
  );
}
