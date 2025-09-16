import 'package:flutter/material.dart';
import '../core/theme.dart'; // Add this import

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.backgroundWhite, // Use theme color
      selectedItemColor: AppColors.primaryBlue, // Use theme color
      unselectedItemColor: AppColors.textSecondary, // Use theme color
      selectedLabelStyle: AppTextStyles.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue,
      ),
      unselectedLabelStyle: AppTextStyles.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      ],
    );
  }
}
