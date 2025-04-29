// app.dart
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Test App',
      debugShowCheckedModeBanner: false, // Quitar la cinta de debug
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(), // Llama a HomePage
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase conectado')),
      body: const Center(
        child: Text(
          '¡Hola Mundo! 🚀\nFirebase está inicializado.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
