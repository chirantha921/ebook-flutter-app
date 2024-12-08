import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import 'create_account_screen.dart'; // Ensure the path is correct

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _fullNameController =
      TextEditingController(text: "Andrew Ainsley");
  final TextEditingController _phoneController =
      TextEditingController(text: "+1-300-555-0399");
  final TextEditingController _dobController =
      TextEditingController(text: "12/27/1995");
  final TextEditingController _countryController =
      TextEditingController(text: "United States");

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
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
        // Left side - hero image
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
        // Right side - form and content
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
                          const SizedBox(height: 16),
                          _buildSubtitle(),
                          const SizedBox(height: 32),
                          _buildProfileImage(),
                          const SizedBox(height: 32),
                          _buildTextFieldLabel("Full Name"),
                          _buildReadOnlyField(_fullNameController),
                          const SizedBox(height: 16),
                          _buildTextFieldLabel("Phone Number"),
                          _buildReadOnlyField(_phoneController),
                          const SizedBox(height: 16),
                          _buildTextFieldLabel("Date of Birth"),
                          _buildReadOnlyField(_dobController, suffixIcon: Icons.calendar_today),
                          const SizedBox(height: 16),
                          _buildTextFieldLabel("Country"),
                          _buildReadOnlyField(_countryController, suffixIcon: Icons.keyboard_arrow_down),
                          const SizedBox(height: 40),
                          _buildContinueButton(),
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

  Widget _buildMobileLayout() {
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
                    image: AssetImage('assets/images/library.jpg'),
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
                const SizedBox(height: 16),
                _buildSubtitle(),
                const SizedBox(height: 32),
                _buildProfileImage(),
                const SizedBox(height: 32),
                _buildTextFieldLabel("Full Name"),
                _buildReadOnlyField(_fullNameController),
                const SizedBox(height: 16),
                _buildTextFieldLabel("Phone Number"),
                _buildReadOnlyField(_phoneController),
                const SizedBox(height: 16),
                _buildTextFieldLabel("Date of Birth"),
                _buildReadOnlyField(_dobController, suffixIcon: Icons.calendar_today),
                const SizedBox(height: 16),
                _buildTextFieldLabel("Country"),
                _buildReadOnlyField(_countryController, suffixIcon: Icons.keyboard_arrow_down),
                const SizedBox(height: 40),
                _buildContinueButton(),
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
        onPressed: () => Navigator.pop(context),
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProgressBar() {
    // Using a fixed widthFactor as GenderSelectionScreen does (like 0.4)
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: 0.4,
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
        ),
        children: const [
          TextSpan(text: 'Complete Your Profile '),
          TextSpan(text: '👩‍💻'),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      "Don't worry, only you can see your personal data. No one else will be able to see it.",
      style: GoogleFonts.urbanist(
        fontSize: 14,
        color: Colors.black54,
        height: 1.5,
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
              image: const DecorationImage(
                image: AssetImage('assets/images/profile_placeholder.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
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
        ],
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
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller, {IconData? suffixIcon}) {
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
          ),
          decoration: InputDecoration(
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: const Color(0xFFFF7A00), size: 20)
                : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFFFF7A00)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF7A00),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Text(
        'Continue',
        style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
