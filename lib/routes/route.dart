import 'package:flutter/material.dart';
import '../Screens/welcome.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String rides = '/rides';
  static const String earnings = '/earnings';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
        // login: (context) => const LoginScreen(), // Add when created
        // home: (context) => const HomeScreen(), // Add when created
        // profile: (context) => const ProfileScreen(), // Add when created
        // rides: (context) => const RidesScreen(), // Add when created
        // earnings: (context) => const EarningsScreen(), // Add when created
      };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (context) => const WelcomeScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}