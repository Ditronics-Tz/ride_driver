import 'package:flutter/material.dart';
import '../wigdets/map_view.dart';
import '../wigdets/bottom_nav.dart';
import '../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      // Remove the AppBar completely
      body: Stack(
        children: [
          // Main content
          _screens[_currentIndex],

          // Floating hamburger menu button
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                16, // Account for status bar
            left: 16,
            child: FloatingActionButton.small(
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

      // Drawer for navigation menu
      drawer: Drawer(
        backgroundColor: AppColors.backgroundWhite,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.textWhite,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Driver Name',
                    style: AppTextStyles.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  Text(
                    'Online',
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textWhite.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: AppColors.primaryBlue),
              title: Text(
                'Home',
                style: AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _onTabTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: AppColors.primaryBlue),
              title: Text(
                'Profile',
                style: AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _onTabTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: AppColors.primaryBlue),
              title: Text(
                'History',
                style: AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _onTabTapped(2);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: AppColors.textSecondary),
              title: Text(
                'Settings',
                style: AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Add settings navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.error),
              title: Text(
                'Logout',
                style: AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Add logout functionality
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
