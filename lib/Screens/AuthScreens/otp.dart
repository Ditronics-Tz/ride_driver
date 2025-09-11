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

  TextStyle gText(double size, FontWeight weight,
      {Color? color, double? letterSpacing, double? height}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

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
    setState(() {});
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

  String get _enteredCode => _controllers.map((c) => c.text).join();

  bool get _isComplete =>
      _enteredCode.length == _otpLength &&
      _enteredCode.split('').every((ch) => ch.trim().isNotEmpty);

  Future<void> _submit() async {
    if (!_isComplete || _submitting) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'OTP $_enteredCode verified (placeholder)',
          style: gText(17, FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF123A91),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // TODO: Navigate to next flow
    // Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'OTP resent (placeholder)',
          style: gText(16, FontWeight.w500, color: Colors.white),
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset + 16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F2FF),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBrandHeader(textBuilder: gText),
                  const SizedBox(height: 30),
                  _buildOtpTitle(),
                  const SizedBox(height: 12),
                  Text(
                    'We have sent an OTP on a given Number\n${widget.phoneMasked}',
                    style: gText(16, FontWeight.w500,
                        color: const Color(0xFF1C2A3A), height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Enter OTP code',
                    style: gText(15.5, FontWeight.w600,
                        color: const Color(0xFF1C2A3A)),
                  ),
                  const SizedBox(height: 14),
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
                          textBuilder: gText,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: gText(15, FontWeight.w500,
                          color: const Color(0xFF1C2A3A)),
                      children: [
                        const TextSpan(text: "Don't receive an OTP? "),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: _resend,
                            child: Text(
                              _secondsLeft > 0 ? 'Resend (${_secondsLeft}s)' : 'Resend',
                              style: gText(15, FontWeight.w600,
                                  color: const Color(0xFF1D64D9)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2566D3),
                        foregroundColor: Colors.white,
                        elevation: _isComplete ? 3 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: gText(18, FontWeight.w600),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text('Verifying...', style: gText(17, FontWeight.w600)),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Continue', style: gText(18, FontWeight.w600)),
                                const SizedBox(width: 8),
                                const Icon(CupertinoIcons.arrow_right, size: 20),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _BottomFooter(height: size.height * 0.16, textBuilder: gText),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpTitle() {
    final title = gText(28, FontWeight.w700, color: const Color(0xFF1C2A3A));
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: 'OTP', style: title.copyWith(color: const Color(0xFF1D64D9))),
          TextSpan(text: ' verification', style: title),
        ],
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKey;
  final TextStyle Function(double, FontWeight,
      {Color? color, double? letterSpacing, double? height}) textBuilder;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKey,
    required this.textBuilder,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  late final FocusNode _keyboardFocusNode;

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode = FocusNode(debugLabel: '_OtpBox RawKeyboardListener');
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFF1D64D9);
    return SizedBox(
      width: 52,
      height: 52,
      child: RawKeyboardListener(
        focusNode: _keyboardFocusNode,
        onKey: widget.onKey,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          maxLength: 1,
          style: widget.textBuilder(24, FontWeight.w700, color: const Color(0xFF0E2033)),
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
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

class _TopBrandHeader extends StatelessWidget {
  final TextStyle Function(double, FontWeight,
      {Color? color, double? letterSpacing, double? height}) textBuilder;

  const _TopBrandHeader({required this.textBuilder});

  @override
  Widget build(BuildContext context) {
    final welcomeStyle =
        textBuilder(17.5, FontWeight.w600, color: const Color(0xFF0E2033));
    final subtitleStyle =
        textBuilder(14, FontWeight.w500, color: const Color(0xFF2F3B52), height: 1.25);

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
                      text: 'Ride',
                      style:
                          welcomeStyle.copyWith(color: const Color(0xFF1D64D9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text('All our drivers are fully verified.', style: subtitleStyle),
            ],
          ),
        ),
        Column(
          children: [
            const Icon(CupertinoIcons.car_detailed, size: 30, color: Color(0xFF1D64D9)),
            const SizedBox(height: 4),
            Text(
              'Ride',
              style: textBuilder(14.5, FontWeight.w600, color: const Color(0xFF1D64D9)),
            ),
          ],
        )
      ],
    );
  }
}

class _BottomFooter extends StatelessWidget {
  final double height;
  final TextStyle Function(double, FontWeight,
      {Color? color, double? letterSpacing, double? height}) textBuilder;

  const _BottomFooter({required this.height, required this.textBuilder});

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
              style:
                  textBuilder(15, FontWeight.w700, color: const Color(0xFF1C2A3A)),
            ),
            const SizedBox(height: 4),
            Text(
              'Trusted by Thousands of Drivers',
              style: textBuilder(14, FontWeight.w500,
                  color: const Color(0xFF1C2A3A).withOpacity(0.85)),
            ),
          ],
        ),
      ),
    );
  }
}