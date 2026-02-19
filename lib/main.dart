import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const QRApp());
}

class QRApp extends StatelessWidget {
  const QRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
          primary: const Color(0xFF00D4FF),
          secondary: const Color(0xFF7C3AED),
          surface: const Color(0xFF16213E),
          background: const Color(0xFF0F0F1A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        fontFamily: 'Vazirmatn',
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Vazirmatn'),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
