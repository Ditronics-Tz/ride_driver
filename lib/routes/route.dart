import 'package:flutter/material.dart';
import '../Screens/loading_screen.dart';
import '../Screens/welcome.dart';
import '../Screens/AuthScreens/login_screen.dart';
import '../Screens/AuthScreens/register_screen.dart';
import '../Screens/AuthScreens/otp.dart';
import '../Screens/home_screen.dart';
import '../Screens/DriverScreens/verification_screen.dart';
import '../Screens/profile_screen.dart';
import '../Screens/history_screen.dart'; // Added history screen import

class AppRoutes {
  static const String loading = '/loading';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String history = '/history'; // Added history route
  static const String rides = '/rides';
  static const String earnings = '/earnings';
  static const String verification = '/verification';

  static Map<String, WidgetBuilder> get routes => {
    loading: (context) => const LoadingScreen(),
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    otp: (context) => const OtpScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    history: (context) => const HistoryScreen(), // Added history screen
    verification: (context) => const VerificationScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loading:
        return MaterialPageRoute(builder: (_) => const LoadingScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case otp:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case history: // Added history case
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case verification:
        return MaterialPageRoute(builder: (_) => const VerificationScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
