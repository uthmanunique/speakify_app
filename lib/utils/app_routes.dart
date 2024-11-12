import 'package:flutter/material.dart';
import 'package:speakify_app/screens/home_screen.dart';       // Import HomeScreen
import 'package:speakify_app/screens/language_screen.dart';  // Import LanguageScreen
import 'package:speakify_app/screens/splash_screen.dart';    // Import SplashScreen

class AppRoutes {
  static const splashScreen = '/';
  static const languageScreen = '/language';
  static const homeScreen = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case languageScreen:
        return MaterialPageRoute(builder: (_) => LanguageScreen());
      case homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
