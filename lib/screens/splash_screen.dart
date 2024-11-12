import 'package:flutter/material.dart';
import 'package:speakify_app/utils/app_routes.dart'; // Assume you have routes set up here

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLanguageSelection();
  }

  _navigateToLanguageSelection() async {
    await Future.delayed(const Duration(seconds: 5), () {});
    Navigator.pushReplacementNamed(context, AppRoutes.languageScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF357ABD), // Set the background color to blue
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make the Scaffold background transparent
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image inside a Container
              Container(
                padding: const EdgeInsets.all(20), // Add padding if necessary
                decoration: BoxDecoration(
                  color: Colors.white, // Add background color for the image frame
                  borderRadius: BorderRadius.circular(200), // Rounded corners for the image frame
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/speakify.png',
                  height: 200,
                ),
              ),
              const SizedBox(height: 10),
              // App name or slogan
              const Text(
                "Speakify",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
