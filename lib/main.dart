import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database_helper.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    await DatabaseHelper().initialize();
  } catch (e) {
    print('Error initializing Hive: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Notes Plus',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9575CD),
          primary: const Color(0xFF9575CD),
          secondary: const Color(0xFFB39DDB),
          tertiary: const Color(0xFFCE93D8),
          surface: const Color(0xFFF3E5F5),
          error: const Color(0xFFEF9A9A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9575CD),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF9575CD),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
