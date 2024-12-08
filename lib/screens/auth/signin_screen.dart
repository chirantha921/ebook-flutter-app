import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart'; // For AppColors, etc.
import 'forgot_password_screen.dart'; // Import the ForgotPasswordScreen

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameEmailController = TextEditingController(text: 'andrew.ainsley@yourdomain.com');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');

  bool _rememberMe = true;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onForgotPassword() {
    // Navigate to ForgotPasswordScreen when clicked
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
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

              // Username/Email field
              _buildTextFieldLabel("Username / Email"),
              _buildReadOnlyField(_usernameEmailController),
              const SizedBox(height: 16),

              // Password field
              _buildTextFieldLabel("Password"),
              _buildPasswordField(_passwordController),
              const SizedBox(height: 16),

              // Remember Me checkbox
              _buildRememberMeCheckbox(),
              const SizedBox(height: 16),

              // Forgot Password
              Center(
                child: TextButton(
                  onPressed: _onForgotPassword, // Navigate to ForgotPasswordScreen
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(
                    "Forgot Password",
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Continue with divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "or continue with",
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                ],
              ),
              const SizedBox(height: 24),

              // Social buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton('assets/icons/google.png', onPressed: () {}),
                  const SizedBox(width: 16),
                  _buildSocialButton('assets/icons/apple.png', onPressed: () {}),
                  const SizedBox(width: 16),
                  _buildSocialButton('assets/icons/facebook.png', onPressed: () {}),
                ],
              ),
              const SizedBox(height: 40),

              // Sign In button
              _buildSignInButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
          TextSpan(text: 'Hello there '),
          TextSpan(text: '👋'),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      "Please enter your username/email and password to sign in.",
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

  Widget _buildReadOnlyField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
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

  Widget _buildPasswordField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !_passwordVisible,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
          decoration: InputDecoration(
            hintText: '••••••••••••',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primary,
              ),
              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
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

  Widget _buildSocialButton(String iconPath, {required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(iconPath),
      ),
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement sign in logic
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
        'Sign In',
        style: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
