import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:form_validator/form_validator.dart';
import '/../routes/route.dart';  

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ---------- TUNING ----------
    final double carHeightFactor = 0.55;     // Fraction of screen height used by the car image
    final double carBottomOvershoot = 0.0;   // Negative to push image further down/off-screen
    final Color globalOverlayColor = const Color(0xFF0C3C85);
    final double globalOverlayOpacity = 0.55; // 0 = no tint, 1 = solid
    // ----------------------------

    return Scaffold(
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

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: size.height * 0.06,
                bottom: 40,
              ),
              child: Column(
                children: [
                  const _BrandHeader(
                    showTagline: false,
                    titleSize: 38,
                    iconSize: 60,
                    circleSize: 72,
                  ),
                  const SizedBox(height: 34),

                  Text(
                    'Welcome back',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.97),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue driving & earning',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.82),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _LoginForm(
                    formKey: _formKey,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscure: _obscure,
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                  ),

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4DA6FF),
                            Color(0xFF1D64D9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: GFButton(
                        onPressed: _loading ? null : _submit,
                        size: GFSize.LARGE,
                        color: Colors.transparent,
                        elevation: 0,
                        fullWidthButton: true,
                        shape: GFButtonShape.pills,
                        textStyle: GoogleFonts.poppins(
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

                  const SizedBox(height: 18),
                  GFButton(
                    onPressed: _loading ? null : _forgotPassword,
                    type: GFButtonType.transparent,
                    text: 'Forgot password?',
                    textStyle: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  const _SocialLoginRow(),

                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.register);
                      },
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.78),
                            fontSize: 14,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Logged in (placeholder)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF123A91),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Forgot password flow coming soon',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleGoogle() {
    if (_loading) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Google login coming soon',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF123A91),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleApple() {
    if (_loading) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Apple login coming soon',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF123A91),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;

  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onToggleObscure,
  });

  bool _isValidEmail(String v) {
    final emailRegex =
        RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
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
            ),
            cursorColor: const Color(0xFF8CCBFF),
            decoration: _decoration(
              label: 'Phone number or Email',
              icon: CupertinoIcons.person,
              pillRadius: pillRadius,
            ),
            validator: phoneOrEmailValidator,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: passwordCtrl,
            obscureText: obscure,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
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
                ),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (v) => passwordValidator(v),
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
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.85)),
      suffixIcon: suffix,
      labelStyle: GoogleFonts.poppins(
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
            style: GoogleFonts.poppins(
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
      shaderCallback: (rect) => gradient.createShader(rect),
      child: Text(text, style: style),
    );
  }
}

class _SocialLoginRow extends StatelessWidget {
  const _SocialLoginRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 6),
      child: SizedBox(
        height: 56,
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
    final state = context.findAncestorStateOfType<_LoginScreenState>();
    final bool disabled = (state?._loading) ?? false;

    late final Widget icon;
    late final Color fg;
    late final List<Color> gradient;

    switch (type) {
      case _SocialType.google:
        icon = Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            'G',
            style: GoogleFonts.poppins(
              fontSize: 14,
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
          size: 26,
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
              if (type == _SocialType.google) {
                state?._handleGoogle();
              } else {
                state?._handleApple();
              }
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
                color: Colors.black.withOpacity(0.20),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.15,
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