import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database_helper.dart';
import 'splash_screen.dart';

/// ====== APPLICATION ENTRY POINT ======
/// 
/// Main entry point for Voice Notes Plus application
/// Handles critical initialization tasks before app launch:
/// 1. Initialize Flutter bindings for platform channels
/// 2. Initialize Hive database system
/// 3. Set up database schema and storage
/// 4. Launch the app root widget (MyApp)
/// 
/// This runs before any UI is rendered, ensuring all services are ready
void main() async {
  // Ensure Flutter bindings are initialized
  // Required for async operations before runApp()
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive local database
    // Sets up Hive for Flutter (creates application documents directory)
    await Hive.initFlutter();
    
    // Initialize DatabaseHelper singleton
    // Creates Hive boxes, initializes note counter from database
    // This is essential before any database operations
    await DatabaseHelper().initialize();
  } catch (e) {
    // Log initialization errors but continue
    // App will still run but may not save data properly
    print('Error initializing Hive: $e');
  }
  
  // Launch the app root widget
  // This displays the splash screen first (via SplashScreen)
  runApp(const MyApp());
}

/// ====== ROOT APPLICATION WIDGET ======
/// 
/// MyApp - Root stateless widget for the entire application
/// Configures:
///   - Material Design 3 theme with teal color palette
///   - App name and title
///   - Color scheme (primary, secondary, tertiary, error)
///   - AppBar and FAB theming
///   - Initial navigation route (SplashScreen)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ====== APP CONFIGURATION ======
      title: 'Voice Notes Plus',
      
      // ====== THEME CONFIGURATION ======
      theme: ThemeData(
        // Use Material Design 3 (modern Flutter design system)
        useMaterial3: true,
        
        // ====== COLOR SCHEME - TEAL PALETTE ======
        colorScheme: ColorScheme.fromSeed(
          // Seed color for generating harmonious color scheme
          seedColor: const Color(0xFF00695C),
          // Primary color - main brand color (dark teal)
          // Used for: AppBar, FAB, buttons, links
          primary: const Color(0xFF00695C),
          // Secondary color - accent color (medium teal)
          // Used for: secondary buttons, highlights
          secondary: const Color(0xFF00897B),
          // Tertiary color - additional accent (light teal)
          // Used for: chips, badges, tertiary actions
          tertiary: const Color(0xFF26A69A),
          // Surface color - light background (very light teal)
          // Used for: card backgrounds, panel backgrounds
          surface: const Color(0xFFE0F2F1),
          // Error color - for error states and alerts
          error: const Color(0xFFF44336),
        ),
        
        // ====== APP BAR THEME ======
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00695C),  // Dark teal
          foregroundColor: Colors.white,       // White text and icons
        ),
        
        // ====== FLOATING ACTION BUTTON THEME ======
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00695C),  // Dark teal
          foregroundColor: Colors.white,       // White icon
        ),
      ),
      
      // ====== INITIAL ROUTE ======
      // Display SplashScreen first - user sees branding before main app
      // SplashScreen handles 3-second delay, then navigates to HomeScreen
      home: const SplashScreen(),
    );
  }
}
