import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_signup.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TravelApp(),
    ),
  );
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF168B83);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: teal,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: teal,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121817),
      ),
      themeMode: ThemeMode.system,
      home: const AuthScreen(),
    );
  }
}