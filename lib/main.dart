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
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with configured options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase AppCheck
  await FirebaseAppCheck.instance.activate(
    // For debug testing, use this:
    //webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // For Android debug, use debug provider
    androidProvider: AndroidProvider.debug,
    // For iOS, use DeviceCheck or AppAttest as appropriate
    appleProvider: AppleProvider.deviceCheck,
  );

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
