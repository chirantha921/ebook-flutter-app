import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'walkthrough_screen.dart';
import '../../services/firebase_service.dart';
import '../../main.dart' show firebaseService, authService;
import '../home/home_screen.dart';

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

    // Initialize app and check auth state
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check if user is already logged in
      final User? currentUser = authService.currentUser;
      
      // Simulate initialization delay
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      if (currentUser != null) {
        // Verify user data exists in Firestore
        final doc = await firebaseService.getDocument('users', currentUser.uid);
        
        if (doc.exists) {
          // Navigate to home if user data exists
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return;
        }
      }

      // Navigate to walkthrough if no valid session
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
      );
    } catch (e) {
      print('Error during initialization: $e');
      // In case of error, direct to walkthrough
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI properties
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final isDesktop = MediaQuery.of(context).size.width > 800;

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
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64.0 : 24.0,
                  ),
                  child: Column(
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Logo/Icon
                              Container(
                                width: isDesktop ? 160 : 120,
                                height: isDesktop ? 160 : 120,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFFF7A00), Color(0xFFFF9D42)],
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF7A00).withOpacity(0.3),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.book_rounded,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: isDesktop ? 32 : 24),
                              // App Name
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.urbanist(
                                    fontSize: isDesktop ? 48 : 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Era',
                                      style: GoogleFonts.urbanist(
                                        color: const Color(0xFFFF7A00),
                                      ),
                                    ),
                                    const TextSpan(text: 'book'),
                                  ],
                                ),
                              ),
                              SizedBox(height: isDesktop ? 24 : 16),
                              // Tagline
                              Text(
                                'Your Digital Book Companion',
                                style: GoogleFonts.urbanist(
                                  fontSize: isDesktop ? 20 : 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Loading animation at the bottom
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: isDesktop ? 140 : 110,
                            height: isDesktop ? 140 : 110,
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFFF7A00),
                                BlendMode.srcATop,
                              ),
                              child: Lottie.asset(
                                'assets/animations/loading.json',
                                fit: BoxFit.contain,
                                repeat: true,
                                animate: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}