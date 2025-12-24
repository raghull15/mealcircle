import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/services/user_profile_page.dart';
import 'package:mealcircle/Donater/past_donation_page.dart';

import 'package:mealcircle/shared/design_system.dart';

// Traditional color scheme replacements handled by AppColors and AppTypography

class PastDonationDetailPage extends StatelessWidget {
  final PastDonation donation;

  const PastDonationDetailPage({
    super.key,
    required this.donation,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = donation.status == "Cancelled";
    final Color statusColor = isCancelled ? Colors.red : AppColors.primaryGreen;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: _buildTopBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              decoration: BoxDecoration(
                color: isCancelled ? Colors.red.shade50 : AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCancelled
                      ? Colors.red.withOpacity(0.2)
                      : AppColors.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCancelled ? Icons.cancel_rounded : Icons.check_circle_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCancelled ? "DONATION CANCELLED" : "DONATION COMPLETED",
                    style: AppTypography.headingMedium(color: statusColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Shelter Information
            _buildSectionTitle("Shelter Information"),
            const SizedBox(height: 10),
            _buildCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      donation.shelterItem["image"] ??
                          "https://via.placeholder.com/100",
                      height: 80,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        color: AppColors.borderLight,
                        height: 80,
                        width: 100,
                        child: Icon(Icons.home_rounded,
                            size: 40, color: AppColors.textLight),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.shelterItem["name"] ?? "Shelter Name",
                          style: AppTypography.labelLarge(color: AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                donation.shelterItem["location"] ?? "N/A",
                                style: AppTypography.bodySmall(color: AppColors.textLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_rounded,
                                size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              donation.shelterItem["phone"] ?? "N/A",
                              style: AppTypography.bodySmall(color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Donation Details
            _buildSectionTitle("Donation Details"),
            const SizedBox(height: 10),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.restaurant_rounded, "Food Type",
                      donation.foodType),
                  const Divider(height: 18),
                  _buildDetailRow(Icons.local_dining_rounded, "Quantity",
                      "${donation.quantity} servings"),
                  const Divider(height: 18),
                  _buildDetailRow(
                    Icons.calendar_today_rounded,
                    "Donation Date",
                    DateFormat('MMM dd, yyyy')
                        .format(donation.donationDate),
                  ),
                  const Divider(height: 18),
                  _buildDetailRow(
                    Icons.access_time_rounded,
                    "Time",
                    DateFormat('hh:mm a').format(donation.donationDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recipient Details
            _buildSectionTitle("Recipient Details"),
            const SizedBox(height: 10),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.person_rounded, "Name",
                      donation.recipientName),
                  const Divider(height: 18),
                  _buildDetailRow(
                      Icons.home_rounded, "Address", donation.recipientAddress),
                  const Divider(height: 18),
                  _buildDetailRow(
                      Icons.phone_rounded, "Phone", donation.recipientPhone),
                ],
              ),
            ),

            // Delivery Method (only if not cancelled)
            if (!isCancelled) ...[
              const SizedBox(height: 20),
              _buildSectionTitle("Delivery Method"),
              const SizedBox(height: 10),
              _buildCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: donation.deliveryByDonor
                            ? AppColors.primaryGreen.withOpacity(0.1)
                            : AppColors.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        donation.deliveryByDonor
                            ? Icons.local_shipping_rounded
                            : Icons.person_pin_circle_rounded,
                        color: donation.deliveryByDonor
                            ? AppColors.primaryGreen
                            : AppColors.accentOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        donation.deliveryByDonor
                            ? 'The food was delivered by the donor'
                            : 'The recipient picked up the food',
                        style: AppTypography.labelMedium(color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Cancellation Details (only if cancelled)
            if (isCancelled) ...[
              const SizedBox(height: 20),
              _buildSectionTitle("Cancellation Details"),
              const SizedBox(height: 10),
              _buildCard(
                color: Colors.red.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel_rounded,
                            color: Colors.red, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          "Reason for Cancellation",
                          style: AppTypography.labelMedium(color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      donation.cancellationReason ?? "No reason provided",
                      style: AppTypography.bodySmall(color: Colors.red.shade700),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
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
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    "Donation Details",
                    style: AppTypography.headingMedium(color: Colors.white),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.headingSmall(color: AppColors.textDark),
    );
  }

  Widget _buildCard(
      {required Widget child, Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall(color: AppColors.textLight),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: AppTypography.labelMedium(color: AppColors.textDark),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}