import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/screens/DonationStatusPage.dart';
const Color _kPrimaryColor = Color(0xFF2AC962);

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
        return AlertDialog(
          title: Text(
            'Reason for Cancellation',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _reasonControllers[index],
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter reason for cancellation...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
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
                backgroundColor: Colors.red.shade400,
              ),
              child: Text(
                'Confirm Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style:
          GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
              'Donation ${index + 1}: ${shelter['name'] ?? 'Shelter'}'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCancelled ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCancelled ? Colors.red.shade300 : Colors.black12,
                width: isCancelled ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        shelter['image'] ?? 'https://via.placeholder.com/50',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shelter['name'] ?? 'Community Shelter',
                            style: GoogleFonts.playfairDisplay(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isCancelled)
                            Text(
                              'CANCELLED',
                              style: GoogleFonts.poppins(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildSectionTitle('Your Donation'),
                const SizedBox(height: 8),
                _buildInfoRow('Food Type:', donation.foodType),
                _buildInfoRow('Quantity (servings):',
                    '${donation.quantity} servings'),
                _buildInfoRow('Date/Time Available:', donation.dateTime),
                const SizedBox(height: 16),
                _buildSectionTitle('Recipient Details'),
                const SizedBox(height: 8),
                _buildInfoRow('Name:', donation.recipientName),
                _buildInfoRow('Address:', donation.recipientAddress),
                _buildInfoRow('Phone.no:', donation.recipientPhone),
                const SizedBox(height: 16),
                _buildSectionTitle('Delivery Method'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      donation.deliveryByDonor
                          ? Icons.local_shipping
                          : Icons.person_pin_circle,
                      color: donation.deliveryByDonor
                          ? _kPrimaryColor
                          : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        donation.deliveryByDonor
                            ? 'The food will be delivered by the donor'
                            : 'The recipient will pickup the food',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'Do you want to cancel this donation?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isCancelled
                            ? null
                            : () {
                                _showReasonDialog(index);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          disabledBackgroundColor: Colors.grey.shade300,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Yes',
                          style: GoogleFonts.poppins(
                            color:
                                isCancelled ? Colors.grey.shade600 : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isCancelled
                            ? () {
                                setState(() {
                                  _currentDonations[index].isCancelled = false;
                                  _currentDonations[index].cancellationReason = '';
                                  _reasonControllers[index]?.clear();
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          disabledBackgroundColor: Colors.grey.shade300,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'No',
                          style: GoogleFonts.poppins(
                            color:
                                isCancelled ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isCancelled) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancellation Reason:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          donation.cancellationReason,
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
        ],
      ),
    );
  }
  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
      decoration: BoxDecoration(
        color: _kPrimaryColor, 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 3, 
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
            ),
          ),
          Text(
            'Donation Confirmation',
            style: GoogleFonts.imFellGreatPrimerSc(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.person_outline, color: Colors.white, size: 25),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    final confirmedCount =
        _currentDonations.where((item) => !item.isCancelled).length;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: confirmedCount > 0
            ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DonationStatusPage(
                      donations: _currentDonations,
                    ),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          disabledBackgroundColor: Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          confirmedCount > 0
              ? 'Proceed to Confirmation'
              : 'Cancel All Donations First',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int confirmedDonations =
        _currentDonations.where((item) => !item.isCancelled).length;
    final int cancelledDonations =
        _currentDonations.where((item) => item.isCancelled).length;

    return Scaffold(
      backgroundColor: _kPrimaryColor, 
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${_currentDonations.length}',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  'Total',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$confirmedDonations',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  'Confirmed',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$cancelledDonations',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                Text(
                                  'Cancelled',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_currentDonations.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40, bottom: 40),
                          child: Center(
                            child: Text(
                              'No donations to process.',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ..._currentDonations.asMap().entries.map((entry) {
                        return _buildSingleDonationCard(entry.value, entry.key);
                      }).toList(),
                      const SizedBox(height: 24),
                      if (_currentDonations.isNotEmpty)
                        _buildProceedButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}