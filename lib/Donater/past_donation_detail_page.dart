import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/widgets/user_profile_page.dart';
import 'package:mealcircle/Donater/past_donation_page.dart';

const Color _kPrimaryColor = Color(0xFF2AC962);

class PastDonationDetailPage extends StatelessWidget {
  final PastDonation donation;

  const PastDonationDetailPage({
    super.key,
    required this.donation,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = donation.status == "Cancelled";
    final Color statusColor =
        isCancelled ? Colors.red.shade700 : Colors.green.shade700;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E5),
      appBar: _buildTopBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                color: isCancelled
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCancelled
                      ? Colors.red.shade200
                      : Colors.green.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCancelled ? Icons.cancel : Icons.check_circle,
                    color: statusColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCancelled
                        ? "DONATION CANCELLED"
                        : "DONATION COMPLETED",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Shelter Information"),
            const SizedBox(height: 10),
            _buildCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      donation.shelterItem["image"] ?? "https://via.placeholder.com/150",
                      height: 75,
                      width: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[300], height: 75, width: 90),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.shelterItem["name"] ?? "Shelter Name",
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                donation.shelterItem["location"] ?? "N/A",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              donation.shelterItem["phone"] ?? "N/A",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
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
                  _buildDetailRow(Icons.fastfood, "Food Type", donation.foodType),
                  const Divider(height: 24),
                  _buildDetailRow(
                      Icons.local_dining, "Quantity", "${donation.quantity} servings"),
                  const Divider(height: 24),
                  _buildDetailRow(
                    Icons.date_range,
                    "Donation Date",
                    DateFormat('MMM dd, yyyy').format(donation.donationDate),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    Icons.access_time,
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
                  _buildDetailRow(Icons.person, "Name", donation.recipientName),
                  const Divider(height: 24),
                  _buildDetailRow(
                      Icons.home, "Address", donation.recipientAddress),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.phone, "Phone", donation.recipientPhone),
                ],
              ),
            ),
            // Only show Delivery Method if NOT cancelled
            if (!isCancelled) ...[
              const SizedBox(height: 20),
              _buildSectionTitle("Delivery Method"),
              const SizedBox(height: 10),
              _buildCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        donation.deliveryByDonor
                            ? Icons.local_shipping
                            : Icons.person_pin_circle,
                        color: donation.deliveryByDonor
                            ? _kPrimaryColor
                            : Colors.orange,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        donation.deliveryByDonor
                            ? 'The food was delivered by the donor'
                            : 'The recipient picked up the food',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Show cancellation details if cancelled
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
                        Icon(Icons.cancel, color: Colors.red.shade700, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          "Reason for Cancellation",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      donation.cancellationReason ?? "No reason provided",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.red.shade600,
                      ),
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
    const double customHeight = 74.0;

    return PreferredSize(
      preferredSize: const Size.fromHeight(customHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: _kPrimaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              offset: Offset(0, .2),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: customHeight,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Donation Details",
            style: GoogleFonts.imFellGreatPrimerSc(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline,
                  color: Colors.white, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserProfilePage(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCard({required Widget child, Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
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
            color: _kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: _kPrimaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}