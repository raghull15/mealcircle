import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/widgets/user_profile_page.dart';
import 'package:mealcircle/Donater/cart_confirmation.dart';
import 'package:mealcircle/Donater/past_donation_manager.dart';
import 'package:mealcircle/Donater/past_donation_page.dart';
import 'package:mealcircle/Donater/recepients.dart';
import 'package:mealcircle/Donater/cart_manager.dart';
import 'package:mealcircle/widgets/user_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CartDetailsPage extends StatefulWidget {
  final List<DonationItem> donations;

  const CartDetailsPage({super.key, required this.donations});

  @override
  State<CartDetailsPage> createState() => _CartDetailsPageState();
}

class _CartDetailsPageState extends State<CartDetailsPage>
    with SingleTickerProviderStateMixin {
  bool _isSaving = true;
  bool _isGeneratingPDF = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  final _userService = UserService(); 

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _saveToPastDonations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveToPastDonations() async {
    final manager = PastDonationManager();

    List<Map<String, dynamic>> donationDataList = [];

    for (var donation in widget.donations) {
      DateTime donationDateTime;
      try {
        final DateFormat formatter = DateFormat("MMM d, yyyy 'at' h:mm a");
        donationDateTime = formatter.parse(donation.dateTime);
      } catch (e) {
        donationDateTime = DateTime.now();
      }

      final pastDonation = PastDonation(
        shelterItem: donation.shelterItem,
        foodType: donation.foodType,
        quantity: donation.quantity,
        donationDate: donationDateTime,
        status: donation.isCancelled ? "Cancelled" : "Delivered",
        recipientName: donation.recipientName,
        recipientAddress: donation.recipientAddress,
        recipientPhone: donation.recipientPhone,
        deliveryByDonor: donation.deliveryByDonor,
        cancellationReason: donation.isCancelled
            ? donation.cancellationReason
            : null,
      );

      manager.addDonation(pastDonation);

      if (!donation.isCancelled) {
        donationDataList.add({
          'quantity': donation.quantity,
          'shelterName': donation.shelterItem['name'] ?? 'Unknown',
          'shelterId':
              '${donation.shelterItem['id'] ?? donation.shelterItem['name']}',
          'isCancelled': false,
        });
      }
    }

    if (donationDataList.isNotEmpty) {
      await _userService.addMultipleDonations(donationDataList);
      print('✅ User statistics updated: ${donationDataList.length} donations');
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _generateAndDownloadPDF() async {
    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      final pdf = pw.Document();
      final checkIcon = pw.MemoryImage(
        (await rootBundle.load('assets/correct.png')).buffer.asUint8List(),
      );

      final crossIcon = pw.MemoryImage(
        (await rootBundle.load('assets/wrong.png')).buffer.asUint8List(),
      );

      final confirmedDonations = widget.donations
          .where((d) => !d.isCancelled)
          .toList();
      final cancelledDonations = widget.donations
          .where((d) => d.isCancelled)
          .toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DONATION INVOICE',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Thank you for your generous contribution!',
                      style: const pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Invoice Date:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        DateFormat('MMM dd, yyyy').format(DateTime.now()),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Invoice #',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPDFStat(
                      'Total Donations',
                      '${widget.donations.length}',
                    ),
                    _buildPDFStat('Confirmed', '${confirmedDonations.length}'),
                    _buildPDFStat('Cancelled', '${cancelledDonations.length}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              if (confirmedDonations.isNotEmpty) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Image(checkIcon, width: 14, height: 14),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        'CONFIRMED DONATIONS',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                ...confirmedDonations.asMap().entries.map((entry) {
                  return _buildPDFDonationCard(
                    entry.value,
                    entry.key + 1,
                    true,
                  );
                }).toList(),
              ],

              if (cancelledDonations.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Image(crossIcon, width: 14, height: 14),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        'CANCELLED DONATIONS',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red900,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                ...cancelledDonations.asMap().entries.map((entry) {
                  return _buildPDFDonationCard(
                    entry.value,
                    entry.key + 1,
                    false,
                  );
                }).toList(),
              ],

              pw.SizedBox(height: 30),

              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'MealCircle - Connecting Donors with Those in Need',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on ${DateFormat('MMM dd, yyyy at hh:mm a').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invoice generated successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error generating invoice: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  pw.Widget _buildPDFStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildPDFDonationCard(
    DonationItem donation,
    int index,
    bool isConfirmed,
  ) {
    final shelter = donation.shelterItem;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: isConfirmed ? PdfColors.green50 : PdfColors.red50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: isConfirmed ? PdfColors.green300 : PdfColors.red300,
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Donation #$index: ${shelter["name"] ?? "Shelter"}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(height: 16, color: PdfColors.grey400),

          _buildPDFInfoRow('Food Type:', donation.foodType),
          _buildPDFInfoRow('Quantity:', '${donation.quantity} servings'),
          _buildPDFInfoRow('Date/Time:', donation.dateTime),

          pw.SizedBox(height: 8),
          pw.Divider(height: 16, color: PdfColors.grey400),

          pw.Text(
            'Recipient Details:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _buildPDFInfoRow('Name:', donation.recipientName),
          _buildPDFInfoRow('Address:', donation.recipientAddress),
          _buildPDFInfoRow('Phone:', donation.recipientPhone),

          if (isConfirmed) ...[
            pw.SizedBox(height: 8),
            pw.Divider(height: 16, color: PdfColors.grey400),
            _buildPDFInfoRow(
              'Delivery Method:',
              donation.deliveryByDonor
                  ? 'Delivered by donor'
                  : 'Picked up by recipient',
            ),
          ],

          if (!isConfirmed) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.red100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'Cancellation Reason: ${donation.cancellationReason.isEmpty ? "Not specified" : donation.cancellationReason}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.red900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPDFInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color successGreen = Color(0xFF2AC962);

    final confirmedDonations = widget.donations
        .where((d) => !d.isCancelled)
        .toList();
    final cancelledDonations = widget.donations
        .where((d) => d.isCancelled)
        .toList();
    final bool hasConfirmed = confirmedDonations.isNotEmpty;

    if (_isSaving) {
      return Scaffold(
        backgroundColor: const Color(0xFFEDE8E5),
        body: const Center(
          child: CircularProgressIndicator(color: successGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E5),
      appBar: _buildTopBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasConfirmed
                            ? successGreen.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        border: Border.all(
                          color: hasConfirmed ? successGreen : Colors.red,
                          width: 6,
                        ),
                      ),
                      child: RotationTransition(
                        turns: _rotationAnimation,
                        child: Center(
                          child: Icon(
                            hasConfirmed ? Icons.check_circle : Icons.cancel,
                            color: hasConfirmed ? successGreen : Colors.red,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    hasConfirmed
                        ? "Donation Successful!"
                        : "All Donations Cancelled",
                    style: GoogleFonts.playfairDisplay(
                      color: hasConfirmed ? successGreen : Colors.red,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasConfirmed
                        ? "Thank you for your generous contribution!"
                        : "You can donate again anytime",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Donation Summary",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        "${widget.donations.length}",
                        "Total",
                        Colors.blue.shade700,
                        Icons.list_alt,
                      ),
                      Container(
                        height: 60,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _buildStatColumn(
                        "${confirmedDonations.length}",
                        "Confirmed",
                        Colors.green.shade700,
                        Icons.check_circle_outline,
                      ),
                      Container(
                        height: 60,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _buildStatColumn(
                        "${cancelledDonations.length}",
                        "Cancelled",
                        Colors.red.shade700,
                        Icons.cancel_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (confirmedDonations.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Confirmed Donations",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...confirmedDonations.map((donation) {
                return _buildDonationCard(donation, true);
              }).toList(),
              const SizedBox(height: 20),
            ],

            if (cancelledDonations.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red.shade700, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "Cancelled Donations",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...cancelledDonations.map((donation) {
                return _buildDonationCard(donation, false);
              }).toList(),
              const SizedBox(height: 20),
            ],

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successGreen,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      CartManager().clearCart();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecipientsScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: Text(
                      "Done",
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.orange.shade600, width: 2),
                    ),
                    onPressed: _isGeneratingPDF
                        ? null
                        : _generateAndDownloadPDF,
                    icon: _isGeneratingPDF
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orange.shade600,
                            ),
                          )
                        : Icon(Icons.download, color: Colors.orange.shade600),
                    label: Text(
                      _isGeneratingPDF ? "Generating..." : "Download Invoice",
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    const successGreen = Color(0xFF2AC962);
    const double customHeight = 74.0;

    return PreferredSize(
      preferredSize: const Size.fromHeight(customHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: successGreen,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: customHeight,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
            onPressed: () {
              CartManager().clearCart();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RecipientsScreen()),
                (route) => false,
              );
            },
          ),
          title: Text(
            "Donation Complete",
            style: GoogleFonts.imFellGreatPrimerSc(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfilePage()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDonationCard(DonationItem donation, bool isConfirmed) {
    final shelter = donation.shelterItem;
    final Color cardColor = isConfirmed
        ? Colors.green.shade50
        : Colors.red.shade50;
    final Color borderColor = isConfirmed
        ? Colors.green.shade300
        : Colors.red.shade300;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              shelter["image"] ?? "https://via.placeholder.com/50",
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
                  shelter["name"] ?? "Shelter",
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${donation.foodType} • ${donation.quantity} servings",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isConfirmed ? Icons.check_circle : Icons.cancel,
            color: isConfirmed ? Colors.green.shade700 : Colors.red.shade700,
            size: 28,
          ),
        ],
      ),
    );
  }
}
