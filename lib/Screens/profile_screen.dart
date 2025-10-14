import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../wigdets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 2; // Profile tab is at index 2

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to different screens based on tab
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Navigate to history screen when implemented
        break;
      case 2:
        // Stay on profile screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section (White background)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(color: AppColors.backgroundWhite),
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundLight,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Driver Name
                  Text(
                    'Dady Nasser',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '5.00 Rating',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Personal info',
              onTap: () {
                // Navigate to personal info
              },
            ),

            _buildMenuItem(
              icon: Icons.security_outlined,
              title: 'Login & security',
              onTap: () {
                // Navigate to login & security
              },
            ),

            _buildMenuItem(
              icon: Icons.language,
              title: 'Language',
              onTap: () {
                // Navigate to language settings
              },
            ),

            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                // Handle logout
              },
            ),

            _buildMenuItem(
              icon: Icons.delete_forever,
              title: 'Delete account',
              onTap: () {
                // Handle delete account
              },
            ),

            // Vehicle Details Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Details',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/icons/car.png',
                          width: 18,
                          height: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Toyota Camry',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'License Plate: C4R-D3V',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary.withOpacity(0.6),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(0),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: AppColors.textSecondary, size: 24),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const SizedBox.shrink(),
      ),
    );
  }
}
