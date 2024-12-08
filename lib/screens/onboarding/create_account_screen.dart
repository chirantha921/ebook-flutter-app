import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../utils/constants.dart'; // Ensure the path is correct

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _usernameController = TextEditingController(text: 'andrew_ainsley');
  final _emailController = TextEditingController(text: 'andrew.ainsley@yourdomain.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _confirmPasswordController = TextEditingController(text: 'password123');

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    // Perform signup logic here
    // After successful sign up:
    _showSignUpSuccessDialog();
  }

  void _showSignUpSuccessDialog() {
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
                          Icons.person,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sign Up Successful!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        decoration: TextDecoration.none, // No underline
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your account has been created.\nPlease wait a moment, we are preparing for you...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                        decoration: TextDecoration.none, // No underline
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Lottie animation for loading
                    Lottie.asset(
                      'assets/animations/loading.json',
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    // Simulate a delay before closing the dialog or navigating away
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close the dialog
      // Navigate to the next screen or home
      // Navigator.pushReplacementNamed(context, '/home');
    });
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        // Left side - Hero image
        Expanded(
          flex: 5,
          child: Container(
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/library.jpg'), // Update path if needed
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
                        'Create\nYour Account',
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          decoration: TextDecoration.none, // No underline
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Enter your details to get started.\nIf you forget it, then you have to do forgot password.',
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.012,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                          decoration: TextDecoration.none, // No underline
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Form
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 12),
                          _buildSubtitle(),
                          const SizedBox(height: 32),
                          _buildTextFieldLabel("Username"),
                          _buildReadOnlyField(_usernameController),
                          const SizedBox(height: 16),
                          _buildTextFieldLabel("Email"),
                          _buildReadOnlyField(_emailController),
                          const SizedBox(height: 16),
                          _buildTextFieldLabel("Password"),
                          _buildPasswordField(
                            controller: _passwordController,
                            visible: _passwordVisible,
                            onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                          ),
                          const SizedBox(height: 16),
                          _buildTextFieldLabel("Confirm Password"),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            visible: _confirmPasswordVisible,
                            onToggle: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                          ),
                          const SizedBox(height: 16),
                          _buildRememberMeCheckbox(),
                          const SizedBox(height: 40),
                          _buildSignUpButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
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

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Hero section
        Expanded(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/library.jpg'), // Update path if needed
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 300,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0.9),
                        Colors.white,
                      ],
                      stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content below hero
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: SingleChildScrollView(
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
                _buildHeader(),
                const SizedBox(height: 12),
                _buildSubtitle(),
                const SizedBox(height: 32),
                _buildTextFieldLabel("Username"),
                _buildReadOnlyField(_usernameController),
                const SizedBox(height: 16),
                _buildTextFieldLabel("Email"),
                _buildReadOnlyField(_emailController),
                const SizedBox(height: 16),
                _buildTextFieldLabel("Password"),
                _buildPasswordField(
                  controller: _passwordController,
                  visible: _passwordVisible,
                  onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
                const SizedBox(height: 16),
                _buildTextFieldLabel("Confirm Password"),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  visible: _confirmPasswordVisible,
                  onToggle: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                ),
                const SizedBox(height: 16),
                _buildRememberMeCheckbox(),
                const SizedBox(height: 40),
                _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ],
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
        color: Colors.black87,
        onPressed: () => Navigator.pop(context),
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
            widthFactor: 0.8, // Progress - adjust as needed
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

  Widget _buildHeader() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.urbanist(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          decoration: TextDecoration.none, // No underline
        ),
        children: const [
          TextSpan(text: 'Create an Account '),
          TextSpan(text: '🔒'),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Enter your username, email & password. If you forget it, then you have to do forgot password.',
      style: GoogleFonts.urbanist(
        fontSize: 14,
        color: Colors.black54,
        height: 1.5,
        decoration: TextDecoration.none, // No underline
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
        decoration: TextDecoration.none, // No underline
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none, // No underline
          ),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
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
            decoration: TextDecoration.none, // No underline
          ),
          decoration: InputDecoration(
            hintText: '••••••••••••',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
              decoration: TextDecoration.none, // No underline
            ),
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primary,
              ),
              onPressed: onToggle,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
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
            decoration: TextDecoration.none, // No underline
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _onSignUp,
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
        'Sign Up',
        style: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none, // No underline
        ),
      ),
    );
  }
}
