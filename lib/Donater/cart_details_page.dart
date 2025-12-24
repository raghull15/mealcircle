import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/services/user_profile_page.dart';
import 'package:mealcircle/Donater/cart_confirmation.dart';
import 'package:mealcircle/Donater/past_donation_manager.dart';
import 'package:mealcircle/Donater/past_donation_page.dart';
import 'package:mealcircle/Donater/recepients.dart';
import 'package:mealcircle/Donater/cart_manager.dart';
import 'package:mealcircle/services/user_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:mealcircle/shared/design_system.dart';

// Color constants for backward compatibility
const Color _kPrimaryGreen = Color(0xFF00B562);
const Color _kAccentOrange = Color(0xFFFF6B35);
const Color _kBackgroundCream = Color(0xFFFFFBF7);
const Color _kTextDark = Color(0xFF1C1C1C);
const Color _kTextLight = Color(0xFF6B7280);
const Color _kBorderLight = Color(0xFFE5E7EB);
const Color _kCardWhite = Colors.white;

// Traditional color scheme replacements handled by AppColors and AppTypography

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

    final user = await _userService.loadUser();
    final donorEmail = user?.email;
    final List<Map<String, dynamic>> donationDataList = [];

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
        donorEmail: donorEmail,
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
              // Enhanced Header with gradient - matching payment_history design
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColors.green, PdfColors.green700],
                  ),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MealCircle',
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'DONATION INVOICE',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Thank you for your generous contribution!',
                      style: const pw.TextStyle(
                        fontSize: 13,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Invoice info row
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
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.green200),
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

              // Confirmed Donations section
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

              // Cancelled Donations section
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
                      'MealCircle Foundation',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Connecting Donors with Those in Need',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generated on ${DateFormat('MMM dd, yyyy at hh:mm a').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 4),
              
                  ],
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Invoice generated successfully!',
                    style: AppTypography.bodyMedium(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error generating invoice: $e',
                    style: AppTypography.bodyMedium(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
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
            color: PdfColors.green900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
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
    final isSuccessful = isConfirmed;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: isSuccessful ? PdfColors.green50 : PdfColors.red50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: isSuccessful ? PdfColors.green300 : PdfColors.red300,
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Donation #$index: ${shelter["name"] ?? "Shelter"}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: isSuccessful
                      ? PdfColors.green100
                      : PdfColors.red100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  isSuccessful ? 'Confirmed' : 'Cancelled',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: isSuccessful
                        ? PdfColors.green900
                        : PdfColors.red900,
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(height: 16, color: PdfColors.grey400),
          _buildPDFInfoRow('Shelter:', shelter["name"] ?? "Shelter"),
          _buildPDFInfoRow('Food Type:', donation.foodType),
          _buildPDFInfoRow('Quantity:', '${donation.quantity} servings'),
          _buildPDFInfoRow('Date & Time:', donation.dateTime),
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
      padding: const pw.EdgeInsets.only(bottom: 6),
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
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
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
                ),
                Expanded(
                  child: Text(
                    'Donation Complete',
                    style: AppTypography.headingMedium(color: Colors.white),
                  ),
                ),
                // Enhanced download button with loading state
                IconButton(
                  icon: _isGeneratingPDF
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                  onPressed: _isGeneratingPDF
                      ? null
                      : _generateAndDownloadPDF,
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

  Widget _buildStatColumn(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDonationCard(DonationItem donation, bool isConfirmed) {
    final shelter = donation.shelterItem;
    final cardColor = isConfirmed
        ? AppColors.primaryGreen.withOpacity(0.08)
        : Colors.red.withOpacity(0.08);
    final borderColor = isConfirmed
        ? AppColors.primaryGreen.withOpacity(0.2)
        : Colors.red.withOpacity(0.2);

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                shelter["image"] ?? "https://via.placeholder.com/50",
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.2),
                        AppColors.accentOrange.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    size: 24,
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
                    shelter["name"] ?? "Shelter",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${donation.foodType} • ${donation.quantity} servings",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isConfirmed
                    ? AppColors.primaryGreen.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isConfirmed ? Icons.check_circle : Icons.cancel,
                color: isConfirmed ? AppColors.primaryGreen : Colors.red,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmedDonations = widget.donations
        .where((d) => !d.isCancelled)
        .toList();
    final cancelledDonations = widget.donations
        .where((d) => d.isCancelled)
        .toList();
    final hasConfirmed = confirmedDonations.isNotEmpty;
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (_isSaving) {
      return Scaffold(
        backgroundColor: AppColors.backgroundCream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Processing donation...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: _buildTopBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success/Failure Banner
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
                            ? AppColors.primaryGreen.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        border: Border.all(
                          color: hasConfirmed ? AppColors.primaryGreen : Colors.red,
                          width: 6,
                        ),
                      ),
                      child: RotationTransition(
                        turns: _rotationAnimation,
                        child: Center(
                          child: Icon(
                            hasConfirmed ? Icons.check_circle : Icons.cancel,
                            color: hasConfirmed ? AppColors.primaryGreen : Colors.red,
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
                    style: GoogleFonts.poppins(
                      color: hasConfirmed ? AppColors.primaryGreen : Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasConfirmed
                        ? "Thank you for your generous contribution!"
                        : "You can donate again anytime",
                    style: GoogleFonts.inter(
                      color: AppColors.textLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Donation Summary",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        "${widget.donations.length}",
                        "Total",
                        Colors.blue,
                        Icons.list_alt_rounded,
                      ),
                      Container(
                        height: 60,
                        width: 1,
                        color: AppColors.borderLight,
                      ),
                      _buildStatColumn(
                        "${confirmedDonations.length}",
                        "Confirmed",
                        AppColors.primaryGreen,
                        Icons.check_circle_outline,
                      ),
                      Container(
                        height: 60,
                        width: 1,
                        color: AppColors.borderLight,
                      ),
                      _buildStatColumn(
                        "${cancelledDonations.length}",
                        "Cancelled",
                        AppColors.accentOrange,
                        Icons.cancel_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirmed Donations
            if (confirmedDonations.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Confirmed Donations",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                      letterSpacing: -0.3,
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

            // Cancelled Donations
            if (cancelledDonations.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Cancelled Donations",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      letterSpacing: -0.3,
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

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(50),
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
                icon: const Icon(Icons.home_rounded, color: Colors.white),
                label: Text(
                  "Back to Home",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                onPressed: _isGeneratingPDF ? null : _generateAndDownloadPDF,
                icon: _isGeneratingPDF
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : Icon(Icons.download_rounded, color: AppColors.primaryGreen),
                label: Text(
                  _isGeneratingPDF ? "Generating..." : "Download Invoice",
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}