import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class RideButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isOnline;

  const RideButton({super.key, required this.onPressed, this.isOnline = false});

  @override
  State<RideButton> createState() => _RideButtonState();
}

class _RideButtonState extends State<RideButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    if (widget.isOnline) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(RideButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline != oldWidget.isOnline) {
      if (widget.isOnline) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: () {
        widget.onPressed();
        // Add haptic feedback
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          // Light impact for iOS
          // HapticFeedback.lightImpact();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _scaleController]),
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_scaleController.value * 0.1),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse ring when online
                if (widget.isOnline) ...[
                  _buildPulseRing(_pulseController.value, 0.3),
                  _buildPulseRing(_pulseController.value - 0.3, 0.2),
                ],

                // Main button
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isOnline
                          ? [
                              AppColors.success,
                              AppColors.success.withOpacity(0.8),
                            ]
                          : [
                              AppColors.primaryBlue,
                              AppColors.primaryBlue.withOpacity(0.8),
                            ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (widget.isOnline
                                    ? AppColors.success
                                    : AppColors.primaryBlue)
                                .withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isOnline ? Icons.pause : Icons.play_arrow,
                        color: AppColors.textWhite,
                        size: 28,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isOnline ? 'ONLINE' : 'GO\nONLINE',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 8,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Shine effect
                if (!widget.isOnline)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white24,
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.3, 1.0],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseRing(double animationValue, double opacity) {
    if (animationValue < 0) return const SizedBox();

    return Transform.scale(
      scale: 1.0 + (animationValue * 0.5),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.success.withOpacity(
              opacity * (1.0 - animationValue),
            ),
            width: 2,
          ),
        ),
      ),
    );
  }
}

// Alternative compact version for smaller screens
class CompactRideButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isOnline;

  const CompactRideButton({
    super.key,
    required this.onPressed,
    this.isOnline = false,
  });

  @override
  State<CompactRideButton> createState() => _CompactRideButtonState();
}

class _CompactRideButtonState extends State<CompactRideButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isOnline
              ? [AppColors.success, AppColors.success.withOpacity(0.8)]
              : [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (widget.isOnline ? AppColors.success : AppColors.primaryBlue)
                .withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isOnline ? Icons.pause_circle : Icons.play_circle,
            color: AppColors.textWhite,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.isOnline ? 'Go Offline' : 'Go Online',
            style: AppTextStyles.button.copyWith(
              color: AppColors.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
