import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/widgets/logo.dart';
import 'package:mealcircle/Donater/recepients.dart';
import 'package:mealcircle/Donater/past_donation_page.dart';
import 'package:mealcircle/Donater/notification_screen.dart';
import 'package:mealcircle/Donater/payment.dart';
import 'package:mealcircle/Donater/support.dart';
import 'package:mealcircle/widgets/user_service.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _userService = UserService();
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() {
    final user = _userService.currentUser;
    if (user != null && user.name != null && user.name!.isNotEmpty) {
      setState(() {
        _userName = user.name!;
      });
    }
  }

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
                  const MealCircleLogo(size: 220),
                  const SizedBox(height: 12),
                  Text(
                    "Hi, $_userName!",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildImageButton(
                    label: "Donate Food",
                    imagePath: "assets/donate_icon.png",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecipientsScreen(),
                      ),
                    ),
                  ),
                  _buildImageButton(
                    label: "Past Donations",
                    imagePath: "assets/past_donation.png",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PastDonationsPage(),
                      ),
                    ),
                  ),
                  _buildImageButton(
                    label: "Notifications",
                    imagePath: "assets/notification.png",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                  _buildImageButton(
                    label: "Donate Money",
                    imagePath: "assets/wallet.png",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentsScreen(),
                      ),
                    ),
                  ),
                  _buildImageButton(
                    label: "Help & Support",
                    imagePath: "assets/support.png",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SupportScreen(),
                      ),
                    ),
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
            Image.asset(imagePath, height: 30, errorBuilder: (context, error, stackTrace) {
              return Icon(_getIconForLabel(label), size: 30, color: Colors.green.shade700);
            }),
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

  IconData _getIconForLabel(String label) {
    switch (label) {
      case "Donate Food":
        return Icons.restaurant;
      case "Past Donations":
        return Icons.history;
      case "Notifications":
        return Icons.notifications;
      case "Donate Money":
        return Icons.account_balance_wallet;
      case "Help & Support":
        return Icons.support_agent;
      default:
        return Icons.circle;
    }
  }
}