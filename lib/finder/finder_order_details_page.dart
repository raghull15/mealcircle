import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/shared/design_system.dart';
import 'package:mealcircle/finder/finder_models.dart';

class FinderOrderDetailsPage extends StatelessWidget {
  final Order order;

  const FinderOrderDetailsPage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBarStyles.standard(
        context: context,
        title: 'Order Details',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Image.network(
                order.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: AppColors.borderLight,
                  child: const Icon(Icons.image_not_supported_rounded),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Order Status Card
            _buildStatusCard(),
            const SizedBox(height: AppSpacing.lg),

            // Food Details
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppDecorations.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Food Details',
                    style: AppTypography.headingSmall(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDetailRow('Food Type', order.foodType),
                  const SizedBox(height: AppSpacing.md),
                  _buildDetailRow('From', order.donorName),
                  const SizedBox(height: AppSpacing.md),
                  _buildDetailRow('Location', order.donorLocation),
                  const SizedBox(height: AppSpacing.md),
                  _buildDetailRow(
                    'Servings',
                    '${order.servings} servings',
                    valueColor: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Your Order Details
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppDecorations.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Information',
                    style: AppTypography.headingSmall(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDetailRow('Name', order.finderName),
                  const SizedBox(height: AppSpacing.md),
                  _buildDetailRow('Phone', order.finderPhone),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Delivery Information
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentOrange.withOpacity(0.1),
                    AppColors.accentOrange.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.accentOrange.withOpacity(0.2),
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
                          color: AppColors.accentOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          order.deliveryMethod == 'donor_delivery'
                              ? Icons.local_shipping_rounded
                              : Icons.person_pin_circle_rounded,
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
                              'Delivery Method',
                              style: AppTypography.labelMedium(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              order.deliveryMethod == 'donor_delivery'
                                  ? 'Donor will deliver to your address'
                                  : 'You will pick up from donor location',
                              style: AppTypography.bodySmall(
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Order Timeline
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppDecorations.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Timeline',
                    style: AppTypography.headingSmall(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTimelineStep(
                    '1',
                    'Order Placed',
                    'Your order has been placed',
                    isCompleted: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTimelineStep(
                    '2',
                    'Confirmed',
                    'Donor has confirmed the order',
                    isCompleted: order.status != 'pending',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTimelineStep(
                    '3',
                    'In Transit',
                    'Food is on the way',
                    isCompleted:
                        order.status == 'in_transit' || order.status == 'delivered',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTimelineStep(
                    '4',
                    'Delivered',
                    'Order received',
                    isCompleted: order.status == 'delivered',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Share order details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.share_rounded, color: Colors.white),
                          SizedBox(width: AppSpacing.lg),
                          Text('Order details shared'),
                        ],
                      ),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share Order'),
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

            // Download PDF Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.download_rounded, color: Colors.white),
                          SizedBox(width: AppSpacing.lg),
                          Text('PDF downloaded'),
                        ],
                      ),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Order (PDF)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order.status) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Waiting for confirmation...';
        statusIcon = Icons.hourglass_bottom_rounded;
        break;
      case 'confirmed':
        statusColor = const Color(0xFF3B82F6);
        statusText = 'Order confirmed!';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'in_transit':
        statusColor = const Color(0xFF8B5CF6);
        statusText = 'On the way to you';
        statusIcon = Icons.local_shipping_rounded;
        break;
      case 'delivered':
        statusColor = AppColors.primaryGreen;
        statusText = 'Delivered successfully';
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = AppColors.primaryGreen;
        statusText = 'Order placed';
        statusIcon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.orderId}',
                  style: AppTypography.labelSmall(color: AppColors.textLight),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  statusText,
                  style: AppTypography.labelMedium(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTypography.bodySmall(color: AppColors.textLight),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall(
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep(String step, String title, String description,
      {required bool isCompleted}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primaryGreen
                    : AppColors.borderLight,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 20)
                    : Text(
                        step,
                        style: AppTypography.labelMedium(
                          color: AppColors.textLight,
                        ),
                      ),
              ),
            ),
            if (step != '4')
              Container(
                width: 2,
                height: 30,
                color: isCompleted
                    ? AppColors.primaryGreen
                    : AppColors.borderLight,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium(
                  color: isCompleted
                      ? AppColors.primaryGreen
                      : AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: AppTypography.bodySmall(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}