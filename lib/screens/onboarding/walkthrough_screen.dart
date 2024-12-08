import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gender_selection_screen.dart'; // This was previously used for "Get Started" navigation
import '../auth/signin_screen.dart';    // Import SignInScreen
import '../../utils/constants.dart';    // Ensure AppColors and other utils are accessible

class WalkthroughScreen extends StatelessWidget {
  const WalkthroughScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
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
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        // Left side - Hero Image
        Expanded(
          flex: 6,
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
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: screenWidth * 0.08,
                  bottom: screenHeight * 0.15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover\nYour Next\nFavorite Book',
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Find the perfect story that matches\nyour interests and mood.',
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.014,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Content
        Expanded(
          flex: 4,
          child: Container(
            height: screenHeight,
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.urbanist(
                              fontSize: 42,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              const TextSpan(text: 'Welcome to '),
                              TextSpan(
                                text: 'ebook',
                                style: GoogleFonts.urbanist(
                                  color: const Color(0xFFFF7A00),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' 👋'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'The Best Ebook Store & Reader\nApplication in this Century',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            color: Colors.black54,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF7A00),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(
                              4,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/icons/google.png', height: 24),
                                const SizedBox(width: 16),
                                Text(
                                  'Continue with Google',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              backgroundColor: const Color(0xFFFF7A00),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const GenderSelectionScreen()),
                              );
                            },
                            child: Text(
                              'Get Started',
                              style: GoogleFonts.urbanist(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            // Navigate to SignInScreen when "I Already Have an Account" is clicked
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF7A00),
                          ),
                          child: Text(
                            'I Already Have an Account',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.urbanist(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            children: [
              const TextSpan(text: 'Welcome to '),
              TextSpan(
                text: 'ebook',
                style: GoogleFonts.urbanist(
                  color: const Color(0xFFFF7A00),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' 👋'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'The Best Ebook Store & Reader\nApplication in this Century',
          textAlign: TextAlign.center,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black54,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            side: BorderSide(color: Colors.grey.shade300),
            backgroundColor: Colors.white,
          ),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/google.png', height: 24),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A00), Color(0xFFFF9D42)],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GenderSelectionScreen()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // Navigate to SignInScreen on "I Already Have an Account"
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFF7A00),
          ),
          child: Text(
            'I Already Have an Account',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
