import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart'; // Ensure AppColors and other utils are accessible
import '../home/home_screen.dart'; // Import the HomeScreen

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({Key? key}) : super(key: key);

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController(text: 'password123');
  final TextEditingController _confirmPasswordController = TextEditingController(text: 'password123');

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onContinue() {
    // After setting the new password successfully, show the success dialog
    _showResetSuccessDialog();
  }

  void _showResetSuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4), // Dark overlay
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          children: [
            // Apply blur effect over entire screen
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon in a colored circle
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reset Password\nSuccessful!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your password has been successfully\nchanged.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                        // Navigate to HomeScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text(
                        'Go to Home',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: Colors.black87,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.urbanist(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          decoration: TextDecoration.none,
        ),
        children: const [
          TextSpan(text: 'Create New Password '),
          TextSpan(text: '🔐'),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      "Enter your new password. If you forget it, then you have to do forgot password.",
      style: GoogleFonts.urbanist(
        fontSize: 14,
        color: Colors.black54,
        height: 1.5,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
    String hintText = '••••••••••••',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primary,
              ),
              onPressed: onToggle,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        InkWell(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _rememberMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _rememberMe ? AppColors.primary : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: _rememberMe
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Remember me',
          style: GoogleFonts.urbanist(
            color: Colors.black87,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _onContinue,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Text(
        'Continue',
        style: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _buildBackButton(context),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 32),

              // Password field
              _buildTextFieldLabel("Password"),
              _buildPasswordField(
                controller: _passwordController,
                visible: _passwordVisible,
                onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
              ),
              const SizedBox(height: 16),

              // Confirm Password field
              _buildTextFieldLabel("Confirm Password"),
              _buildPasswordField(
                controller: _confirmPasswordController,
                visible: _confirmPasswordVisible,
                onToggle: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
              ),
              const SizedBox(height: 16),

              _buildRememberMeCheckbox(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          top: 16,
        ),
        child: _buildContinueButton(),
      ),
    );
  }
}
