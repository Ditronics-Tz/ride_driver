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
import '../Screens/DriverScreens/create_ride_screen.dart';
import '../wigdets/ride_card.dart';

import 'package:latlong2/latlong.dart';

class AppRoutes {
  // Toggle to disable auth flows for internal polishing
  static const bool authDisabled = true;
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
  static const String createRide = '/create-ride';
  static const String earnings = '/earnings';
  static const String verification = '/verification';
  static const String map = '/map';

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
        return authDisabled
            ? MaterialPageRoute(builder: (_) => const HomeScreen())
            : MaterialPageRoute(builder: (_) => const LoadingScreen());
      case welcome:
        return authDisabled
            ? MaterialPageRoute(builder: (_) => const HomeScreen())
            : MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return authDisabled
            ? MaterialPageRoute(builder: (_) => const HomeScreen())
            : MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return authDisabled
            ? MaterialPageRoute(builder: (_) => const HomeScreen())
            : MaterialPageRoute(builder: (_) => const RegisterScreen());
      case otp:
        return authDisabled
            ? MaterialPageRoute(builder: (_) => const HomeScreen())
            : MaterialPageRoute(builder: (_) => const OtpScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case history: // Added history case
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case verification:
        return MaterialPageRoute(builder: (_) => const VerificationScreen());
      case createRide:
        {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              args['start'] == null ||
              args['end'] == null ||
              args['start_address'] == null ||
              args['end_address'] == null) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Invalid route parameters')),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (_) => CreateRideScreen(
              start: args['start'] as LatLng,
              end: args['end'] as LatLng,
              startAddress: args['start_address'] as String,
              endAddress: args['end_address'] as String,
            ),
          );
        }
      case rides:
        {
          LatLng? start;
          LatLng? end;
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            if (args['start'] is LatLng) start = args['start'] as LatLng;
            if (args['end'] is LatLng) end = args['end'] as LatLng;
          }
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: SafeArea(
                child: RideCard(
                  title:
                      'Ride from (${start?.latitude.toStringAsFixed(2) ?? 'N/A'}, ${start?.longitude.toStringAsFixed(2) ?? 'N/A'}) to (${end?.latitude.toStringAsFixed(2) ?? 'N/A'}, ${end?.longitude.toStringAsFixed(2) ?? 'N/A'})',
                  subtitle: 'Tap to view details',
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: 0,
                onTap: (i) {
                  switch (i) {
                    case 0:
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                      break;
                    case 1:
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.history,
                      );
                      break;
                    case 2:
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.profile,
                      );
                      break;
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Ride'),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          );
        }

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
