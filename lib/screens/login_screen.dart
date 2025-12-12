import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/widgets/logo.dart';
import 'congrats_login.dart';
import 'sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

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
                const MealCircleLogo(size: 220),
                const SizedBox(height: 12),
                Text(
                  "Login",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15, 
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD1EBD0),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CongratsLogin()),
                      );
                    },
                    child: Text(
                      "Sign In",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: Colors.black26)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Or sign in with",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: Colors.black26)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialIcon("assets/google_logo.png"),
                    const SizedBox(width: 18),
                    _socialIcon("assets/facebook_logo.png"),
                    const SizedBox(width: 18),
                    _socialIcon("assets/twitter_x_logo.png"),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.playfairDisplay(fontSize: 15, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      ),
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
          hintStyle: GoogleFonts.playfairDisplay(fontSize: 15, color: Colors.black87),
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
