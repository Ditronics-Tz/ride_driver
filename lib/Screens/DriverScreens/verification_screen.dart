import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nidaController = TextEditingController();
  final _addressController = TextEditingController();
  final _carNameController = TextEditingController();
  final _plateNumberController =
      TextEditingController(); // Added plate number controller

  File? _profileImage;
  File? _idImage;
  File? _carImage;

  String? _selectedCarType;
  int? _selectedSeats;

  final List<String> _carTypes = ['Sedan', 'SUV', 'Pickup', 'Van', 'Coupe'];

  final List<int> _seatOptions = [2, 3, 4, 5, 6, 7];

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'profile':
            _profileImage = File(pickedFile.path);
            break;
          case 'id':
            _idImage = File(pickedFile.path);
            break;
          case 'car':
            _carImage = File(pickedFile.path);
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: Text(
          'Driver Verification',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 15),

              _buildTextInput(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 15),

              _buildTextInput(
                controller: _nidaController,
                label: 'NIDA Number',
                hint: 'Enter your NIDA number',
                icon: Icons.credit_card,
              ),

              const SizedBox(height: 15),

              _buildTextInput(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter your full address',
                icon: Icons.location_on,
                maxLines: 1,
              ),

              const SizedBox(height: 20),

              // Photo Upload Section
              _buildSectionHeader('Photo Uploads'),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildImageUpload(
                      'Profile Photo',
                      _profileImage,
                      () => _pickImage('profile'),
                      Icons.person,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildImageUpload(
                      'ID Photo',
                      _idImage,
                      () => _pickImage('id'),
                      Icons.badge,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              _buildImageUpload(
                'Car Photo',
                _carImage,
                () => _pickImage('car'),
                Icons.directions_car,
                isFullWidth: true,
              ),

              const SizedBox(height: 30),

              // Vehicle Information Section
              _buildSectionHeader('Vehicle Information'),
              const SizedBox(height: 15),

              _buildTextInput(
                controller: _carNameController,
                label: 'Car Name/Model',
                hint: 'e.g., Toyota Corolla 2020',
                icon: Icons.directions_car,
              ),

              const SizedBox(height: 15),

              // Plate Number field (added)
              _buildTextInput(
                controller: _plateNumberController,
                label: 'Plate Number',
                hint: 'e.g., T123ABC',
                icon: Icons.pin,
              ),

              const SizedBox(height: 15),

              // Car Type Dropdown
              _buildDropdown(),

              const SizedBox(height: 15),

              // Seats Dropdown
              _buildSeatsDropdown(),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 22),
                      const SizedBox(width: 8),
                      Text('Submit Verification', style: AppTextStyles.button),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.headingMedium.copyWith(fontSize: 18)),
      ],
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCarType,
      decoration: InputDecoration(
        labelText: 'Car Type',
        prefixIcon: const Icon(Icons.category, color: AppColors.primaryBlue),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      items: _carTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type, style: AppTextStyles.bodyMedium),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCarType = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a car type';
        }
        return null;
      },
    );
  }

  Widget _buildSeatsDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedSeats,
      decoration: InputDecoration(
        labelText: 'Number of Seats',
        prefixIcon: const Icon(
          Icons.airline_seat_recline_normal,
          color: AppColors.primaryBlue,
        ),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      items: _seatOptions.map((int seats) {
        return DropdownMenuItem<int>(
          value: seats,
          child: Text(
            '$seats ${seats == 1 ? 'Seat' : 'Seats'}',
            style: AppTextStyles.bodyMedium,
          ),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedSeats = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select number of seats';
        }
        return null;
      },
    );
  }

  Widget _buildImageUpload(
    String title,
    File? image,
    VoidCallback onTap,
    IconData icon, {
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isFullWidth ? 120 : 100,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null
                ? AppColors.success
                : AppColors.primaryBlue.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: AppColors.primaryBlue),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to upload',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _submitVerification() {
    if (_formKey.currentState!.validate()) {
      // Check if all required images are uploaded
      if (_profileImage == null || _idImage == null || _carImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please upload all required photos',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textWhite,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Show success message and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification submitted successfully!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to home or pending screen
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nidaController.dispose();
    _addressController.dispose();
    _carNameController.dispose();
    _plateNumberController
        .dispose(); // Added dispose for plate number controller
    super.dispose();
  }
}
