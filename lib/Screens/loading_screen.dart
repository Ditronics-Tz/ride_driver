import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/route.dart';
import '../core/theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Navigate to login after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Match the auth screens colors
    const Color globalOverlayColor = Color(0xFF0C3C85);
    const double globalOverlayOpacity = 0.55;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (matching auth screens)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                  Color(0xFF123A91),
                ],
              ),
            ),
          ),

          // Car icon background (matching auth screens)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF123A91),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.car_detailed,
                    size: 180,
                    color: Colors.white30,
                  ),
                ),
              ),
            ),
          ),

          // Uniform overlay tint
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: globalOverlayColor.withOpacity(globalOverlayOpacity),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Brand Header
                        _BrandHeader(),

                        const SizedBox(height: 80),

                        // Loading Indicator
                        const _CircularLoadingIndicator(),

                        const SizedBox(height: 40),

                        // Welcome Message
                        Text(
                          'Welcome to',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        _GradientText(
                          'RideShare App',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFF8CCBFF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Your journey to earning starts here',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Brand Header with Logo
class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Circle
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border: Border.all(
              width: 2,
              color: Colors.white.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.car_detailed,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 20),

        // App Name
        _GradientText(
          'RideApp',
          style: GoogleFonts.poppins(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            height: 1.0,
          ),
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFF8CCBFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }
}

// Circular Loading Indicator with Animation
class _CircularLoadingIndicator extends StatefulWidget {
  const _CircularLoadingIndicator();

  @override
  State<_CircularLoadingIndicator> createState() =>
      __CircularLoadingIndicatorState();
}

class __CircularLoadingIndicatorState extends State<_CircularLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer circle background
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),

        // Animated circular progress
        RotationTransition(
          turns: _rotationController,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Color(0xFF8CCBFF),
                  Colors.transparent,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Inner white circle
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2563EB),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            CupertinoIcons.checkmark_alt,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }
}

// Gradient Text Widget
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
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}