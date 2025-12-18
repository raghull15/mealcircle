import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_type_selection_screen.dart';

class CongratsSignup extends StatefulWidget {
  const CongratsSignup({super.key});

  @override
  State<CongratsSignup> createState() => _CongratsSignupState();
}

class _CongratsSignupState extends State<CongratsSignup> {
  double _scale = 0.5;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _scale = 1;
        _opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2AC962),
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 700),
          opacity: _opacity,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 600),
            scale: _scale,
            curve: Curves.easeOutBack,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 120,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Account Created!",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 34,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your Meal Circle account has been\ncreated successfully.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const UserTypeSelectionFlow()),
                      );
                    },
                    child: Text(
                      "Continue",
                      style: GoogleFonts.playfairDisplay(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}