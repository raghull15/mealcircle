import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/widgets/logo.dart';

class FindScreen extends StatelessWidget {
  const FindScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2AC962), Color(0xFF2AC962)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const MealCircleLogo(size:220),
                  const SizedBox(height: 12),
                  Text(
                    "Hi, Raghul!",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildImageButton(
                    label: "Find Food",
                    imagePath: "assets/find_food.png",
                    onPressed: () => debugPrint("Find Food Clicked"),
                  ),
                  _buildImageButton(
                    label: "My Orders",
                    imagePath: "assets/orders.png",
                    onPressed: () => debugPrint("My Orders Clicked"),
                  ),
                  _buildImageButton(
                    label: "Notifications",
                    imagePath: "assets/notification.png",
                    onPressed: () => debugPrint("Notifications Clicked"),
                  ),
                  _buildImageButton(
                    label: "Payment",
                    imagePath: "assets/wallet.png",
                    onPressed: () => debugPrint("payment Clicked"),
                  ),
                  _buildImageButton(
                    label: "Support",
                    imagePath: "assets/support.png",
                    onPressed: () => debugPrint("Support Clicked"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton({
    required String label,
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green.shade700,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 30),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
