import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Remove the black background; gradient will cover everything.
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          // Keep top safe area; bottom can extend if you prefer:
          // top: true, bottom: false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Logo & name
              Positioned(
                top: size.height * 0.10,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      color: Colors.white,
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          height: 1.05,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Driver',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Ride',
                            style: TextStyle(
                              color: Color(0xFF6CB4FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Car image
              Positioned(
                bottom: size.height * 0.18,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: size.height * 0.42,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(
                      'assets/images/md.png',
                      errorBuilder: (context, error, stack) => Container(
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

              // Start button
              Positioned(
                bottom: size.height * 0.06,
                child: _StartButton(
                  onTap: () => _handleStartButton(context),
                ),
              ),
            ],
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
  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 96,
        height: 54,
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
              color: Colors.black.withOpacity(0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
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