import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lwzowcfjgphahaubujel.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx3em93Y2ZqZ3BoYWhhdWJ1amVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0MTc3NzEsImV4cCI6MjA5Nzk5Mzc3MX0.FHQFQSNQRR-IyxFPxJms1uzmSfKDXbyVrIYVoLKE-mE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Royal Hanthawaddy ISM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: const Color.fromARGB(255, 8, 44, 98),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 5, 29, 66),
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
