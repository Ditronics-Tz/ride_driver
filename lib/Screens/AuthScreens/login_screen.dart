import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:form_validator/form_validator.dart';

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
    final carHeight = size.height * 0.26;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
            Container(
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

          // Scrollable content
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
                    iconSize: 58,
                    circleSize: 70,
                  ),
                  const SizedBox(height: 26),

                  // Car image (brand consistency)
                  SizedBox(
                    height: carHeight,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        'assets/images/md1.png',
                        height: carHeight,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.directions_car_filled,
                          size: 110,
                          color: Colors.white30,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Welcome back',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue driving & earning',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.80),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _LoginForm(
                    formKey: _formKey,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscure: _obscure,
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                  ),

                  const SizedBox(height: 22),

                  // Gradient-wrapped GetWidget button
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
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: GFButton(
                        onPressed: _loading ? null : _submit,
                        size: GFSize.LARGE,
                        color: Colors.transparent, // gradient provides color
                        elevation: 0,
                        fullWidthButton: true,
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
                                    'Signing in...',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  GFButton(
                    onPressed: _loading ? null : _forgotPassword,
                    type: GFButtonType.transparent,
                    text: 'Forgot password?',
                    textStyle: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),
                  Divider(
                    color: Colors.white.withOpacity(0.15),
                    thickness: 1,
                    height: 40,
                  ),

                  // Register prompt
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.75),
                      ),
                      children: const [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Register',
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

          // Back button (Cupertino style)
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 4,
            child: GFIconButton(
              color: Colors.white.withOpacity(0.12),
              size: GFSize.SMALL,
              shape: GFIconButtonShape.circle,
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),

          // Fullscreen loader overlay (optional visual emphasis)
          if (_loading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
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
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
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
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Colors.black87,
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

  @override
  Widget build(BuildContext context) {
    final emailValidator = ValidationBuilder()
        .minLength(3, 'Too short')
        .email('Invalid email')
        .build();
    final passwordValidator =
        ValidationBuilder().minLength(6, 'Min 6 chars').build();

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: const Color(0xFF8CCBFF),
            decoration: _decoration(
              label: 'Email',
              icon: CupertinoIcons.mail,
            ),
            validator: (v) => emailValidator(v),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: passwordCtrl,
            obscureText: obscure,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: const Color(0xFF8CCBFF),
            decoration: _decoration(
              label: 'Password',
              icon: CupertinoIcons.lock,
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
      fillColor: Colors.white.withOpacity(0.10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.18),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF8CCBFF),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// Reusable brand header (same style as welcome)
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
      shaderCallback: (rect) => gradient.createShader(rect),
      child: Text(text, style: style),
    );
  }
}