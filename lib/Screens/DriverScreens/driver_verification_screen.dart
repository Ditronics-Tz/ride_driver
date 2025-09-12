import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:form_validator/form_validator.dart';
import 'dart:io';
import '../../providers/driver_provider.dart';

class DriverVerificationScreen extends ConsumerStatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  ConsumerState<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState
    extends ConsumerState<DriverVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _driverLicenseCtrl = TextEditingController();
  final _nidaCtrl = TextEditingController();
  final _carPlateCtrl = TextEditingController();
  final _carSeatCtrl = TextEditingController();

  // Images
  File? _carPhoto;
  File? _idPhoto;

  @override
  void initState() {
    super.initState();
    // Pre-populate form if driver info exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverInfo = ref.read(driverInfoProvider);
      if (driverInfo.fullName != null) {
        _fullNameCtrl.text = driverInfo.fullName!;
        _addressCtrl.text = driverInfo.address ?? '';
        _driverLicenseCtrl.text = driverInfo.driverLicenseNumber ?? '';
        _nidaCtrl.text = driverInfo.nidaNumber ?? '';
        _carPlateCtrl.text = driverInfo.carPlateNumber ?? '';
        _carSeatCtrl.text = driverInfo.carSeats?.toString() ?? '';
      }
    });
  }

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
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          if (isCarPhoto) {
            _carPhoto = File(picked.path);
          } else {
            _idPhoto = File(picked.path);
          }
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: message,
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success',
          message: message,
          contentType: ContentType.success,
        ),
      ),
    );
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackbar('Please fill all required fields');
      return;
    }

    if (_carPhoto == null || _idPhoto == null) {
      _showErrorSnackbar('Please upload both car photo and ID photo');
      return;
    }

    try {
      await ref
          .read(driverProvider.notifier)
          .submitVerification(
            fullName: _fullNameCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            driverLicenseNumber: _driverLicenseCtrl.text.trim(),
            nidaNumber: _nidaCtrl.text.trim(),
            carPlateNumber: _carPlateCtrl.text.trim().toUpperCase(),
            carSeats: int.parse(_carSeatCtrl.text.trim()),
            carPhotoPath: _carPhoto!.path,
            idPhotoPath: _idPhoto!.path,
          );

      _showSuccessSnackbar('Verification documents submitted successfully!');
    } catch (e) {
      _showErrorSnackbar('Failed to submit verification: $e');
    }
  }

  void _mockStatusUpdate() {
    // For testing - cycle through verification statuses
    final currentStatus = ref.read(verificationStatusProvider);
    VerificationStatus nextStatus;
    String message;

    switch (currentStatus) {
      case VerificationStatus.notSubmitted:
      case VerificationStatus.pending:
        nextStatus = VerificationStatus.approved;
        message = 'Congratulations! Your documents have been approved.';
        break;
      case VerificationStatus.approved:
        nextStatus = VerificationStatus.rejected;
        message = 'Some documents need correction. Please resubmit.';
        break;
      case VerificationStatus.rejected:
        nextStatus = VerificationStatus.pending;
        message = 'Documents resubmitted and under review.';
        break;
    }

    ref
        .read(driverProvider.notifier)
        .mockVerificationUpdate(nextStatus, message);
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final isLoading = ref.watch(isDriverLoadingProvider);
    final verificationStatus = ref.watch(verificationStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Driver Verification',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        actions: [
          // Test button for cycling through verification statuses
          IconButton(
            onPressed: _mockStatusUpdate,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Test Status Update',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(driverProvider.notifier).checkVerificationStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _VerificationStatusCard(
                status: verificationStatus,
                message: driverState.driverInfo.verificationMessage,
                onRetry: verificationStatus == VerificationStatus.rejected
                    ? _submitVerification
                    : null,
              ),

              const SizedBox(height: 24),

              if (verificationStatus != VerificationStatus.approved) ...[
                // Form Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _CustomTextField(
                          controller: _fullNameCtrl,
                          label: 'Full Name',
                          icon: CupertinoIcons.person,
                          validator: ValidationBuilder()
                              .minLength(2, 'Too short')
                              .build(),
                        ),

                        const SizedBox(height: 16),

                        _CustomTextField(
                          controller: _addressCtrl,
                          label: 'Address',
                          icon: CupertinoIcons.location,
                          maxLines: 2,
                          validator: ValidationBuilder()
                              .minLength(10, 'Please provide complete address')
                              .build(),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'License Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _CustomTextField(
                          controller: _driverLicenseCtrl,
                          label: 'Driver License Number',
                          icon: CupertinoIcons.doc_text,
                          validator: ValidationBuilder()
                              .minLength(6, 'Invalid license number')
                              .build(),
                        ),

                        const SizedBox(height: 16),

                        _CustomTextField(
                          controller: _nidaCtrl,
                          label: 'NIDA Number',
                          icon: CupertinoIcons.person_badge_plus,
                          validator: ValidationBuilder()
                              .minLength(20, 'NIDA number must be 20 digits')
                              .maxLength(20, 'NIDA number must be 20 digits')
                              .build(),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Vehicle Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _CustomTextField(
                          controller: _carPlateCtrl,
                          label: 'Car Plate Number',
                          icon: CupertinoIcons.car_detailed,
                          textCapitalization: TextCapitalization.characters,
                          validator: ValidationBuilder()
                              .minLength(6, 'Invalid plate number')
                              .build(),
                        ),

                        const SizedBox(height: 16),

                        _CustomTextField(
                          controller: _carSeatCtrl,
                          label: 'Number of Seats (Available for passengers)',
                          icon: CupertinoIcons.person_2,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final seats = int.tryParse(value);
                            if (seats == null || seats < 1 || seats > 4) {
                              return 'Must be between 1 and 4 seats';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Document Upload',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _PhotoUploadCard(
                          title: 'Car Photo',
                          subtitle: 'Clear photo of your vehicle',
                          image: _carPhoto,
                          onTap: () => _pickImage(true),
                        ),

                        const SizedBox(height: 16),

                        _PhotoUploadCard(
                          title: 'Driver ID Photo',
                          subtitle: 'Photo of your driver\'s license or ID',
                          image: _idPhoto,
                          onTap: () => _pickImage(false),
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isLoading ? null : _submitVerification,
                            child: isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Submitting...',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        verificationStatus ==
                                                VerificationStatus.rejected
                                            ? 'Resubmit Documents'
                                            : 'Submit for Verification',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        CupertinoIcons.checkmark_alt,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationStatusCard extends StatelessWidget {
  final VerificationStatus status;
  final String? message;
  final VoidCallback? onRetry;

  const _VerificationStatusCard({
    required this.status,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;
    String title;
    Color textColor;

    switch (status) {
      case VerificationStatus.notSubmitted:
        backgroundColor = const Color(0xFFF3F4F6);
        iconColor = const Color(0xFF6B7280);
        icon = CupertinoIcons.doc_text;
        title = 'Verification Required';
        textColor = const Color(0xFF374151);
        break;
      case VerificationStatus.pending:
        backgroundColor = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        icon = CupertinoIcons.clock;
        title = 'Under Review';
        textColor = const Color(0xFF92400E);
        break;
      case VerificationStatus.approved:
        backgroundColor = const Color(0xFFD1FAE5);
        iconColor = const Color(0xFF059669);
        icon = CupertinoIcons.checkmark_alt_circle_fill;
        title = 'Approved';
        textColor = const Color(0xFF065F46);
        break;
      case VerificationStatus.rejected:
        backgroundColor = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFDC2626);
        icon = CupertinoIcons.xmark_circle_fill;
        title = 'Needs Attention';
        textColor = const Color(0xFF991B1B);
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        message!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (status == VerificationStatus.rejected && onRetry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: iconColor,
                  side: BorderSide(color: iconColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onRetry,
                icon: const Icon(CupertinoIcons.refresh, size: 18),
                label: Text(
                  'Resubmit Documents',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final int? maxLines;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textCapitalization,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        labelStyle: GoogleFonts.poppins(
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
      ),
    );
  }
}

class _PhotoUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final File? image;
  final VoidCallback onTap;

  const _PhotoUploadCard({
    required this.title,
    required this.subtitle,
    this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null
                ? const Color(0xFF10B981)
                : const Color(0xFFE5E7EB),
            width: image != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: image != null
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(image!, fit: BoxFit.cover),
                    )
                  : Icon(
                      CupertinoIcons.camera,
                      color: image != null
                          ? Colors.white
                          : const Color(0xFF6B7280),
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image != null ? 'Image uploaded successfully' : subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: image != null
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              image != null
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.camera,
              color: image != null
                  ? const Color(0xFF10B981)
                  : const Color(0xFF6B7280),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
