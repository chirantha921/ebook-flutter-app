import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart'; // Ensure AppColors and other utils are accessible
import 'otp_screen.dart'; // Import the OTP screen

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: 'andrew.ainsley@yourdomain.com');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    // Navigate to OtpScreen when "Continue" is clicked
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OtpScreen()),
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
              _buildTextFieldLabel("Email"),
              _buildEmailField(),
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
          TextSpan(text: 'Forgot Password '),
          TextSpan(text: '🔑'),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      "Enter your email address. We will send an OTP code for verification in the next step.",
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
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
}
