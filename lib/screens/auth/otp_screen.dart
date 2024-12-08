import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart'; // Ensure AppColors and other utilities are accessible
import 'create_new_password_screen.dart'; // Import the create new password screen

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Controllers for OTP fields
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  
  // Timer logic (for resend)
  int _secondsRemaining = 55; 
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onConfirm() {
    // After verifying OTP, navigate to create new password screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNewPasswordScreen()),
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
          TextSpan(text: "You've Got Mail "),
          TextSpan(text: '✉️'),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      "We have sent the OTP verification code to your email address. Check your email and enter the code below.",
      style: GoogleFonts.urbanist(
        fontSize: 14,
        color: Colors.black54,
        height: 1.5,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 50,
          margin: EdgeInsets.only(right: index != 3 ? 16 : 0),
          child: TextFormField(
            controller: _otpControllers[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: index == _focusedIndex ? AppColors.primary : Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }

  int get _focusedIndex {
    for (int i = 0; i < _otpControllers.length; i++) {
      if (_otpControllers[i].text.isEmpty) return i;
    }
    return _otpControllers.length - 1; 
  }

  Widget _buildResendInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center text horizontally
      children: [
        Text(
          "Didn't receive email?",
          style: GoogleFonts.urbanist(
            fontSize: 14,
            color: Colors.black87,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _secondsRemaining > 0 
            ? "You can resend code in $_secondsRemaining s"
            : "You can resend the code now",
          style: GoogleFonts.urbanist(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _onConfirm,
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
        'Confirm',
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
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildOtpFields(),
                    const SizedBox(height: 24),
                    _buildResendInfo(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }
}
