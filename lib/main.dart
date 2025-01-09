import 'package:ebook_app/screens/adminScreen/addBook.dart';
import 'package:ebook_app/screens/adminScreen/adminHomeScreen.dart';
import 'package:ebook_app/screens/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'package:provider/provider.dart';
import 'providers/user_Provider.dart';
import 'services/firebase_service.dart';
import 'utils/constants.dart';
import 'utils/routes.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Create global service instances
final authService = AuthService();
final firebaseService = FirebaseService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with all required options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    print('Firebase initialized successfully');
  });

   //  Firestore offline persistence
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
  );
  
  // Configure Firebase Storage to handle large files
  FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 30));
  FirebaseStorage.instance
      .setMaxOperationRetryTime(const Duration(seconds: 30));

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

  // Initialize audio session
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
    avAudioSessionMode: AVAudioSessionMode.spokenAudio,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
      title: 'eBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SignInScreen(),
      ),
    );
  }
}
