import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:form_validator/form_validator.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../routes/route.dart';
import '../../core/network/api_exceptions.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showAwesomeSnackbar({
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // Check if form is filled
  bool get _isFormFilled {
    return _emailCtrl.text.isNotEmpty && _passwordCtrl.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    // ---------- TUNING ----------
    final double carHeightFactor = 0.55;     // Fraction of screen height used by the car image
    final double carBottomOvershoot = 0.0;   // Negative to push image further down/off-screen
    final Color globalOverlayColor = const Color(0xFF0C3C85);
    final double globalOverlayOpacity = 0.55; // 0 = no tint, 1 = solid
    // ----------------------------

    return Scaffold(
      resizeToAvoidBottomInset: true, // Handle keyboard properly
      body: Stack(
        children: [
          // Gradient base
          Positioned.fill(
            child: Container(
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
            ),
          ),

          // Car image bottom-anchored
          Positioned(
            left: 0,
            right: 0,
            bottom: carBottomOvershoot,
            child: IgnorePointer(
              child: SizedBox(
                height: size.height * carHeightFactor,
                width: size.width,
                child: Image.asset(
                  'assets/images/md1.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (c, e, s) => Container(
                    color: const Color(0xFF123A91),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.car_detailed,
                      size: 120,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Full-screen uniform tint
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: globalOverlayColor.withOpacity(globalOverlayOpacity),
              ),
            ),
          ),

          // Content - Scrollable to prevent overflow
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Brand header
                      const _BrandHeader(
                        showTagline: false,
                        titleSize: 28,
                        iconSize: 45,
                        circleSize: 55,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Welcome back',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.97),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to continue driving & earning',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.82),
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login form
                      _LoginForm(
                        formKey: _formKey,
                        emailCtrl: _emailCtrl,
                        passwordCtrl: _passwordCtrl,
                        obscure: _obscure,
                        onToggleObscure: () => setState(() => _obscure = !_obscure),
                        onFormChanged: () => setState(() {}), // Trigger rebuild when form changes
                      ),

                      const SizedBox(height: 20),

                      // Login button - always visible with better opacity
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: _isFormFilled
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF4DA6FF),
                                      Color(0xFF1D64D9),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      const Color(0xFF4DA6FF).withOpacity(0.7), // Better visibility
                                      const Color(0xFF1D64D9).withOpacity(0.7), // Better visibility
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              if (_isFormFilled)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                )
                            ],
                          ),
                          child: GFButton(
                            onPressed: (isLoading || !_isFormFilled) 
                                ? () {
                                    // Show helpful message when button is disabled
                                    if (!_isFormFilled) {
                                      _showAwesomeSnackbar(
                                        title: 'Form Incomplete',
                                        message: 'Please fill all fields first',
                                        contentType: ContentType.help,
                                      );
                                    }
                                  }
                                : _submit,
                            size: GFSize.LARGE,
                            color: Colors.transparent,
                            elevation: 0,
                            fullWidthButton: true,
                            shape: GFButtonShape.pills,
                            textStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
              child: isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const GFLoader(
                                        type: GFLoaderType.circle,
                                        size: GFSize.SMALL,
                                        loaderColorOne: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Signing in...',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Compact forgot password button
                      Container(
                        height: 32,
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: isLoading ? null : _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Social login row
                      _SocialLoginRow(onGoogleTap: _handleGoogle, onAppleTap: _handleApple),

                      const SizedBox(height: 16),

                      // Register link
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.register);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Register',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF8CCBFF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ),

      if (isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.30),
                  alignment: Alignment.center,
                  child: const GFLoader(
                    type: GFLoaderType.circle,
                    size: GFSize.LARGE,
                    loaderColorOne: Colors.white,
                    loaderColorTwo: Color(0xFF8CCBFF),
                    loaderColorThree: Color(0xFF4DA6FF),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showAwesomeSnackbar(
        title: 'Validation Error',
        message: 'Please check your credentials',
        contentType: ContentType.warning,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final controller = ref.read(authControllerProvider.notifier);

    try {
      final pending = await controller.login(
        identifier: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;

      _showAwesomeSnackbar(
        title: 'OTP Sent!',
        message: pending.message,
        contentType: ContentType.success,
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.otp);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showAwesomeSnackbar(
        title: 'Login Failed',
        message: e.message,
        contentType: ContentType.failure,
      );
    } catch (_) {
      if (!mounted) return;
      _showAwesomeSnackbar(
        title: 'Login Failed',
        message: 'Unexpected error. Please try again.',
        contentType: ContentType.failure,
      );
    }
  }

  void _forgotPassword() {
    _showAwesomeSnackbar(
      title: 'Coming Soon!',
      message: 'Forgot password feature will be available soon.',
      contentType: ContentType.help,
    );
  }

  void _handleGoogle() {
    if (ref.read(authControllerProvider).isLoading) return;
    _showAwesomeSnackbar(
      title: 'Google Login',
      message: 'Google login is coming soon!',
      contentType: ContentType.help,
    );
  }

  void _handleApple() {
    if (ref.read(authControllerProvider).isLoading) return;
    _showAwesomeSnackbar(
      title: 'Apple Login',
      message: 'Apple login is coming soon!',
      contentType: ContentType.help,
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onFormChanged;

  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.onFormChanged,
  });

  bool _isValidEmail(String v) {
    final emailRegex =
        RegExp(r'^[A-Za-z0-9._%+\-]+@[A-ZaZ0-9.\-]+\.[A-Za-z]{2,}$');
    return emailRegex.hasMatch(v);
  }

  bool _isValidPhone(String v) {
    final phone = v.replaceAll(' ', '');
    final phoneRegex = RegExp(r'^\+?\d{7,15}$'); // allows + then 7–15 digits
    return phoneRegex.hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    const double pillRadius = 40;

    String? phoneOrEmailValidator(String? v) {
      if (v == null || v.trim().isEmpty) return 'Required';
      final value = v.trim();
      if (_isValidEmail(value) || _isValidPhone(value)) return null;
      return 'Enter valid email or phone';
    }

    final passwordValidator =
        ValidationBuilder().minLength(6, 'Min 6 chars').build();

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            cursorColor: const Color(0xFF8CCBFF),
            decoration: _decoration(
              label: 'Phone number or Email',
              icon: CupertinoIcons.person,
              pillRadius: pillRadius,
            ),
            validator: phoneOrEmailValidator,
            onChanged: (_) => onFormChanged(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordCtrl,
            obscureText: obscure,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            cursorColor: const Color(0xFF8CCBFF),
            decoration: _decoration(
              label: 'Password',
              icon: CupertinoIcons.lock,
              pillRadius: pillRadius,
              suffix: IconButton(
                splashRadius: 20,
                icon: Icon(
                  obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  color: Colors.white.withOpacity(0.80),
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
            ),
            validator: passwordValidator,
            onChanged: (_) => onFormChanged(),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    required double pillRadius,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.85), size: 20),
      suffixIcon: suffix,
      labelStyle: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.85),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(pillRadius),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.16),
          width: 1.1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(pillRadius),
        borderSide: const BorderSide(
          color: Color(0xFF8CCBFF),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(pillRadius),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(pillRadius),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool showTagline;
  final double titleSize;
  final double iconSize;
  final double circleSize;
  const _BrandHeader({
    this.showTagline = true,
    this.titleSize = 40,
    this.iconSize = 40,
    this.circleSize = 74,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      fontSize: titleSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      height: 1.05,
    );
    return Column(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
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
          child: Icon(
            CupertinoIcons.car_detailed,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        const SizedBox(height: 12),
        _GradientText(
          'RideApp',
          style: titleStyle,
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFF8CCBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            'Join us to start earning',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.92),
              letterSpacing: 0.25,
            ),
          ),
        ],
      ],
    );
  }
}

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

class _SocialLoginRow extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  const _SocialLoginRow({
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: _SocialButton(
              type: _SocialType.google,
              label: 'Google',
              onTap: onGoogleTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SocialButton(
              type: _SocialType.apple,
              label: 'Apple',
              onTap: onAppleTap,
            ),
          ),
        ],
      ),
    );
  }
}

enum _SocialType { google, apple }

class _SocialButton extends StatelessWidget {
  final _SocialType type;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.type,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    late final Widget icon;
    late final Color fg;
    late final List<Color> gradient;

    switch (type) {
      case _SocialType.google:
        icon = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            'G',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4285F4),
              letterSpacing: -0.4,
            ),
          ),
        );
        gradient = [
          Colors.white.withOpacity(0.92),
          Colors.white.withOpacity(0.86),
        ];
        fg = const Color(0xFF1C1C1C);
        break;
      case _SocialType.apple:
        icon = const Icon(
          Icons.apple,
          color: Colors.white,
          size: 20,
        );
        gradient = [
          Colors.white.withOpacity(0.14),
          Colors.white.withOpacity(0.08),
        ];
        fg = Colors.white;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.white.withOpacity(0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}