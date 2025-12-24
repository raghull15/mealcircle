import 'package:flutter/material.dart';
import 'package:mealcircle/services/user_service.dart';
import 'package:mealcircle/shared/design_system.dart';
import 'package:mealcircle/Donater/recepients.dart';
import 'package:mealcircle/Donater/past_donation_page.dart';
import 'package:mealcircle/Donater/notification_screen.dart';
import 'package:mealcircle/payments/payment.dart';
import 'package:mealcircle/services/support.dart';
import 'package:mealcircle/services/user_profile_page.dart';
import 'package:mealcircle/Frontscreens/logo.dart';

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

  void _loadUserName() async {
    final user = await _userService.loadUser();
    if (user != null && user.name != null && user.name!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _userName = user.name!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.95),
                    AppColors.primaryGreen.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const MealCircleLogo(size: 220),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Welcome, $_userName! 👋",
                    style: AppTypography.headingMedium(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Make a difference today",
                    style: AppTypography.labelMedium(color: Colors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildMenuButton(
              label: "Donate Food",
              icon: Icons.restaurant_rounded,
              color: AppColors.primaryGreen,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecipientsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              label: "Past Donations",
              icon: Icons.history_rounded,
              color: Colors.blue,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PastDonationsPage()),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              label: "Notifications",
              icon: Icons.notifications_rounded,
              color: AppColors.accentOrange,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              label: "Donate Money",
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.purple,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              label: "Help & Support",
              icon: Icons.support_agent_rounded,
              color: Colors.indigo,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryGreen, AppColors.primaryGreen.withOpacity(0.85)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MealCircle',
                        style: AppTypography.headingMedium(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share meals, Share love',
                          style: AppTypography.caption(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline,
                        color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserProfilePage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.labelLarge(color: AppColors.textDark),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: AppColors.textLight.withOpacity(0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}