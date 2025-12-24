import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'finder_models.dart';
import 'package:provider/provider.dart';
import 'package:mealcircle/shared/design_system.dart';
import 'package:mealcircle/finder/finder_cart_manager.dart';
import 'package:mealcircle/finder/finder_order_confirmation_screen.dart';

class FinderCartScreen extends StatefulWidget {
  const FinderCartScreen({super.key});

  @override
  State<FinderCartScreen> createState() => _FinderCartScreenState();
}

class _FinderCartScreenState extends State<FinderCartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBarStyles.standard(
        context: context,
        title: 'Shopping Cart',
        subtitle: 'Review your items',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Consumer<FinderCartManager>(
        builder: (context, cartManager, child) {
          if (cartManager.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: cartManager.items.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(
                      context,
                      cartManager.items[index],
                      index,
                      cartManager,
                    );
                  },
                ),
              ),

              // Cart Summary
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Summary rows
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Items:',
                            style: AppTypography.bodyMedium(),
                          ),
                          Text(
                            cartManager.itemCount.toString(),
                            style: AppTypography.labelLarge(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Servings:',
                            style: AppTypography.bodyMedium(),
                          ),
                          Text(
                            cartManager.totalServings.toString(),
                            style: AppTypography.labelLarge(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Divider(color: AppColors.borderLight),
                      const SizedBox(height: AppSpacing.lg),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showClearCartDialog(context, cartManager);
                              },
                              icon: const Icon(Icons.delete_outlined),
                              label: const Text('Clear Cart'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FinderOrderConfirmationScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Proceed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.primaryGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Your cart is empty',
            style: AppTypography.headingSmall(color: AppColors.textDark),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Browse donations to add items to your cart',
            style: AppTypography.bodySmall(color: AppColors.textLight),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.shopping_bag_rounded),
            label: const Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    FinderCartItem item,
    int index,
    FinderCartManager cartManager,
  ) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: AppDecorations.card(),
        child: Column(
          children: [
            // Image & Item Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(AppRadius.lg),
                  ),
                  child: Image.network(
                    item.donation.imagePath ?? '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: AppColors.borderLight,
                      child: const Icon(Icons.image_not_supported_rounded),
                    ),
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.donation.foodType,
                          style: AppTypography.labelLarge(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'by ${item.donation.donorName}',
                          style:
                              AppTypography.bodySmall(color: AppColors.textLight),
                        ),
                        const SizedBox(height: AppSpacing.sm),
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
                            'Servings: ${item.requestedServings}',
                            style: AppTypography.labelSmall(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Delete button
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: GestureDetector(
                    onTap: () {
                      cartManager.removeItemAt(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Item removed from cart'),
                          backgroundColor: AppColors.primaryGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details section (expandable)
            _buildCollapsibleDetails(item, context),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleDetails(FinderCartItem item, BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          'View Details',
          style: AppTypography.labelMedium(color: AppColors.primaryGreen),
        ),
        trailing: const Icon(Icons.expand_more_rounded),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: AppColors.borderLight),
              const SizedBox(height: AppSpacing.md),
              
              // Donor Info
              _buildDetailSection('Donor Information', [
                _buildDetailItem('Name', item.donation.donorName),
                _buildDetailItem('Phone', item.donation.donorPhone),
                _buildDetailItem('Location', item.donation.location),
              ]),
              const SizedBox(height: AppSpacing.lg),

              // Finder Info
              _buildDetailSection('Your Information', [
                _buildDetailItem('Name', item.finderName),
                _buildDetailItem('Phone', item.finderPhone),
                _buildDetailItem('Address', item.finderAddress),
              ]),
              const SizedBox(height: AppSpacing.lg),

              // Delivery Method
              _buildDetailSection('Delivery Method', [
                _buildDetailItem(
                  'Method',
                  item.selectedDeliveryMethod == 'donor_delivery'
                      ? 'Donor will deliver'
                      : 'You will pickup',
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),

              // Notes
              if (item.notes != null && item.notes!.isNotEmpty)
                _buildDetailSection('Notes', [
                  _buildDetailItem('Special Notes', item.notes ?? ''),
                ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.labelMedium()),
        const SizedBox(height: AppSpacing.md),
        ...items,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodySmall(color: AppColors.textLight),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(
    BuildContext context,
    FinderCartManager cartManager,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Clear Cart?',
          style: AppTypography.headingSmall(),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: AppTypography.bodyMedium(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.labelMedium(color: AppColors.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cartManager.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cart cleared'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}