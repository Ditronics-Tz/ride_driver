import 'package:flutter/material.dart';
import '../Screens/welcome.dart';
import '../Screens/AuthScreens/login_screen.dart';
import '../Screens/AuthScreens/register_screen.dart';
import '../Screens/AuthScreens/otp.dart';
import '../Screens/home_screen.dart'; // Added import for HomeScreen

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String rides = '/rides';
  static const String earnings = '/earnings';

  static Map<String, WidgetBuilder> get routes => {
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    otp: (context) => const OtpScreen(),
    home: (context) => const HomeScreen(), // Added HomeScreen route
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case otp:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case home: // Added case for home
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
