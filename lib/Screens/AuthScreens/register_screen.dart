import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:form_validator/form_validator.dart';
import '../../routes/route.dart'; // <--- add this line if not already present

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController(); // phone or email
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ---------- TUNING ----------
    final double carHeightFactor = 0.55;
    final double carBottomOvershoot = 0.0;
    final Color globalOverlayColor = const Color(0xFF0C3C85);
    final double globalOverlayOpacity = 0.55;
    const double pillRadius = 40;
    // ----------------------------

    final canSubmit = !_loading && _acceptedTerms;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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

          // Car image bottom
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

          // Uniform tint
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: globalOverlayColor.withOpacity(globalOverlayOpacity),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: size.height * 0.055,
                bottom: 40,
              ),
              child: Column(
                children: [
                  const _BrandHeader(
                    showTagline: false,
                    titleSize: 36,
                    iconSize: 56,
                    circleSize: 70,
                  ),
                  const SizedBox(height: 30),

                  Text(
                    'Create your account',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.97),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Start driving & earning with RideApp',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.82),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _RegisterForm(
                    formKey: _formKey,
                    nameCtrl: _nameCtrl,
                    contactCtrl: _contactCtrl,
                    passwordCtrl: _passwordCtrl,
                    confirmCtrl: _confirmCtrl,
                    obscurePass: _obscurePass,
                    obscureConfirm: _obscureConfirm,
                    onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
                    onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    pillRadius: pillRadius,
                  ),

                  const SizedBox(height: 20),

                  // Terms acceptance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _toggleTerms,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _acceptedTerms
                                ? const Color(0xFF4DA6FF)
                                : Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _acceptedTerms
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleTerms,
                          behavior: HitTestBehavior.translucent,
                          child: Text.rich(
                            TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13.2,
                                height: 1.35,
                                color: Colors.white.withOpacity(0.82),
                              ),
                              children: const [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Color(0xFF8CCBFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' & '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF8CCBFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: canSubmit
                            ? const LinearGradient(
                                colors: [Color(0xFF4DA6FF), Color(0xFF1D64D9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  const Color(0xFF4DA6FF).withOpacity(0.45),
                                  const Color(0xFF1D64D9).withOpacity(0.45),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          if (canSubmit)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                        ],
                      ),
                      child: GFButton(
                        onPressed: canSubmit ? _submit : null,
                        size: GFSize.LARGE,
                        color: Colors.transparent,
                        elevation: 0,
                        fullWidthButton: true,
                        shape: GFButtonShape.pills,
                        textStyle: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        child: _loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const GFLoader(
                                    type: GFLoaderType.circle,
                                    size: GFSize.SMALL,
                                    loaderColorOne: Colors.white,
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Creating...',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // TEMP TEST REGISTER BUTTON (bypasses validation & terms)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4DA6FF), Color(0xFF1D64D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: GFButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
                        },
                        size: GFSize.LARGE,
                        color: Colors.transparent,
                        elevation: 0,
                        fullWidthButton: true,
                        shape: GFButtonShape.pills,
                        textStyle: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        child: const Text(
                          'Register (Bypassed)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Social row (reuse)
                  const _SocialLoginRow(),

                  // Already have account link
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.75),
                      ),
                      children: const [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: Color(0xFF8CCBFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
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

  void _toggleTerms() => setState(() => _acceptedTerms = !_acceptedTerms);

  Future<void> _submit() async {
    // TEMP: Bypass registration form for testing – go straight to onboarding.
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    return;

    /*
    // Original logic (restore when done testing)
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please accept the terms first',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Account created (placeholder)',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF123A91),
        behavior: SnackBarBehavior.floating,
      ),
    );
    */
  }
}

/* ------------------ FORM WIDGET ------------------ */

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController contactCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool obscurePass;
  final bool obscureConfirm;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;
  final double pillRadius;

  const _RegisterForm({
    required this.formKey,
    required this.nameCtrl,
    required this.contactCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscurePass,
    required this.obscureConfirm,
    required this.onTogglePass,
    required this.onToggleConfirm,
    required this.pillRadius,
  });

  bool _isValidEmail(String v) {
    final emailRegex =
        RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
    return emailRegex.hasMatch(v);
  }

  bool _isValidPhone(String v) {
    final phone = v.replaceAll(' ', '');
    final phoneRegex = RegExp(r'^\+?\d{7,15}$');
    return phoneRegex.hasMatch(phone);
  }

  InputDecoration _dec({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.85)),
      suffixIcon: suffix,
      labelStyle: GoogleFonts.inter(
        color: Colors.white.withOpacity(0.85),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameValidator = ValidationBuilder()
        .minLength(2, 'Too short')
        .regExp(RegExp(r'[A-Za-z]'), 'Invalid')
        .build();

    String? contactValidator(String? v) {
      if (v == null || v.trim().isEmpty) return 'Required';
      final val = v.trim();
      if (_isValidEmail(val) || _isValidPhone(val)) return null;
      return 'Enter valid email or phone';
    }

    final passwordValidator =
        ValidationBuilder().minLength(6, 'Min 6 chars').build();

    String? confirmValidator(String? v) {
      if (v == null || v.isEmpty) return 'Required';
      if (v != passwordCtrl.text) return 'Passwords do not match';
      return null;
    }

    TextStyle fieldStyle = GoogleFonts.inter(
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameCtrl,
            keyboardType: TextInputType.name,
            style: fieldStyle,
            cursorColor: const Color(0xFF8CCBFF),
            decoration: _dec(
              label: 'Full name',
              icon: CupertinoIcons.person_crop_circle,
            ),
            validator: (v) => nameValidator(v),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: contactCtrl,
            keyboardType: TextInputType.emailAddress,
            style: fieldStyle,
            cursorColor: const Color(0xFF8CCBFF),
            decoration: _dec(
              label: 'Phone number or Email',
              icon: CupertinoIcons.phone,
            ),
            validator: contactValidator,
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: passwordCtrl,
            obscureText: obscurePass,
            style: fieldStyle,
            cursorColor: const Color(0xFF8CCBFF),
            decoration: _dec(
              label: 'Password',
              icon: CupertinoIcons.lock,
              suffix: IconButton(
                splashRadius: 20,
                icon: Icon(
                  obscurePass ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  color: Colors.white.withOpacity(0.80),
                ),
                onPressed: onTogglePass,
              ),
            ),
            validator: (v) => passwordValidator(v),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: confirmCtrl,
            obscureText: obscureConfirm,
            style: fieldStyle,
            cursorColor: const Color(0xFF8CCBFF),
            decoration: _dec(
              label: 'Confirm password',
              icon: CupertinoIcons.lock_shield,
              suffix: IconButton(
                splashRadius: 20,
                icon: Icon(
                  obscureConfirm ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  color: Colors.white.withOpacity(0.80),
                ),
                onPressed: onToggleConfirm,
              ),
            ),
            validator: confirmValidator,
          ),
        ],
      ),
    );
  }
}

/* ------------------ SHARED BRAND + SOCIAL (duplicated for now) ------------------ */

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
    final titleStyle = GoogleFonts.inter(
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
        const SizedBox(height: 16),
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
          const SizedBox(height: 10),
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
      shaderCallback: (r) => gradient.createShader(r),
      child: Text(text, style: style),
    );
  }
}

class _SocialLoginRow extends StatelessWidget {
  const _SocialLoginRow();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_RegisterScreenState>();
    final bool disabled = state?._loading ?? false;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: SizedBox(
        height: 52,
        child: Row(
          children: const [
            Expanded(
              child: _SocialButton(
                type: _SocialType.google,
                label: 'Google',
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _SocialButton(
                type: _SocialType.apple,
                label: 'Apple',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SocialType { google, apple }

class _SocialButton extends StatelessWidget {
  final _SocialType type;
  final String label;
  const _SocialButton({
    required this.type,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final registerState = context.findAncestorStateOfType<_RegisterScreenState>();
    final bool disabled = registerState?._loading ?? false;

    late final Widget icon;
    late final Color fg;
    late final List<Color> gradient;

    switch (type) {
      case _SocialType.google:
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            'G',
            style: GoogleFonts.inter(
              fontSize: 13,
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
          size: 24,
        );
        gradient = [
          Colors.white.withOpacity(0.14),
          Colors.white.withOpacity(0.08),
        ];
        fg = Colors.white;
        break;
    }

    return GestureDetector(
      onTap: disabled
          ? null
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${label} login coming soon',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: const Color(0xFF123A91),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: disabled ? 0.55 : 1,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}