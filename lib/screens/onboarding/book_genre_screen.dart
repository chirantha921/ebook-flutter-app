import 'dart:convert';
import 'package:ebook_app/screens/onboarding/complete_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/home/home_screen.dart';
import '../../services/firebase_service.dart';
import '../../main.dart' show firebaseService, authService;

class BookGenreScreen extends StatefulWidget {
  const BookGenreScreen({Key? key}) : super(key: key);

  @override
  State<BookGenreScreen> createState() => _BookGenreScreenState();
}

class _BookGenreScreenState extends State<BookGenreScreen> {
  final Set<String> _selectedGenres = {};
  bool _isLoading = false;

  // Genre data with emojis and descriptions
  final List<Map<String, dynamic>> _genres = [
    {
      'name': 'Romance',
      'icon': '💕',
      'description': 'Love stories and relationships',
      'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
    },
    {
      'name': 'Fantasy',
      'icon': '🐉',
      'description': 'Magical worlds and creatures',
      'gradient': [const Color(0xFF6B66FF), const Color(0xFF8E8AFF)],
    },
    {
      'name': 'Sci-Fi',
      'icon': '🚀',
      'description': 'Future and technology',
      'gradient': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
    },
    {
      'name': 'Horror',
      'icon': '👻',
      'description': 'Scary and supernatural',
      'gradient': [const Color(0xFF434343), const Color(0xFF000000)],
    },
    {
      'name': 'Mystery',
      'icon': '🔍',
      'description': 'Crime and detective stories',
      'gradient': [const Color(0xFF4B6CB7), const Color(0xFF182848)],
    },
    {
      'name': 'Thriller',
      'icon': '🎭',
      'description': 'Suspense and action',
      'gradient': [const Color(0xFFED213A), const Color(0xFF93291E)],
    },
    {
      'name': 'Psychology',
      'icon': '🧠',
      'description': 'Mind and behavior',
      'gradient': [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
    },
    {
      'name': 'Inspiration',
      'icon': '⭐',
      'description': 'Motivation and success',
      'gradient': [const Color(0xFFF7971E), const Color(0xFFFFD200)],
    },
    {
      'name': 'Comedy',
      'icon': '😂',
      'description': 'Humor and fun',
      'gradient': [const Color(0xFF2AF598), const Color(0xFF009EFD)],
    },
    {
      'name': 'Action',
      'icon': '💥',
      'description': 'Adventure and excitement',
      'gradient': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
    },
    {
      'name': 'Adventure',
      'icon': '🗺️',
      'description': 'Exploration and journeys',
      'gradient': [const Color(0xFF1FA2FF), const Color(0xFF12D8FA)],
    },
    {
      'name': 'Comics',
      'icon': '📚',
      'description': 'Graphic novels and manga',
      'gradient': [const Color(0xFFFF5F6D), const Color(0xFFFFC371)],
    },
    {
      'name': 'Children\'s',
      'icon': '🧸',
      'description': 'Books for young readers',
      'gradient': [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
    },
    {
      'name': 'Art & Photography',
      'icon': '🎨',
      'description': 'Visual arts and photography',
      'gradient': [const Color(0xFFDA4453), const Color(0xFF89216B)],
    },
    {
      'name': 'Food & Drink',
      'icon': '🍳',
      'description': 'Cooking and culinary arts',
      'gradient': [const Color(0xFF11998E), const Color(0xFF38EF7D)],
    },
    {
      'name': 'Biography',
      'icon': '📝',
      'description': 'Life stories and memoirs',
      'gradient': [const Color(0xFF834D9B), const Color(0xFFD04ED6)],
    },
  ];

  Future<void> _saveGenreSelections() async {
    if (_selectedGenres.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final User? currentUser = authService.currentUser;
      
      if (currentUser == null) {
        _showErrorDialog('User session not found. Please try signing in again.');
        return;
      }

      // Update user profile in Firestore with selected genres
      await firebaseService.setDocument(
        'users',
        currentUser.uid,
        {
          'preferred_genres': _selectedGenres.toList(),
          'onboarding_step': 'onboarding_completed',
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      // Navigate to home screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to save selection. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.urbanist(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.urbanist(
                color: const Color(0xFFFF7A00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        onPressed: _isLoading ? null : () => Navigator.pop(context),
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
      children: _genres.map((genre) {
        final isSelected = _selectedGenres.contains(genre['name']);
        final gradientColors = genre['gradient'] as List<Color>;

        return GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  setState(() {
                    if (isSelected) {
                      _selectedGenres.remove(genre['name']);
                    } else {
                      _selectedGenres.add(genre['name']);
                    }
                  });
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  genre['icon'],
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  genre['name'],
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isLoading
          ? null
          : () {
              // Skip directly to profile completion
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompleteProfileScreen(),
                ),
              );
            },
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFFF7A00),
        minimumSize: const Size(double.infinity, 44),
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
      onPressed: _selectedGenres.isEmpty || _isLoading ? null : _saveGenreSelections,
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedGenres.isEmpty ? Colors.grey.shade300 : const Color(0xFFFF7A00),
        foregroundColor: _selectedGenres.isEmpty ? Colors.black54 : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _selectedGenres.isEmpty ? Colors.black54 : Colors.white,
                ),
              ),
            )
          else
            Text(
              'Continue',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}