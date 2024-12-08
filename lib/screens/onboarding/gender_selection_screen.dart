import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'age_selection_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: screenHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/library.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                        'Tell Us About\nYourself',
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Help us personalize your reading experience\nby sharing a bit about yourself.',
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
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.1,
            ),
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildAnimatedBackButton(context),
                        const SizedBox(width: 16),
                        Expanded(child: _buildAnimatedProgressBar()),
                      ],
                    ),
                    const SizedBox(height: 48),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    ..._buildGenderOptions(),
                    const SizedBox(height: 48),
                    _buildContinueButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Top hero section with image and gradient
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
        // Bottom content container with similar padding structure as WalkthroughScreen
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAnimatedBackButton(context),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAnimatedProgressBar()),
                  ],
                ),
                const SizedBox(height: 48),
                _buildHeader(),
                const SizedBox(height: 40),
                ..._buildGenderOptions(),
                const SizedBox(height: 48),
                _buildContinueButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedBackButton(BuildContext context) {
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

  Widget _buildAnimatedProgressBar() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 0.2),
      builder: (context, double value, child) {
        return Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: value,
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
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your gender?',
          style: GoogleFonts.urbanist(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select gender for better content.',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGenderOptions() {
    final options = [
      {'title': 'I am male', 'value': 'male', 'icon': '👨'},
      {'title': 'I am female', 'value': 'female', 'icon': '👩'},
      {'title': 'Rather not to say', 'value': 'none', 'icon': '🤝'},
    ];

    return options.map((option) {
      final bool isSelected = _selectedGender == option['value'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: InkWell(
            onTap: () => setState(() => _selectedGender = option['value'] as String),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF7A00).withOpacity(0.1) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF7A00) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    option['icon'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    option['title'] as String,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFFFF7A00) : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFFFF7A00),
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildContinueButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _selectedGender == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgeSelectionScreen()),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedGender == null ? Colors.grey.shade300 : const Color(0xFFFF7A00),
        foregroundColor: _selectedGender == null ? Colors.black54 : Colors.white,
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
        ),
      ),
    );
  }
}
