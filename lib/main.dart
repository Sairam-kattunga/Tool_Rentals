import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ProfileScreen.dart';
import 'screens/SettingsScreen.dart';
import 'screens/SupportScreen.dart';
import 'screens/list_tool_screen.dart';
import 'screens/RentToolScreen.dart';
import 'screens/MyToolsScreen.dart';
import 'screens/WalletScreen.dart';   // ✅ Import new screens
import 'screens/HistoryScreen.dart'; // ✅ Import new screens

import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔑 Check saved login state
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tool Rental App',
      theme: AppTheme.lightTheme,

      // 🔑 Start at home if logged in, else login
      initialRoute: isLoggedIn ? '/home' : '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(), // New route for Profile
        '/settings': (context) => const SettingsScreen(), // New route for Settings
        '/support': (context) => const SupportScreen(), // New route for Support
        '/list_tool': (context) => const ListToolScreen(),
        '/rent_tool': (context) => const RentToolScreen(),
        '/my_tools': (context) => const MyToolsScreen(),
        '/wallet': (context) => const WalletScreen(),     // ✅ New route
        '/history': (context) => const HistoryScreen(),   // ✅ New route
      },
    );
  }
}