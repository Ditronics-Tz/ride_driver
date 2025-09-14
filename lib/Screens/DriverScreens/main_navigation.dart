import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/driver_provider.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'driver_verification_screen.dart';
import 'route_creation_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: CupertinoIcons.home,
      label: 'Home',
      screen: const HomeScreen(),
    ),
    NavigationItem(
      icon: CupertinoIcons.doc_checkmark,
      label: 'Verification',
      screen: const DriverVerificationScreen(),
    ),
    NavigationItem(
      icon: CupertinoIcons.location_circle,
      label: 'Create Route',
      screen: const RouteCreationScreen(),
    ),
    NavigationItem(
      icon: CupertinoIcons.person_2,
      label: 'Requests',
      screen: const _ComingSoonScreen(title: 'Ride Requests'),
    ),
    NavigationItem(
      icon: CupertinoIcons.car_detailed,
      label: 'Active Trip',
      screen: const _ComingSoonScreen(title: 'Active Trip'),
    ),
    NavigationItem(
      icon: CupertinoIcons.group,
      label: 'Passengers',
      screen: const _ComingSoonScreen(title: 'Passengers View'),
    ),
    NavigationItem(
      icon: CupertinoIcons.money_dollar_circle,
      label: 'Earnings',
      screen: const _ComingSoonScreen(title: 'Earnings & History'),
    ),
    NavigationItem(
      icon: CupertinoIcons.person_circle,
      label: 'Profile',
      screen: const _ComingSoonScreen(title: 'Profile & Settings'),
    ),
    NavigationItem(
      icon: CupertinoIcons.bell,
      label: 'Notifications',
      screen: const _ComingSoonScreen(title: 'Notifications'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final driverInfo = ref.watch(driverInfoProvider);
    final verificationStatus = ref.watch(verificationStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _navigationItems[_selectedIndex].label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        actions: [
          // Mock status indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(verificationStatus),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(verificationStatus),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        CupertinoIcons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      driverInfo.fullName ?? 'Driver Name',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'RideApp Driver',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Items
              ..._navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == index;

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF6B7280),
                    size: 24,
                  ),
                  title: Text(
                    item.label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF374151),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB),
                  selectedTileColor: const Color(0xFF2563EB).withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    Navigator.of(context).pop();
                  },
                );
              }),

              const Divider(),

              // Mock Actions
              ListTile(
                leading: const Icon(
                  CupertinoIcons.refresh,
                  color: Color(0xFF6B7280),
                ),
                title: Text(
                  'Mock Status Update',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
                onTap: () {
                  _mockStatusUpdate();
                  Navigator.of(context).pop();
                },
              ),

              ListTile(
                leading: const Icon(
                  CupertinoIcons.square_arrow_right,
                  color: Color(0xFFEF4444),
                ),
                title: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                onTap: () {
                  _logout();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
      body: _navigationItems[_selectedIndex].screen,
    );
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return const Color(0xFF10B981);
      case VerificationStatus.pending:
        return const Color(0xFFF59E0B);
      case VerificationStatus.rejected:
        return const Color(0xFFEF4444);
      case VerificationStatus.notSubmitted:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return 'VERIFIED';
      case VerificationStatus.pending:
        return 'PENDING';
      case VerificationStatus.rejected:
        return 'REJECTED';
      case VerificationStatus.notSubmitted:
        return 'NOT VERIFIED';
    }
  }

  void _mockStatusUpdate() {
    final currentStatus = ref.read(verificationStatusProvider);
    VerificationStatus nextStatus;
    String message;

    switch (currentStatus) {
      case VerificationStatus.notSubmitted:
      case VerificationStatus.pending:
        nextStatus = VerificationStatus.approved;
        message = 'Congratulations! Your documents have been approved.';
        break;
      case VerificationStatus.approved:
        nextStatus = VerificationStatus.rejected;
        message = 'Some documents need correction. Please resubmit.';
        break;
      case VerificationStatus.rejected:
        nextStatus = VerificationStatus.pending;
        message = 'Documents resubmitted and under review.';
        break;
    }

    ref
        .read(driverProvider.notifier)
        .mockVerificationUpdate(nextStatus, message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Status updated to ${nextStatus.name}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

class _ComingSoonScreen extends StatelessWidget {
  final String title;

  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                CupertinoIcons.hammer,
                size: 60,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'This screen is under development.\nComing soon!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🚧 Under Construction 🚧',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
