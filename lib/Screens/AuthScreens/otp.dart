import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:getwidget/getwidget.dart';

class OtpScreen extends StatefulWidget {
  final String phoneMasked; // e.g. "+255 ....."
  const OtpScreen({super.key, this.phoneMasked = '+255 .....'});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 4;
  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  bool _submitting = false;
  int _secondsLeft = 30;
  Timer? _timer;

  TextStyle gText(
    double size,
    FontWeight weight, {
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
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

    // Navigate to main navigation
    Navigator.of(context).pushReplacementNamed('/main');
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
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset + 16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Center(
              child: GFCard(
                margin: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                padding: const EdgeInsets.all(24), // Use consistent padding
                borderRadius: BorderRadius.circular(32),
                color: const Color(0xFFF0F5FF),
                elevation: 10,
                boxFit: BoxFit.cover,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBrandHeader(textBuilder: gText),
                    const SizedBox(height: 30),
                    _buildOtpTitle(),
                    const SizedBox(height: 12),
                    Text(
                      'We have sent an OTP on a given Number\n${widget.phoneMasked}',
                      style: gText(
                        15,
                        FontWeight.w500,
                        color: const Color(0xFF1C2A3A),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Enter OTP code',
                      style: gText(
                        15.5,
                        FontWeight.w600,
                        color: const Color(0xFF1C2A3A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_otpLength, (i) {
                        return _OtpBox(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          onChanged: (v) => _onChanged(i, v),
                          onKey: (e) => _onKey(e, i),
                          textBuilder: gText,
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: gText(
                          15,
                          FontWeight.w500,
                          color: const Color(0xFF1C2A3A),
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
                                style: gText(
                                  15,
                                  FontWeight.w600,
                                  color: const Color(0xFF1D64D9),
                                ),
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
                      child: GFButton(
                        onPressed: _isComplete && !_submitting ? _submit : null,
                        size: GFSize.LARGE,
                        color: const Color(0xFF2566D3),
                        elevation: _isComplete ? 6 : 2,
                        shape: GFButtonShape.pills,
                        fullWidthButton: true,
                        textStyle: gText(18, FontWeight.w600),
                        child: _submitting
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
                                    'Verifying...',
                                    style: gText(
                                      17,
                                      FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: gText(
                                      18,
                                      FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    CupertinoIcons.arrow_right,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32), // Spacing before footer
                    // --- Footer content moved here ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const GFAvatar(
                          backgroundColor: Color(0xFF1D64D9),
                          radius: 8,
                          child: Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          // Keep Flexible to handle smaller screens
                          child: Text(
                            'Your trusted ride partner',
                            textAlign: TextAlign.center,
                            style: gText(
                              15,
                              FontWeight.w700,
                              color: const Color(0xFF1C2A3A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const GFAvatar(
                          backgroundColor: Color(0xFF1D64D9),
                          radius: 8,
                          child: Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Trusted by Thousands of Drivers',
                        style: gText(
                          14,
                          FontWeight.w500,
                          color: const Color(0xFF1C2A3A).withOpacity(0.85),
                        ),
                      ),
                    ),
                  ],
                ),
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
          TextSpan(
            text: 'OTP',
            style: title.copyWith(color: const Color(0xFF1D64D9)),
          ),
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
  final TextStyle Function(
    double,
    FontWeight, {
    Color? color,
    double? letterSpacing,
    double? height,
  })
  textBuilder;

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

class _OtpBoxState extends State<_OtpBox> with SingleTickerProviderStateMixin {
  late final FocusNode _keyboardFocusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode = FocusNode(debugLabel: '_OtpBox RawKeyboardListener');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _keyboardFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted &&
        !_animationController.isCompleted &&
        !_animationController.isDismissed) {
      if (widget.focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFF1D64D9);
    final hasValue = widget.controller.text.isNotEmpty;

    // Make the box size responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize =
        (screenWidth - 48 - 48 - (12 * 3)) / 4; // Paddings and spacing

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), // Smoother radius
              color: Colors.white,
              border: Border.all(
                color: widget.focusNode.hasFocus
                    ? borderColor
                    : hasValue
                    ? borderColor.withOpacity(0.7)
                    : borderColor.withOpacity(0.3),
                width: widget.focusNode.hasFocus ? 2.0 : 1.5,
              ),
              boxShadow: [
                if (widget.focusNode.hasFocus || hasValue)
                  BoxShadow(
                    color: borderColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
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
                style: widget.textBuilder(
                  28,
                  FontWeight.w700,
                  color: const Color(0xFF0E2033),
                ),
                cursorColor: borderColor,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: widget.onChanged,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBrandHeader extends StatelessWidget {
  final TextStyle Function(
    double,
    FontWeight, {
    Color? color,
    double? letterSpacing,
    double? height,
  })
  textBuilder;

  const _TopBrandHeader({required this.textBuilder});

  @override
  Widget build(BuildContext context) {
    final welcomeStyle = textBuilder(
      17.5,
      FontWeight.w600,
      color: const Color(0xFF0E2033),
    );
    final subtitleStyle = textBuilder(
      14,
      FontWeight.w500,
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
                      text: 'Ride',
                      style: welcomeStyle.copyWith(
                        color: const Color(0xFF1D64D9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text('All our drivers are fully verified.', style: subtitleStyle),
            ],
          ),
        ),
        GFAvatar(
          backgroundColor: const Color(0xFF1D64D9).withOpacity(0.1),
          radius: 25,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.car_detailed,
                size: 24,
                color: Color(0xFF1D64D9),
              ),
              const SizedBox(height: 2),
              Text(
                'Ride',
                style: textBuilder(
                  10,
                  FontWeight.w600,
                  color: const Color(0xFF1D64D9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
