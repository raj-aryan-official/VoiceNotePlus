import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

/// ====== SPLASH SCREEN WIDGET ======
/// 
/// Splash Screen - Initial branding screen shown when app starts
/// Features:
///   - Beautiful teal gradient background
///   - Animated app icon with shadow effect
///   - App title and tagline
///   - Loading progress indicator
///   - 3-second delay before navigating to HomeScreen
///   - Smooth navigation using pushReplacement
/// 
/// Purpose:
///   - Show branding and welcome message
///   - Give time for Hive database to initialize
///   - Improve perceived app launch speed
///   - Professional user experience
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// State class for SplashScreen
/// Manages:
///   - 3-second timer before navigation
///   - Safe navigation (checks if widget is still mounted)
class _SplashScreenState extends State<SplashScreen> {
  /// ====== INITIALIZATION ======
  /// 
  /// Called when widget is created
  /// Sets up timer to automatically navigate after 3 seconds
  @override
  void initState() {
    super.initState();
    
    // Create a timer that fires after 3 seconds
    // Duration gives time for:
    //   - Hive database to fully initialize
    //   - User to see and appreciate splash screen
    //   - Smooth transition to main app
    Timer(const Duration(seconds: 3), () {
      // Check if widget is still mounted before navigation
      // Prevents crashes if user closes app during splash screen
      if (mounted) {
        // Use pushReplacement to navigate to HomeScreen
        // This removes SplashScreen from navigation stack
        // User cannot go back to splash screen (prevents loop)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  /// ====== UI BUILD ======
  /// 
  /// Main build method creating splash screen UI
  /// Uses gradient background with centered content
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ====== BODY CONTAINER ======
      body: Container(
        // Full-screen gradient background (top-left to bottom-right)
        // Teal gradient: dark teal to medium teal
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00695C),  // Dark teal
              Color(0xFF00897B),  // Medium teal
            ],
          ),
        ),
        // Center all content in the middle of screen
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ====== APP ICON SECTION ======
              // Circular white container with mic icon inside
              Container(
                width: 120,
                height: 120,
                // Circular shape with white background and shadow
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.9),  // Slightly transparent white
                  // Drop shadow for depth
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,     // Soft blur
                      spreadRadius: 5,    // Wide shadow spread
                    ),
                  ],
                ),
                // Microphone icon inside circle
                child: const Icon(
                  Icons.mic_rounded,      // Rounded microphone icon
                  size: 70,               // Large icon
                  color: Color(0xFF00695C),  // Dark teal color
                ),
              ),
              const SizedBox(height: 40),
              
              // ====== APP NAME/TITLE ======
              // Main app title displayed prominently
              const Text(
                'Voice Notes Plus',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,    // Heavy weight for prominence
                  color: Colors.white,
                  letterSpacing: 1.2,             // Wide letter spacing for elegance
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // ====== TAGLINE ======
              // Descriptive subtitle
              const Text(
                'Capture Your Notes Effortlessly',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,          // Slightly transparent white
                  fontStyle: FontStyle.italic,    // Italic for elegance
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              
              // ====== WELCOME MESSAGE ======
              // Greeting text
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,    // Semi-bold
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              
              // ====== LOADING PROGRESS BAR ======
              // Visual indicator that app is loading/initializing
              SizedBox(
                width: 80,
                // Linear progress bar (indeterminate - animated)
                child: LinearProgressIndicator(
                  // Progress bar color: white with transparency
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                  // Background color: more transparent white
                  backgroundColor: Colors.white.withOpacity(0.3),
                  minHeight: 3,  // Thin progress bar
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
