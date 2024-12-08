import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart'; // Make sure the path is correct
import 'complete_profile_screen.dart'; // Import your new screen

class BookGenreScreen extends StatefulWidget {
  const BookGenreScreen({Key? key}) : super(key: key);

  @override
  State<BookGenreScreen> createState() => _BookGenreScreenState();
}

class _BookGenreScreenState extends State<BookGenreScreen> {
  final List<String> genres = [
    'Romance',
    'Fantasy',
    'Sci-Fi',
    'Horror',
    'Mystery',
    'Thriller',
    'Psychology',
    'Inspiration',
    'Comedy',
    'Action',
    'Adventure',
    'Comics',
    'Children\'s',
    'Art & Photography',
    'Food & Drink',
    'Biography',
    'Science & Technology',
    'Guide / How-to',
    'Travel',
  ];

  Set<String> _selectedGenres = {};

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
                        'Discover Your\nPerfect Genre',
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Select the genres that interest you most\nfor a tailored reading experience.',
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
                          _buildGenreGrid(),
                          const SizedBox(height: 32),
                          _buildSkipButton(),
                          const SizedBox(height: 16),
                          _buildContinueButton(),
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
                  _buildGenreGrid(),
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
          child: Column(
            children: [
              _buildSkipButton(),
              const SizedBox(height: 16),
              _buildContinueButton(),
            ],
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
      tween: Tween<double>(begin: 0, end: 0.6),
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
    return RichText(
      text: TextSpan(
        style: GoogleFonts.urbanist(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        children: const [
          TextSpan(text: 'Choose the Book Genre\nYou Like '),
          TextSpan(text: '❤️'),
        ],
      ),
    );
  }

  Widget _buildGenreGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: genres.map((genre) {
        final isSelected = _selectedGenres.contains(genre);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedGenres.remove(genre);
              } else {
                _selectedGenres.add(genre);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF7A00) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF7A00) : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Text(
              genre,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        // Implement skip action if needed
        // For example, directly go to the next screen:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteProfileScreen()));
      },
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFFF7A00),
      ),
      child: Text(
        'Skip',
        style: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _selectedGenres.isNotEmpty
          ? () {
              // Navigate to CompleteProfileScreen when continue is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedGenres.isNotEmpty ? const Color(0xFFFF7A00) : Colors.grey.shade300,
        foregroundColor: _selectedGenres.isNotEmpty ? Colors.white : Colors.black54,
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
