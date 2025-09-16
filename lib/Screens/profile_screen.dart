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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false, // Removed back button
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    // Profile Image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textWhite,
                          width: 4,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 58,
                        backgroundImage: AssetImage(
                          'assets/images/profile_placeholder.png',
                        ),
                        backgroundColor: AppColors.backgroundLight,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Driver Name
                    Text(
                      'Ethan Carter',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Joined Date
                    Text(
                      'Joined 2021',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textWhite.withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Edit Profile Button
                    SizedBox(
                      width: 200,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to edit profile screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textWhite,
                          foregroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'Edit Profile',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Profile Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Details Section
                  _buildSectionHeader('Vehicle Details'),
                  const SizedBox(height: 15),

                  _buildProfileItem(
                    icon: Icons.directions_car,
                    title: 'Toyota Camry',
                    subtitle: 'License Plate: C4R-D3V',
                    onTap: () {
                      // Navigate to vehicle details
                    },
                  ),

                  const SizedBox(height: 30),

                  // Ratings & Performance Section
                  _buildSectionHeader('Ratings & Performance'),
                  const SizedBox(height: 15),

                  _buildProfileItem(
                    icon: Icons.star,
                    title: 'Overall Rating',
                    subtitle: '4.85/5.00',
                    onTap: () {
                      // Navigate to ratings details
                    },
                  ),

                  const SizedBox(height: 15),

                  _buildProfileItem(
                    icon: Icons.location_on,
                    title: 'Total Trips',
                    subtitle: '1,200',
                    onTap: () {
                      // Navigate to trip history
                    },
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error.withOpacity(0.1)
                : AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary.withOpacity(0.6),
          size: 20,
        ),
      ),
    );
  }
}
