import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpScreen extends StatefulWidget {
  final String phoneMasked; // e.g. "+255 ....."
  const OtpScreen({
    super.key,
    this.phoneMasked = '+255 .....',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 4;
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _submitting = false;
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // If user pasted multiple characters, keep only first
      _controllers[index].text = value[0];
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    setState(() {}); // update button enabled state
  }

  void _onKey(RawKeyEvent event, int index) {
    // Handle backspace navigation
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].text = '';
    }
  }

  String get _enteredCode =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete =>
      _enteredCode.length == _otpLength &&
      _enteredCode.split('').every((ch) => ch.trim().isNotEmpty);

  Future<void> _submit() async {
    if (!_isComplete || _submitting) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate verify
    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'OTP $_enteredCode verified (placeholder)',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF123A91),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // TODO: Navigate to next flow (e.g., onboarding or home)
    // Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    // Simulate resend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'OTP resent (placeholder)',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF123A91),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF2563EB), // Edge / border color in screenshot
      body: SafeArea(
        child: Center(
          child: Container(
            // Create the inner light panel
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F2FF),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBrandHeader(),
                const SizedBox(height: 30),
                _buildOtpTitle(),
                const SizedBox(height: 10),
                Text(
                  'We have sent an OTP on a given Number\n${widget.phoneMasked}',
                  style: GoogleFonts.inter(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1C2A3A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Enter OTP code',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2A3A),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(_otpLength, (i) {
                    return Padding(
                      padding: EdgeInsets.only(right: i == _otpLength - 1 ? 0 : 12),
                      child: _OtpBox(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        onChanged: (v) => _onChanged(i, v),
                        onKey: (e) => _onKey(e, i),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF1C2A3A),
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: "Don't receive an OTP? "),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: _resend,
                          child: Text(
                            _secondsLeft > 0
                                ? 'Resend (${_secondsLeft}s)'
                                : 'Resend',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1D64D9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2566D3),
                      foregroundColor: Colors.white,
                      elevation: _isComplete ? 3 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    onPressed: _isComplete && !_submitting ? _submit : null,
                    child: _submitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Verifying...',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Continue'),
                              SizedBox(width: 8),
                              Icon(
                                CupertinoIcons.arrow_right,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
                const Spacer(),
                _BottomFooter(height: size.height * 0.16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpTitle() {
    final base = GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: const Color(0xFF1C2A3A),
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'OTP',
            style: base.copyWith(color: const Color(0xFF1D64D9)),
          ),
          TextSpan(text: ' verification', style: base),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKey;
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKey,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFF1D64D9);
    return SizedBox(
      width: 48,
      height: 48,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: onKey,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          maxLength: 1,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0E2033),
          ),
          cursorColor: borderColor,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor.withOpacity(0.55), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 1.6),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TopBrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final welcomeStyle = GoogleFonts.inter(
      fontSize: 15.5,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF0E2033),
      letterSpacing: -0.2,
    );
    final subtitleStyle = GoogleFonts.inter(
      fontSize: 12.2,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF2F3B52),
      height: 1.25,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: welcomeStyle,
                  children: [
                    const TextSpan(text: 'Welcome to '),
                    TextSpan(
                      text: 'eDriver',
                      style: welcomeStyle.copyWith(color: const Color(0xFF1D64D9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'All our drivers are fully verified.',
                style: subtitleStyle,
              ),
            ],
          ),
        ),
        Column(
          children: [
            Icon(
              CupertinoIcons.car_detailed,
              size: 30,
              color: const Color(0xFF1D64D9),
            ),
            const SizedBox(height: 4),
            Text(
              'eDriver',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D64D9),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _BottomFooter extends StatelessWidget {
  final double height;
  const _BottomFooter({required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(26),
        bottomRight: Radius.circular(26),
      ),
      child: Container(
        width: double.infinity,
        height: height,
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Your trusted ride partner',
              style: GoogleFonts.inter(
                fontSize: 13.2,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C2A3A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Trusted by Thousands of Drivers',
              style: GoogleFonts.inter(
                fontSize: 12.2,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C2A3A).withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}