import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF123A91),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final w = constraints.maxWidth;

              // Tunable layout numbers (adjust if needed)
              final carHeight = h * 0.58;          // overall car display height
              final carBottomOvershoot = -9.0;     // push car slightly off-screen bottom
              final buttonLiftFromCarBottom = carHeight * 0.38; // how high button floats over car
              final buttonWidth = 92.0;
              final buttonHeight = 52.0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Logo + name
                  Positioned(
                    top: h * 0.10,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_car_outlined,
                            color: Colors.white, size: 54),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 38,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                            children: const [
                              TextSpan(
                                text: 'eDri',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'ver',
                                style: TextStyle(color: Color(0xFF6CB4FF)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Car (anchored bottom, slightly larger & overshooting)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: carBottomOvershoot,
                    child: IgnorePointer(
                      child: SizedBox(
                        height: carHeight,
                        width: w,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/images/md1.png',
                            height: carHeight,
                            errorBuilder: (c, e, s) => Container(
                              width: 220,
                              height: 300,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.directions_car_filled,
                                size: 80,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Button (floats over upper part of the car)
                  Positioned(
                    left: (w - buttonWidth) / 2,
                    bottom: carBottomOvershoot + buttonLiftFromCarBottom,
                    child: _StartButton(
                      width: buttonWidth,
                      height: buttonHeight,
                      onTap: () => _handleStartButton(context),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleStartButton(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Starting eDriver...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF123A91),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login screen coming soon!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final double height;
  const _StartButton({
    required this.onTap,
    this.width = 96,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4DA6FF),
              Color(0xFF1D64D9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}