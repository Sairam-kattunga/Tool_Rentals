import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/Authentication/login_screen.dart';
import 'screens/Authentication/register_screen.dart';
import 'screens/Authentication/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/Profile/ProfileScreen.dart';
import 'screens/RentTool/RentToolScreen.dart';
import 'screens/MyTools/MyToolsScreen.dart';
import 'screens/MyRentals/MyRentalsScreen.dart';
import 'screens/listing_choice_screen.dart';

import 'screens/Policies/policies_screen.dart';
import 'screens/AppSettings/app_settings_screen.dart';
import 'screens/UserAccount/user_account_screen.dart';
import 'screens/HelpInfo/help_info_screen.dart';
import 'screens/HelpInfo/support_form_screen.dart';
import 'screens/HelpInfo/faq_screen.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'intro_screen.dart'; // ⬅️ Import IntroScreen

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
      title: 'RentEazy',
      theme: AppTheme.lightTheme,

      // ⬅️ Always start with IntroScreen
      home: IntroScreen(isLoggedIn: isLoggedIn),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/rent_tool': (context) => const RentToolScreen(),
        '/my_tools': (context) => const MyListingsScreen(),
        '/list_choice': (context) => const ListingChoiceScreen(),
        '/policies': (context) => const PoliciesScreen(),
        '/app_settings': (context) => const AppSettingsScreen(),
        '/user_account': (context) => const UserAccountScreen(),
        '/help_info': (context) => const HelpInfoScreen(),
        '/support': (context) => const SupportFormScreen(),
        '/faq': (context) => const FaqScreen(),
        '/my_rentals': (context) => const MyRentalsScreen(),
      },
    );
  }
}
