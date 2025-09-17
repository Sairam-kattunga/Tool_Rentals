import 'dart:async';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  final bool isLoggedIn;
  const IntroScreen({super.key, required this.isLoggedIn});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Bouncing logo animation: scale up with a bounce
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Dynamic text animation: fade and slide
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

    _controller.forward();

    // After 2.5 sec → navigate
    Timer(const Duration(milliseconds: 2500), () {
      if (widget.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with bouncing scale animation
            ScaleTransition(
              scale: _logoScale,
              child: Image.asset(
                "lib/assets/Logo_intro.png",
                height: 200, // 🔥 Increased logo size for a bigger bounce effect
                width: 200,
              ),
            ),
            const SizedBox(height: 20),
            // Combined Fade and Slide for "Rental" text
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: const Text(
                  "RentEazy",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Combined Fade and Slide for "Rent Smarter" text
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: const Text(
                  "Rent Smarter • Save More",
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}