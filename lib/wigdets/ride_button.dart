import 'package:flutter/material.dart';
import '../core/theme.dart';

class RideButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RideButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add, color: AppColors.textWhite, size: 32),
      ),
    );
  }
}
