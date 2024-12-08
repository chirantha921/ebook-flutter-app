import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'walkthrough_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configure animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Start animation
    _controller.forward();

    // Navigate to walkthrough screen after delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WalkthroughScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // App Logo/Icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFFF7A00), Color(0xFFFF9D42)],
                                ),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: const Icon(
                                Icons.book_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // App Name
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.urbanist(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Era',
                                    style: GoogleFonts.urbanist(
                                      color: Color(0xFFFF7A00),
                                    ),
                                  ),
                                  const TextSpan(text: 'book'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Tagline
                            Text(
                              'Your Digital Book Companion',
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Loading animation at the bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: SizedBox(
                        width: 110,
                        height: 110,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFF7A00),
                            BlendMode.srcATop,
                          ),
                          child: Lottie.asset(
                            'assets/animations/loading.json',
                            fit: BoxFit.cover,
                            repeat: true,
                            animate: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
