import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'book_genre_screen.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  String? _selectedAge;

  final List<String> ageRanges = [
    '14 - 17',
    '18 - 24',
    '25 - 29',
    '30 - 34',
    '35 - 39',
    '40 - 44',
    '45 - 49',
    '≥ 50',
  ];

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
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
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
                        'Age-Appropriate\nRecommendations',
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'We\'ll suggest books that resonate\nwith your age group.',
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
                      _buildAnimatedBackButton(context),
                      const SizedBox(width: 16),
                      Expanded(child: _buildAnimatedProgressBar()),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildAgeGrid(),
                          const SizedBox(height: 48),
                          _buildContinueButton(context),
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
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              _buildAnimatedBackButton(context),
              const SizedBox(width: 16),
              Expanded(child: _buildAnimatedProgressBar()),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildAgeGrid(),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            top: 16,
          ),
          child: _buildContinueButton(context),
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
      tween: Tween<double>(begin: 0, end: 0.4),
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
          'What is your age?',
          style: GoogleFonts.urbanist(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select age range for better content.',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAgeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: ageRanges.length,
      itemBuilder: (context, index) {
        final ageRange = ageRanges[index];
        final isSelected = _selectedAge == ageRange;

        return GestureDetector(
          onTap: () => setState(() => _selectedAge = ageRange),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF7A00) : Colors.grey.shade300,
                width: 2,
              ),
              color: isSelected ? const Color(0xFFFF7A00).withOpacity(0.1) : Colors.transparent,
            ),
            child: Center(
              child: Text(
                ageRange,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFFFF7A00) : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _selectedAge == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookGenreScreen()),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedAge == null ? Colors.grey.shade300 : const Color(0xFFFF7A00),
        foregroundColor: _selectedAge == null ? Colors.black54 : Colors.white,
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
