import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/theme.dart';
import '../routes/route.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);
        // Navigate to different screens based on tab
        switch (index) {
          case 0:
            Navigator.pushNamed(context, AppRoutes.home);
            break;
          case 1:
            Navigator.pushNamed(
              context,
              AppRoutes.history,
            ); // Added history navigation
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.profile);
            break;
        }
      },
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.clock),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_circle),
          label: 'Profile',
        ),
      ],
    );
  }
}
