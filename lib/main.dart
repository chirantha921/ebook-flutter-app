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
import 'screens/home/home_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}