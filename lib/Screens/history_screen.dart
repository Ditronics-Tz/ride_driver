import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import '../core/theme.dart';
import '../wigdets/bottom_nav.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentIndex = 1; // History tab is at index 1

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
        // Stay on history screen
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Ride History',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false, // Removed back button
      ),
      body: _buildRidesList(),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildRidesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Today Section
        _buildDateHeader('Today'),
        const SizedBox(height: 12),
        _buildRideItem('\$12.50', '10:00 AM', '15 min', 5.0),
        const SizedBox(height: 8),
        _buildRideItem('\$15.75', '11:30 AM', '20 min', 4.8),

        const SizedBox(height: 24),

        // Yesterday Section
        _buildDateHeader('Yesterday'),
        const SizedBox(height: 12),
        _buildRideItem('\$18.00', '9:00 AM', '25 min', 5.0),
        const SizedBox(height: 8),
        _buildRideItem('\$14.20', '10:30 AM', '18 min', 5.0),
        const SizedBox(height: 8),
        _buildRideItem('\$22.50', '12:00 PM', '30 min', 4.9),

        const SizedBox(height: 100), // Space for bottom nav
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Text(
      date,
      style: AppTextStyles.headingMedium.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRideItem(
    String amount,
    String time,
    String duration,
    double rating,
  ) {
    return GFCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      content: GFListTile(
        padding: const EdgeInsets.all(16),
        avatar: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.directions_car,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          amount,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subTitle: Text(
          '$time • $duration',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            Text(
              rating.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
