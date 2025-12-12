import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 
import 'package:mealcircle/screens/cart_confirmation.dart';

class DonationDetailsPage extends StatelessWidget {
  final List<DonationItem> donations;

  const DonationDetailsPage({
    super.key,
    required this.donations,
  });

  DateTime? _parseDateTime(dynamic rawDate) {
    if (rawDate is String) {
      try {
        return DateTime.parse(rawDate);
      } catch (_) {
        try {
          final DateFormat customFormatter = DateFormat("MMM dd, yyyy 'at' hh:mm a");
          return customFormatter.parseStrict(rawDate, true); 
        } catch (e) {
          debugPrint('Error parsing date string: $rawDate, Error: $e');
          return null;
        }
      }
    }
    return rawDate is DateTime ? rawDate : null; 
  }

  PreferredSizeWidget _buildCustomShadowTopBar(BuildContext context) {
    const Color primaryColor = Color(0xFF2AC962);
    const double customHeight = 74.0;

    return PreferredSize(
      preferredSize: const Size.fromHeight(customHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black, 
              blurRadius: 3.5,
              offset: Offset(0, .5),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: customHeight,
          automaticallyImplyLeading: false,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
              icon: const Icon(Icons.person_outline, color: Colors.white, size: 26),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmedDonations = donations.where((d) => !d.isCancelled).toList();
    final cancelledDonations = donations.where((d) => d.isCancelled).toList();

    return Scaffold(
      appBar: _buildCustomShadowTopBar(context), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(confirmedDonations.length, cancelledDonations.length),
            const SizedBox(height: 20),
            if (confirmedDonations.isNotEmpty)
              _buildSection(
                title: "Confirmed Donations (${confirmedDonations.length})",
                icon: Icons.check_circle,
                color: Colors.green.shade700,
                list: confirmedDonations,
                isConfirmed: true,
              ),
            if (confirmedDonations.isNotEmpty && cancelledDonations.isNotEmpty)
              const SizedBox(height: 30),
            if (cancelledDonations.isNotEmpty)
              _buildSection(
                title: "Cancelled Donations (${cancelledDonations.length})",
                icon: Icons.cancel,
                color: Colors.red.shade700,
                list: cancelledDonations,
                isConfirmed: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(int confirmedCount, int cancelledCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatDetail(
            "Total Items",
            "${confirmedCount + cancelledCount}",
            Colors.blue.shade700,
          ),
          Container(height: 40, width: 1, color: Colors.blue.shade200),
          _buildStatDetail(
            "Confirmed",
            "$confirmedCount",
            Colors.green.shade700,
          ),
          Container(height: 40, width: 1, color: Colors.blue.shade200),
          _buildStatDetail(
            "Cancelled",
            "$cancelledCount",
            Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetail(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<DonationItem> list,
    required bool isConfirmed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...list.map((donation) {
          return _buildDetailCard(donation, isConfirmed, color);
        }).toList(),
      ],
    );
  }

  Widget _buildDetailCard(
      DonationItem donation, bool isConfirmed, Color statusColor) {
    final shelter = donation.shelterItem;

    final dynamic donationDateTimeRaw = donation.dateTime; 
    final DateTime? donationTimeParsed = _parseDateTime(donationDateTimeRaw);
    
    final String formattedDate = donationTimeParsed != null
        ? DateFormat('MMM dd, yyyy').format(donationTimeParsed)
        : 'Date N/A';
    final String formattedTime = donationTimeParsed != null
        ? DateFormat('hh:mm a').format(donationTimeParsed)
        : 'Time N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    shelter["image"] ?? "https://via.placeholder.com/60",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shelter["name"] ?? "Unknown Shelter",
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        icon: Icons.fastfood,
                        label: "Food Type",
                        value: donation.foodType,
                        color: Colors.grey.shade600,
                      ),
                      _buildInfoRow(
                        icon: Icons.local_dining,
                        label: "Servings",
                        value: "${donation.quantity} servings",
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.date_range,
                    label: "Donation Date",
                    value: formattedDate,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.access_time,
                    label: "Time",
                    value: formattedTime,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            if (!isConfirmed) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status: CANCELLED",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Reason: ${donation.cancellationReason.isEmpty ? 'Not specified' : donation.cancellationReason}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.8)),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}