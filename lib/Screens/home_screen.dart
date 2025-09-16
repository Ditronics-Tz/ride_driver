import 'package:flutter/material.dart';
import '../wigdets/map_view.dart';
import '../wigdets/bottom_nav.dart';
import '../core/theme.dart';
import '../wigdets/navigation_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const MapView(), // Index 0: Home
    const Center(child: Text('History Screen')), // Index 1: History
    const Center(child: Text('Profile Screen')), // Index 2: Profile
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          children: [
            _screens[_currentIndex],
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton.small(
                heroTag: 'menuButton', // Add unique hero tag
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.textWhite,
                elevation: 4,
                child: const Icon(Icons.menu, size: 20),
              ),
            ),
          ],
        ),
      ),
      drawer: AppNavigationDrawer(onTabSelected: _onTabTapped), // Updated here
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
