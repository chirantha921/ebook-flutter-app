import 'package:flutter/material.dart';
import '../../screens/onboarding/splash_screen.dart';
import '../../screens/onboarding/walkthrough_screen.dart';
import '../../screens/onboarding/signup_screen.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.walkthrough:
        return MaterialPageRoute(builder: (_) => const WalkthroughScreen());
      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

// Route names as constants
class Routes {
  static const String splash = '/';
  static const String walkthrough = '/walkthrough';
  static const String signup = '/signup';
}