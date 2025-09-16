import 'package:flutter/material.dart';
import '../wigdets/map_view.dart';
import '../wigdets/bottom_nav.dart';
import '../core/theme.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapView(), // Home tab shows the map
    const Center(child: Text('Profile Screen')), // Placeholder for profile
    const Center(child: Text('History Screen')), // Placeholder for history
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ride Driver',
          style: AppTextStyles.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.primaryBlue, // Use theme color
        foregroundColor: AppColors.textWhite, // Use theme color
        automaticallyImplyLeading: false, // This removes the back button
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
