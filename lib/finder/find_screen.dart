import 'package:flutter/material.dart';
import 'package:mealcircle/finder/finder_support_screen.dart';
import 'package:mealcircle/Frontscreens/logo.dart';
import 'package:mealcircle/services/user_service.dart';
import 'package:mealcircle/finder/finder_user_profile_page.dart';
import 'package:mealcircle/finder/browse_donations_screen.dart';
import 'package:mealcircle/finder/finder_notification_screen.dart';
import 'package:mealcircle/finder/received_money_screen.dart';
import 'package:mealcircle/finder/my_orders_screen.dart';
import 'package:mealcircle/shared/design_system.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
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
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBarStyles.standard(
        context: context,
        title: 'MealCircle',
        subtitle: 'Find meals, Receive help',
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline,
                  color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FinderUserProfilePage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppBreakpoints.responsivePadding(context),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.95),
                    AppColors.primaryGreen.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.medium,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const MealCircleLogo(size: 220),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Welcome, $_userName! 👋",
                    style: AppTypography.headingMedium(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "Find meals available near you",
                    style: AppTypography.bodySmall(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Menu Buttons
            _buildMenuButton(
              label: "Browse Food Donations",
              icon: Icons.restaurant_rounded,
              color: AppColors.primaryGreen,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BrowseDonationsScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMenuButton(
              label: "My Orders",
              icon: Icons.list_alt_rounded,
              color: AppColors.teal,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMenuButton(
              label: "Notifications",
              icon: Icons.notifications_rounded,
              color: AppColors.purple,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FinderNotificationScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMenuButton(
              label: "Received Money",
              icon: Icons.wallet,
              color: AppColors.pink,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReceivedMoneyScreen()),
                );
              },
            ),
            
            const SizedBox(height: AppSpacing.md),
            _buildMenuButton(
              label: "Help & Support",
              icon: Icons.support_agent_rounded,
              color: AppColors.indigo,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FinderSupportScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
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
          borderRadius: BorderRadius.circular(AppRadius.md + 2),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 14,
            ),
            decoration: AppDecorations.card(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: AppDecorations.rounded(
                    color: color.withOpacity(0.15),
                    radius: AppRadius.md,
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppColors.textLight.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}