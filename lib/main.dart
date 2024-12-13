import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'utils/constants.dart';
import 'utils/routes.dart';
import 'screens/onboarding/splash_screen.dart';

// Create global service instances
final authService = AuthService();
final firebaseService = FirebaseService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with all required options
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyB0ZQL9PuxU84r30Jfh8cjSlzMKPV9bp70',
      appId: '1:311947320356:android:b47bd9a43f7531d5ee8cb1',
      messagingSenderId: '311947320356',
      projectId: 'ebook-zakaria',
      storageBucket: 'ebook-zakaria.firebasestorage.app',
    ),
  );

  // Configure Firebase Storage to handle large files
  FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 30));
  FirebaseStorage.instance.setMaxOperationRetryTime(const Duration(seconds: 30));
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erabook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primary,
        ),
      ),
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      navigatorKey: AppRouter.navigatorKey,
      // Add route observer for analytics if needed
      navigatorObservers: [
        RouteObserver<ModalRoute<void>>(),
      ],
      builder: (context, child) {
        // Add any app-wide builders here (e.g., for overlays, error handling)
        return MediaQuery(
          // Prevent text scaling to maintain design consistency
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}