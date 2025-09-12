import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './otp.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _driverLicenseCtrl = TextEditingController();
  final _nidaCtrl = TextEditingController();
  final _carPlateCtrl = TextEditingController();
  final _carSeatCtrl = TextEditingController();

  bool _loading = false;
  File? _carPhoto;
  File? _idPhoto;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _addressCtrl.dispose();
    _driverLicenseCtrl.dispose();
    _nidaCtrl.dispose();
    _carPlateCtrl.dispose();
    _carSeatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCarPhoto) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isCarPhoto) {
          _carPhoto = File(picked.path);
        } else {
          _idPhoto = File(picked.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0C3C85),
                    Color(0xFF1656B8),
                    Color(0xFF1C6DD9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
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
                            controller: _fullNameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: deco(
                              'Full Name',
                              icon: CupertinoIcons.person,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: fieldSpacing),
                          TextFormField(
                            controller: _addressCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: deco(
                              'Address',
                              icon: CupertinoIcons.location,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: fieldSpacing),
                          TextFormField(
                            controller: _driverLicenseCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: deco(
                              'Driver License Number',
                              icon: CupertinoIcons.doc_text,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: fieldSpacing),
                          TextFormField(
                            controller: _nidaCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: deco(
                              'NIDA Number',
                              icon: CupertinoIcons.person_badge_plus,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Required';
                              if (v.length < 6) return 'Too short';
                              return null;
                            },
                          ),
                          const SizedBox(height: fieldSpacing),
                          TextFormField(
                            controller: _carPlateCtrl,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.next,
                            decoration: deco(
                              'Car Plate Number',
                              icon: CupertinoIcons.car_detailed,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: fieldSpacing),
                          TextFormField(
                            controller: _carSeatCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            decoration: deco(
                              'Car Seat',
                              icon: CupertinoIcons.person_2,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Upload Documents',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2F3B52),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _PhotoPickerRow(
                            label: 'Car Photo',
                            added: _carPhoto != null,
                            onTap: () => _pickImage(true),
                            image: _carPhoto,
                          ),
                          const SizedBox(height: 14),
                          _PhotoPickerRow(
                            label: 'Driver ID Photo',
                            added: _idPhoto != null,
                            onTap: () => _pickImage(false),
                            image: _idPhoto,
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
    // Navigate to main navigation after onboarding completion
    Navigator.of(context).pushReplacementNamed('/main');
    return;
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
            border: Border.all(color: Colors.white.withOpacity(0.25)),
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
  final File? image;
  const _PhotoPickerRow({
    required this.label,
    required this.added,
    required this.onTap,
    this.image,
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
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            if (added && image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  image!,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(
                added
                    ? CupertinoIcons.checkmark_alt_circle_fill
                    : CupertinoIcons.cloud_upload,
                size: 20,
                color: added
                    ? const Color(0xFF2566D3)
                    : const Color(0xFF4A90E2),
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
