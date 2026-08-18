import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lwzowcfjgphahaubujel.supabase.co',
    publishableKey: 'sb_publishable_MD6KgkvbEEfDq2sxRl6_Uw_pmUJkbys',
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
          seedColor: const Color.fromARGB(255, 8, 44, 98),
          primary: const Color.fromARGB(255, 8, 44, 98),
          primaryContainer: const Color.fromARGB(255, 8, 44, 98),
          onPrimary: Colors.white,
          onPrimaryContainer: Colors.white,
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
