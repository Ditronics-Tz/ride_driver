import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../routes/route.dart';

class AppNavigationDrawer extends ConsumerWidget {
  final Function(int) onTabSelected;

  const AppNavigationDrawer({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.backgroundWhite,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.backgroundWhite),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundLight,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Driver Name',
                  style: AppTextStyles.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Online',
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home_rounded, color: AppColors.textSecondary),
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
              onTabSelected(0);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.verified_user_rounded,
              color: AppColors.textSecondary,
            ),
            title: Text(
              'Verification',
              style: AppTextStyles.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.verification);
            },
          ),
          const Divider(color: AppColors.backgroundLight),
          ListTile(
            leading: Icon(
              Icons.settings_rounded,
              color: AppColors.textSecondary,
            ),
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
            leading: Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            title: Text(
              'Logout',
              style: AppTextStyles.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            onTap: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);

              try {
                await ref.read(authControllerProvider.notifier).logout();
                navigator.pushNamedAndRemoveUntil(
                  AppRoutes.welcome,
                  (route) => false,
                );
              } catch (error) {
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        error.toString(),
                        style: AppTextStyles.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textWhite,
                        ),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}
