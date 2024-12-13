import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';
import 'create_new_password_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  
  // Timer logic
  int _secondsRemaining = 55; 
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Add listeners to focus nodes for nicer UI feedback
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {}); // Rebuild to update focused field styling
      });
    }
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
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onConfirm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNewPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? screenWidth * 0.3 : 24.0,
            vertical: isDesktop ? 60.0 : 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildBackButton(context),
                ],
              ),
              SizedBox(height: isDesktop ? 60 : 40),
              _buildHeader(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              SizedBox(height: isDesktop ? 60 : 40),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildOtpFields(isDesktop),
                    const SizedBox(height: 32),
                    _buildResendInfo(),
                  ],
                ),
              ),
              SizedBox(height: isDesktop ? 60 : 40),
              _buildConfirmButton(),
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
      ),
    );
  }

  Widget _buildOtpFields(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: isDesktop ? 70 : 50,
          margin: EdgeInsets.only(right: index != 3 ? 16 : 0),
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: GoogleFonts.urbanist(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _focusNodes[index].hasFocus 
                      ? AppColors.primary 
                      : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: isDesktop ? 20 : 12,
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendInfo() {
    return Column(
      children: [
        Text(
          "Didn't receive email?",
          style: GoogleFonts.urbanist(
            fontSize: 14,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _secondsRemaining == 0 ? () {
            setState(() {
              _secondsRemaining = 55;
              _startTimer();
            });
          } : null,
          child: Text(
            _secondsRemaining > 0 
              ? "You can resend code in $_secondsRemaining s"
              : "You can resend the code now",
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
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
        ),
      ),
    );
  }
}
