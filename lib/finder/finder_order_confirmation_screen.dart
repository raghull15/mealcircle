import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'finder_models.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/shared/design_system.dart';
import 'package:mealcircle/finder/finder_cart_manager.dart';
import 'package:mealcircle/finder/my_orders_screen.dart';

class FinderOrderConfirmationScreen extends StatefulWidget {
  const FinderOrderConfirmationScreen({super.key});

  @override
  State<FinderOrderConfirmationScreen> createState() =>
      _FinderOrderConfirmationScreenState();
}

class _FinderOrderConfirmationScreenState
    extends State<FinderOrderConfirmationScreen> with TickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _checkController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = Provider.of<FinderCartManager>(context);

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),

                  // Animated Check Icon
                  ScaleTransition(
                    scale: _checkAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withOpacity(0.8)
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Success Message
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Column(
                      children: [
                        Text(
                          'Order Placed Successfully!',
                          style: AppTypography.displaySmall(
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Your food donation requests have been sent to the donors',
                          style: AppTypography.bodyLarge(
                            color: AppColors.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Order Summary Card
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: AppDecorations.card(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: AppColors.accentOrange,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order Summary',
                                      style: AppTypography.headingSmall(),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Order placed on ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                                      style: AppTypography.bodySmall(
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Divider(color: AppColors.borderLight),
                          const SizedBox(height: AppSpacing.lg),

                          // Items Summary
                          ..._buildOrderSummaryItems(cartManager),

                          const SizedBox(height: AppSpacing.lg),
                          Divider(color: AppColors.borderLight),
                          const SizedBox(height: AppSpacing.lg),

                          // Totals
                          _buildSummaryRow(
                            'Total Items:',
                            cartManager.itemCount.toString(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildSummaryRow(
                            'Total Servings:',
                            cartManager.totalServings.toString(),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Next Steps Card
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withOpacity(0.1),
                            AppColors.primaryGreen.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  Icons.info_outlined,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Text(
                                  'What Happens Next?',
                                  style: AppTypography.labelMedium(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildNextStepItem(
                            '1',
                            'Donors Notified',
                            'Food donors will receive your request immediately',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildNextStepItem(
                            '2',
                            'Confirmation',
                            'Donors will confirm availability and delivery time',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildNextStepItem(
                            '3',
                            'Delivery/Pickup',
                            'Food will be delivered or ready for pickup',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Action Buttons
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Download PDF (placeholder for now)
                              _downloadOrderPDF(cartManager);
                            },
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Download Order Details (PDF)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyOrdersScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.list_alt_rounded),
                            label: const Text('View My Orders'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).popUntil(
                                (route) => route.isFirst,
                              );
                            },
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('Back to Home'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: const BorderSide(
                                color: AppColors.primaryGreen,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOrderSummaryItems(FinderCartManager cartManager) {
    return cartManager.items.asMap().entries.map((entry) {
      int idx = entry.key;
      FinderCartItem item = entry.value;

      return Column(
        children: [
          if (idx > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.borderLight, height: 0),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.network(
                  item.donation.imagePath ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.borderLight,
                    child: const Icon(Icons.image_not_supported_rounded, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.donation.foodType,
                      style: AppTypography.labelMedium(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'by ${item.donation.donorName}',
                      style:
                          AppTypography.bodySmall(color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${item.requestedServings} servings',
                  style: AppTypography.labelSmall(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }).toList();
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTypography.labelMedium()
              : AppTypography.bodyMedium(),
        ),
        Text(
          value,
          style: isBold
              ? AppTypography.headingSmall(color: AppColors.primaryGreen)
              : AppTypography.labelMedium(color: AppColors.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildNextStepItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen,
                AppColors.primaryGreen.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.labelMedium(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: AppTypography.bodySmall(color: AppColors.textLight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _downloadOrderPDF(FinderCartManager cartManager) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: AppSpacing.lg),
            Text('Order details downloaded as PDF'),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}