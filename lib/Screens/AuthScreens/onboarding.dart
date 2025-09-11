import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressCtrl = TextEditingController();
  final _driverLicenseCtrl = TextEditingController();
  final _nidaCtrl = TextEditingController();          // National ID
  final _carPlateCtrl = TextEditingController();

  bool _loading = false;
  bool _carPhotoAdded = false;
  bool _idPhotoAdded = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _driverLicenseCtrl.dispose();
    _nidaCtrl.dispose();
    _carPlateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reuse gradient + font style (no car background IMAGE per requirement)
    const double fieldSpacing = 14;
    const double borderRadius = 10;
    final baseLabelStyle = GoogleFonts.inter(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF2F3B52),
      letterSpacing: 0.15,
    );

    InputDecoration deco(String label, {IconData? icon}) {
      return InputDecoration(
        labelText: label,
        prefixIcon: icon == null
            ? null
            : Icon(icon, size: 20, color: const Color(0xFF4A90E2)),
        labelStyle: baseLabelStyle,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Color(0xFFB7C6DB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background (no car image)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0C3C85), Color(0xFF1656B8), Color(0xFF1C6DD9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Soft overlay card area scrollable
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OnboardingHeader(),
                    const SizedBox(height: 28),
                    Text(
                      'Please enter the details below to continue',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _addressCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: deco('Address', icon: CupertinoIcons.location),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: fieldSpacing),
                            TextFormField(
                              controller: _driverLicenseCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: deco('Driver License Number',
                                  icon: CupertinoIcons.doc_text),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: fieldSpacing),
                            TextFormField(
                              controller: _nidaCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: deco('NIDA Number',
                                  icon: CupertinoIcons.person_badge_plus),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (v.length < 6) return 'Too short';
                                return null;
                              },
                            ),
                            const SizedBox(height: fieldSpacing),
                            TextFormField(
                              controller: _carPlateCtrl,
                              textCapitalization: TextCapitalization.characters,
                              textInputAction: TextInputAction.done,
                              decoration: deco('Car Plate Number',
                                  icon: CupertinoIcons.car_detailed),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 20),
                            _PhotoPickerRow(
                              label: 'Car Photo',
                              added: _carPhotoAdded,
                              onTap: () {
                                setState(() => _carPhotoAdded = true);
                              },
                            ),
                            const SizedBox(height: 14),
                            _PhotoPickerRow(
                              label: 'ID Photo',
                              added: _idPhotoAdded,
                              onTap: () {
                                setState(() => _idPhotoAdded = true);
                              },
                            ),
                            const SizedBox(height: 26),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2566D3),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _loading ? null : _submit,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _loading ? 'Please wait...' : 'Continue',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      CupertinoIcons.arrow_right,
                                      size: 19,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Your trusted ride partner',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Trusted by Thousands of Drivers',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.90),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          if (_loading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
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
    if (!_carPhotoAdded || !_idPhotoAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add both photos',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
          'Onboarding submitted (placeholder)',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF123A91),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate to home or next flow (placeholder)
    // Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
}

class _OnboardingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.inter(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      height: 1.05,
      color: Colors.white,
    );
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
            decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            CupertinoIcons.car_detailed,
            size: 34,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Text('RideApp', style: titleStyle),
      ],
    );
  }
}

class _PhotoPickerRow extends StatelessWidget {
  final String label;
  final bool added;
  final VoidCallback onTap;
  const _PhotoPickerRow({
    required this.label,
    required this.added,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.inter(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2F3B52),
    );
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: added ? const Color(0xFF4A90E2) : const Color(0xFFB7C6DB),
            width: 1.1,
          ),
          boxShadow: added
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              added
                  ? CupertinoIcons.checkmark_alt_circle_fill
                  : CupertinoIcons.cloud_upload,
              size: 20,
              color: added ? const Color(0xFF2566D3) : const Color(0xFF4A90E2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                added ? '$label Added' : '$label (Tap to add)',
                style: textStyle,
              ),
            ),
            if (!added)
              Icon(
                CupertinoIcons.arrow_right,
                size: 18,
                color: const Color(0xFF4A90E2).withOpacity(0.75),
              ),
          ],
        ),
      ),
    );
  }
}