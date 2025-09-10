import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/route.dart';  

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final w = constraints.maxWidth;

          // ------------------ TUNING ------------------
            final carHeightFactor = 0.62;
            final carBottomOvershoot = -14;
            final buttonWidth = 100.0;
            final buttonHeight = 54.0;
            final buttonVerticalFactorOnCar = 0.78;
          // ---------------------------------------------

          final carHeight = h * carHeightFactor;
          final buttonBottom = carBottomOvershoot +
              (carHeight * (1 - buttonVerticalFactorOnCar));

          return Container(
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
              top: true,
              bottom: false,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ---- Improved Brand Header ----
                  Positioned(
                    top: h * 0.085,
                    left: 0,
                    right: 0,
                    child: const _BrandHeader(),
                  ),

                  // Car image
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: carBottomOvershoot.toDouble(),
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

                  // Start button
                  Positioned(
                    left: (w - buttonWidth) / 2,
                    bottom: buttonBottom,
                    child: _StartButton(
                      width: buttonWidth,
                      height: buttonHeight,
                      onTap: () => _handleStartButton(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleStartButton(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.login);
  }
}

// Brand header widget
class _BrandHeader extends StatelessWidget {
  const _BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final titleBaseStyle = GoogleFonts.inter(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      height: 1.05,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon in soft glass circle
        Container(
          width: 74,
          height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
              border: Border.all(
                width: 1.2,
                color: Colors.white.withOpacity(0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          alignment: Alignment.center,
          child: const Icon(
            CupertinoIcons.car_detailed, // Cleaner iOS-style car icon
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        // Gradient brand name
        _GradientText(
          'RideApp',
          style: titleBaseStyle,
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFF8CCBFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        const SizedBox(height: 10),
        // Tagline row
        Text(
          'Join us to start earning',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.92),
            letterSpacing: 0.25,
          ),
        ),
      ],
    );
  }
}

// Simple gradient text helper
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  const _GradientText(
    this.text, {
    required this.style,
    required this.gradient,
   
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => gradient.createShader(rect),
      child: Text(text, style: style),
    );
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