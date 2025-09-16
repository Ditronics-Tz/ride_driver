import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../wigdets/map_view.dart';
import '../wigdets/bottom_nav.dart';
import '../core/theme.dart';
import '../wigdets/navigation_drawer.dart';
import '../wigdets/ride_button.dart';

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

  void _createRide() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.add_road, color: AppColors.primaryBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Create Ride Trip',
                style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Do you want to create a new ride trip and start accepting passengers?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                // Show success notification after creating ride
                final snackBar = SnackBar(
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  content: AwesomeSnackbarContent(
                    title: 'Ride Created!',
                    message: 'Your ride trip has been created successfully.',
                    contentType: ContentType.success,
                  ),
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Create Trip',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          children: [
            _screens[_currentIndex],

            // Menu Button (Top Left)
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton.small(
                heroTag: 'menuButton',
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.textWhite,
                elevation: 4,
                child: const Icon(Icons.menu, size: 20),
              ),
            ),

            // Ride Button (Above Location Button) - Only show on map view
            if (_currentIndex == 0) ...[
              Positioned(
                right: 16,
                bottom: 100,
                child: RideButton(onPressed: _createRide),
              ),
            ],
          ],
        ),
      ),
      drawer: AppNavigationDrawer(onTabSelected: _onTabTapped),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
