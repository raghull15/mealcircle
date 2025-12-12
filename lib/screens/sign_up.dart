import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/widgets/logo.dart';
import 'congrats_signup.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2AC962),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MealCircleLogo(size:220),
                const SizedBox(height: 20),
                Text(
                  "Create Account",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),
                _inputField(hint: "Email", obscure: false),
                const SizedBox(height: 20),
                _inputField(
                  hint: "Password",
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black87,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 20),
                _inputField(
                  hint: "Confirm Password",
                  obscure: _obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black87,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD1EBD0),
                      foregroundColor: Colors.black87,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CongratsSignup()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: Colors.black38)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Or sign up with",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: Colors.black38)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialIcon("assets/google_logo.png"),
                    const SizedBox(width: 22),
                    _socialIcon("assets/facebook_logo.png"),
                    const SizedBox(width: 22),
                    _socialIcon("assets/twitter_x_logo.png"),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Sign In",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({required String hint, required bool obscure, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDE8E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: obscure,
        style: GoogleFonts.playfairDisplay(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.playfairDisplay(fontSize: 16, color: Colors.black87),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          border: InputBorder.none,
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _socialIcon(String asset) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Image.asset(asset, height: 22),
    );
  }
}
