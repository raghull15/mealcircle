import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/Donater/cart_details_page.dart';
import 'package:mealcircle/services/user_profile_page.dart';

import 'package:mealcircle/shared/design_system.dart';

// Modern color replacements handled by DesignSystem

class DonationItem {
  final Map<String, dynamic> shelterItem;
  final String foodType;
  final int quantity;
  final String dateTime;
  final String recipientName;
  final String recipientAddress;
  final String recipientPhone;
  final bool deliveryByDonor;
  bool isCancelled;
  String cancellationReason;

  DonationItem({
    required this.shelterItem,
    required this.foodType,
    required this.quantity,
    required this.dateTime,
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientPhone,
    required this.deliveryByDonor,
    this.isCancelled = false,
    this.cancellationReason = '',
  });
}

class DonationConfirmationPage extends StatefulWidget {
  final List<DonationItem> confirmedDonations;

  const DonationConfirmationPage({
    super.key,
    required this.confirmedDonations,
  });

  @override
  State<DonationConfirmationPage> createState() =>
      _DonationConfirmationPageState();
}

class _DonationConfirmationPageState extends State<DonationConfirmationPage> {
  late List<DonationItem> _currentDonations;
  late Map<int, TextEditingController> _reasonControllers;

  @override
  void initState() {
    super.initState();
    _currentDonations = List.from(widget.confirmedDonations);
    _reasonControllers = {};
    for (int i = 0; i < _currentDonations.length; i++) {
      _reasonControllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _reasonControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showReasonDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.accentOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cancellation Reason',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _reasonControllers[index],
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter reason for cancellation...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundCream,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentDonations[index].isCancelled = true;
                              _currentDonations[index].cancellationReason =
                                  _reasonControllers[index]!.text.isNotEmpty
                                      ? _reasonControllers[index]!.text
                                      : 'No reason provided';
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                          ),
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleDonationCard(DonationItem donation, int index) {
    final shelter = donation.shelterItem;
    final isCancelled = donation.isCancelled;

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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isCancelled ? Colors.red.shade50 : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCancelled ? Colors.red.shade200 : AppColors.borderLight,
            width: isCancelled ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      shelter['image'] ?? 'https://via.placeholder.com/50',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.2),
                              AppColors.accentOrange.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          size: 28,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shelter['name'] ?? 'Shelter',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (isCancelled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'CANCELLED',
                              style: GoogleFonts.inter(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.borderLight, height: 1),
              const SizedBox(height: 16),
              _buildSectionTitle('Donation Details:'),
              const SizedBox(height: 12),
              _buildInfoRow('Food Type:', donation.foodType),
              _buildInfoRow(
                'Quantity:',
                '${donation.quantity} servings',
              ),
              _buildInfoRow('Available:', donation.dateTime),
              const SizedBox(height: 16),
              _buildSectionTitle('Recipient Details:'),
              const SizedBox(height: 12),
              _buildInfoRow('Name:', donation.recipientName),
              _buildInfoRow('Address:', donation.recipientAddress),
              _buildInfoRow('Phone:', donation.recipientPhone),
              const SizedBox(height: 16),
              _buildSectionTitle('Delivery Method:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: donation.deliveryByDonor
                          ? AppColors.primaryGreen.withOpacity(0.1)
                          : AppColors.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      donation.deliveryByDonor
                          ? Icons.local_shipping_rounded
                          : Icons.person_pin_circle_rounded,
                      color: donation.deliveryByDonor
                          ? AppColors.primaryGreen
                          : AppColors.accentOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      donation.deliveryByDonor
                          ? 'Delivered by donor'
                          : 'Picked up by recipient',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.borderLight, height: 1),
              const SizedBox(height: 16),
              Text(
                'Cancel this donation?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!isCancelled) {
                          _showReasonDialog(index);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCancelled
                            ? AppColors.textLight.withOpacity(0.2)
                            : AppColors.accentOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: isCancelled ? 0 : 2,
                      ),
                      child: Text(
                        'Yes',
                        style: GoogleFonts.poppins(
                          color: isCancelled ? AppColors.textLight : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isCancelled) {
                          setState(() {
                            _currentDonations[index].isCancelled = false;
                            _currentDonations[index].cancellationReason = '';
                            _reasonControllers[index]?.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCancelled
                            ? AppColors.primaryGreen
                            : AppColors.borderLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(
                        'No',
                        style: GoogleFonts.poppins(
                          color: isCancelled ? Colors.white : AppColors.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isCancelled) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason:',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        donation.cancellationReason,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
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
            colors: [
              AppColors.primaryGreen,
              AppColors.primaryGreen.withOpacity(0.85),
            ],
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
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Donation Confirmation',
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
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserProfilePage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    final confirmedCount =
        _currentDonations.where((item) => !item.isCancelled).length;
    final isValid = confirmedCount > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid
            ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartDetailsPage(
                      donations: _currentDonations,
                    ),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor: AppColors.textLight.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
        ),
        child: Text(
          'Proceed to Donation',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmedDonations =
        _currentDonations.where((item) => !item.isCancelled).length;
    final cancelledDonations =
        _currentDonations.where((item) => item.isCancelled).length;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: _buildTopBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        'Total',
                        '${_currentDonations.length}',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        'Confirmed',
                        '$confirmedDonations',
                        AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        'Cancelled',
                        '$cancelledDonations',
                        AppColors.accentOrange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_currentDonations.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.textLight.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No donations to process',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              ..._currentDonations.asMap().entries.map((entry) {
                return _buildSingleDonationCard(entry.value, entry.key);
              }).toList(),
              const SizedBox(height: 24),
              _buildProceedButton(context),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}