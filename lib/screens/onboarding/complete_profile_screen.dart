import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'create_account_screen.dart';
import 'book_genre_screen.dart';
import '../../services/firebase_service.dart';
import '../../main.dart' show firebaseService, authService;

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _profileImageUrl;
  DateTime? _selectedDate;
  final _imagePicker = ImagePicker();

  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final User? currentUser = authService.currentUser;
      
      if (currentUser == null) {
        _showErrorDialog('User session not found. Please try signing in again.');
        return;
      }

      // Prepare profile data
      final Map<String, dynamic> profileData = {
        'full_name': _fullNameController.text.trim(),
        'date_of_birth': _selectedDate?.toIso8601String(),
        'country': _countryController.text.trim(),
        'profile_image_url': _profileImageUrl,
        'onboarding_step': 'profile_completed',
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update user profile in Firestore
      await firebaseService.setDocument(
        'users',
        currentUser.uid,
        profileData,
      );

      // Update Firebase Auth profile
      await currentUser.updateDisplayName(_fullNameController.text.trim());
      if (_profileImageUrl != null) {
        await currentUser.updatePhotoURL(_profileImageUrl);
      }

      // Navigate to book genre screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookGenreScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to save profile. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return;

      setState(() => _isLoading = true);

      // Get current user
      final User? currentUser = authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Get the app's local storage directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'profile_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String localPath = path.join(appDir.path, fileName);

      // Copy the image to local storage
      final File localImage = File(localPath);
      await localImage.writeAsBytes(await image.readAsBytes());

      // Delete old image if exists
      if (_profileImageUrl != null) {
        try {
          final File oldImage = File(_profileImageUrl!);
          if (await oldImage.exists()) {
            await oldImage.delete();
          }
        } catch (e) {
          print('Failed to delete old image: $e');
        }
      }

      if (mounted) {
        setState(() {
          _profileImageUrl = localPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print('Error saving image: $e');
        _showErrorDialog('Failed to save image. Please try again.');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF7A00),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  Future<void> _selectCountry() async {
    // For now, we'll just show a simple dialog with a few countries
    final String? selectedCountry = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Country',
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                'United States',
                'United Kingdom',
                'Canada',
                'Australia',
                'Germany',
                'France',
                'Japan',
                'India',
                'Brazil',
                'Other'
              ].map((String country) {
                return ListTile(
                  title: Text(
                    country,
                    style: GoogleFonts.urbanist(),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(country);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedCountry != null) {
      setState(() {
        _countryController.text = selectedCountry;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.urbanist(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.urbanist(
                color: const Color(0xFFFF7A00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/library.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 60,
                  bottom: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete\nYour Profile',
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Only you can see your personal data.\nNo one else will be able to see it.',
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.012,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            height: screenHeight,
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      _buildBackButton(context),
                      const SizedBox(width: 16),
                      Expanded(child: _buildProgressBar()),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: _buildForm(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildBackButton(context),
                const SizedBox(width: 16),
                Expanded(child: _buildProgressBar()),
              ],
            ),
            const SizedBox(height: 48),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: _isLoading ? null : () => Navigator.pop(context),
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: 0.8,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A00), Color(0xFFFF9D42)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Your Profile 👩‍💻',
            style: GoogleFonts.urbanist(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Don't worry, only you can see your personal data. No one else will be able to see it.",
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    image: _profileImageUrl != null
                        ? DecorationImage(
                            image: FileImage(File(_profileImageUrl!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _profileImageUrl == null
                      ? Icon(
                          Icons.person_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A00),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            validator: (value) => _validateRequired(value, 'Full name'),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _dobController,
            label: 'Date of Birth',
            readOnly: true,
            onTap: () => _selectDate(context),
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
            validator: (value) => _validateRequired(value, 'Date of birth'),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _countryController,
            label: 'Country',
            readOnly: true,
            onTap: _selectCountry,
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
            validator: (value) => _validateRequired(value, 'Country'),
          ),
          const SizedBox(height: 40),
          _buildContinueButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          enabled: !_isLoading,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            suffixIcon: suffixIcon != null
                ? IconTheme(
                    data: const IconThemeData(
                      color: Color(0xFFFF7A00),
                      size: 20,
                    ),
                    child: suffixIcon,
                  )
                : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF7A00)),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveProfileData,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF7A00),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        minimumSize: const Size(double.infinity, 56),
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      child: _isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
              ),
            )
          : Text(
              'Continue',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            image: _profileImageUrl != null
                ? DecorationImage(
                    image: FileImage(File(_profileImageUrl!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _profileImageUrl == null
              ? Icon(Icons.person, size: 60, color: Colors.grey[400])
              : null,
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isLoading ? null : _pickImage,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}