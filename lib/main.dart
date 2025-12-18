import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Frontscreens/login_screen.dart';
//import 'Frontscreens/sign_up.dart';
import 'widgets/logo.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meal Circle',
      theme: ThemeData(useMaterial3: true),
      home: const IntroScreen(),
    );
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF15622F),
              Color(0xFF2AC962),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: height * 0.10),
              const MealCircleLogo(size: 220,),
              const Spacer(),
              const _QuoteText(),
              const Spacer(flex: 3,),
              const _DiveButton(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
class _DiveButton extends StatelessWidget {
  const _DiveButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC8E6C9),
            foregroundColor: Colors.black87,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Let’s Dive!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
class _QuoteText extends StatelessWidget {
  const _QuoteText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        '" Every Bite Of Food Matters,\nNothing Should Go To Waste "',
        textAlign: TextAlign.center,
        style: GoogleFonts.kaushanScript(
          fontSize: 32,
          color: Colors.white,
          height: 1.4,
          shadows: [
            Shadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
