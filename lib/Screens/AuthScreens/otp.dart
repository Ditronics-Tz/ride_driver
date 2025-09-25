import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:getwidget/getwidget.dart';
import '../../core/theme.dart'; // Add this import
import '../../core/network/api_exceptions.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneMasked; // e.g. "+255 ....."
  const OtpScreen({super.key, this.phoneMasked = '+255 .....'});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int _otpLength = 4;
  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  int _secondsLeft = 30;
  Timer? _timer;
  PendingOtp? _pending;
  bool _isProgrammaticChange = false;

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
    _pending = ref.read(authControllerProvider).pendingOtp ?? _pending;
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
    if (_isProgrammaticChange) {
      return;
    }

    final sanitized = value.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '');

    if (sanitized != value) {
      _isProgrammaticChange = true;
      _controllers[index].value = TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(
          offset: sanitized.isEmpty
              ? 0
              : sanitized.length > 1
                  ? 1
                  : sanitized.length,
        ),
      );
      _isProgrammaticChange = false;
      if (sanitized.isEmpty) {
        setState(() {});
        return;
      }
    }

    if (sanitized.isEmpty) {
      setState(() {});
      return;
    }

    if (sanitized.length > 1) {
      _applyPastedInput(index, sanitized);
    } else {
      if (_controllers[index].text != sanitized) {
        _isProgrammaticChange = true;
        _controllers[index].value = TextEditingValue(
          text: sanitized,
          selection: const TextSelection.collapsed(offset: 1),
        );
        _isProgrammaticChange = false;
      }
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    setState(() {});
  }

  void _applyPastedInput(int startIndex, String value) {
    if (value.isEmpty) {
      return;
    }

    final maxChars = math.min(value.length, _otpLength);
    final uppercase = value.substring(0, maxChars).toUpperCase();

    if (uppercase.length >= _otpLength) {
      _setFullCode(uppercase.substring(0, _otpLength));
      return;
    }

    final availableSlots = math.max(0, _otpLength - startIndex);
    if (availableSlots == 0) {
      return;
    }
    final trimmedLength = math.min(uppercase.length, availableSlots);
    final trimmed = uppercase.substring(0, trimmedLength);

    _isProgrammaticChange = true;
    var idx = startIndex;
    for (final char in trimmed.split('')) {
      if (idx >= _otpLength) break;
      _controllers[idx].value = TextEditingValue(
        text: char,
        selection: const TextSelection.collapsed(offset: 1),
      );
      idx++;
    }
    _isProgrammaticChange = false;

    if (idx < _otpLength) {
      _focusNodes[idx].requestFocus();
    } else {
      _focusNodes[_otpLength - 1].unfocus();
    }
  }

  void _setFullCode(String code) {
    final chars = code.split('');
    _isProgrammaticChange = true;
    for (var i = 0; i < _otpLength; i++) {
      _controllers[i].value = TextEditingValue(
        text: chars[i],
        selection: const TextSelection.collapsed(offset: 1),
      );
    }
    _isProgrammaticChange = false;
    _focusNodes[_otpLength - 1].unfocus();
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
      _controllers.map((c) => c.text.toUpperCase()).join();

  bool get _isComplete =>
      _enteredCode.length == _otpLength &&
      _enteredCode.split('').every((ch) => ch.trim().isNotEmpty);

  Future<void> _submit() async {
    if (!_isComplete) return;
    final pending = ref.read(authControllerProvider).pendingOtp ?? _pending;
    if (pending == null) {
      _showSnack('No OTP challenge found. Please login again.', success: false);
      return;
    }

    FocusScope.of(context).unfocus();
    final controller = ref.read(authControllerProvider.notifier);

    try {
      final res = await controller.verifyOtp(_enteredCode);
      if (!mounted) return;

      _showSnack(res.message.isNotEmpty ? res.message : 'OTP verified successfully');
      setState(() => _pending = null);

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, success: false);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Verification failed. Please try again.', success: false);
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    final controller = ref.read(authControllerProvider.notifier);
    try {
      final message = await controller.resendOtp();
      if (!mounted) return;
      _showSnack(message);
      _startCountdown();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, success: false);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to resend OTP. Please try again.', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final pending = authState.pendingOtp ?? _pending;
    final contactLabel = pending?.maskedContact ?? widget.phoneMasked;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient, // Use theme gradient
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
                padding: const EdgeInsets.all(24),
                borderRadius: BorderRadius.circular(32),
                color: AppColors.backgroundLight, // Use theme color
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
                      'We have sent an OTP on a given Number\n$contactLabel',
                      style: gText(
                        15,
                        FontWeight.w500,
                        color: AppColors.textPrimary, // Use theme color
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Enter OTP code',
                      style: gText(
                        15.5,
                        FontWeight.w600,
                        color: AppColors.textPrimary, // Use theme color
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
                          color: AppColors.textPrimary, // Use theme color
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
                                  color:
                                      AppColors.primaryBlue, // Use theme color
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
                        onPressed: _isComplete && !isLoading ? _submit : null,
                        size: GFSize.LARGE,
                        color: AppColors.primaryBlue, // Use theme color
                        elevation: _isComplete ? 6 : 2,
                        shape: GFButtonShape.pills,
                        fullWidthButton: true,
                        textStyle: gText(18, FontWeight.w600),
                        child: isLoading
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
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GFAvatar(
                          backgroundColor:
                              AppColors.primaryBlue, // Use theme color
                          radius: 8,
                          child: const Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Your trusted ride partner',
                            textAlign: TextAlign.center,
                            style: gText(
                              15,
                              FontWeight.w700,
                              color: AppColors.textPrimary, // Use theme color
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GFAvatar(
                          backgroundColor:
                              AppColors.primaryBlue, // Use theme color
                          radius: 8,
                          child: const Icon(
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
                          color: AppColors.textPrimary.withOpacity(
                            0.85,
                          ), // Use theme color
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
    final title = gText(
      28,
      FontWeight.w700,
      color: AppColors.textPrimary,
    ); // Use theme color
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'OTP',
            style: title.copyWith(
              color: AppColors.primaryBlue,
            ), // Use theme color
          ),
          TextSpan(text: ' verification', style: title),
        ],
      ),
    );
  }

  void _showSnack(String message, {bool success = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: gText(16, FontWeight.w600, color: Colors.white),
          ),
          backgroundColor:
              success ? AppColors.primaryBlueDarker : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
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
    final borderColor = AppColors.primaryBlue; // Use theme color
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
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
                ],
                enableSuggestions: false,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                maxLength: 1,
                style: widget.textBuilder(
                  28,
                  FontWeight.w700,
                  color: AppColors.textDark, // Use theme color
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
      color: AppColors.textDark, // Use theme color
    );
    final subtitleStyle = textBuilder(
      14,
      FontWeight.w500,
      color: AppColors.textSecondary, // Use theme color
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
                        color: AppColors.primaryBlue, // Use theme color
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
          backgroundColor: AppColors.primaryBlue.withOpacity(
            0.1,
          ), // Use theme color
          radius: 25,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.car_detailed,
                size: 24,
                color: AppColors.primaryBlue, // Use theme color
              ),
              const SizedBox(height: 2),
              Text(
                'Ride',
                style: textBuilder(
                  10,
                  FontWeight.w600,
                  color: AppColors.primaryBlue, // Use theme color
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
