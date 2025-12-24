import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/user_provider.dart';
import '../services/user_model.dart';

const Color _kPrimaryGreen = Color(0xFF00B562);
const Color _kBackgroundCream = Color(0xFFFFFBF7);
const Color _kCardWhite = Color(0xFFFFFFFF);
const Color _kTextDark = Color(0xFF1C1C1C);
const Color _kTextLight = Color(0xFF6B7280);
const Color _kBorderLight = Color(0xFFE5E7EB);
const Color _kSuccessLight = Color(0xFFECFDF3);
const Color _kSuccessMedium = Color(0xFF6CE9A6);

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Recent',
    'This Month',
    'Last Month',
  ];
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    // Refresh user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      userProvider.refresh();
    });
  }

  Future<void> _handleRefresh() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.refresh();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                'History refreshed',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: _kPrimaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // Generate individual receipt PDF
  Future<void> _generateReceiptPDF(DonationTransaction donation) async {
    setState(() => _isGeneratingPDF = true);

    try {
      final pdf = pw.Document();
      
      // Load rupee symbol image
      final rupeeImage = await rootBundle.load('assets/rupee.png');
      final rupeeImageBytes = rupeeImage.buffer.asUint8List();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with logo/branding
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [PdfColors.green, PdfColors.green700],
                    ),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
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
                        'DONATION RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 30),
                
                // Receipt Details Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          _buildReceiptField('Receipt Number:', 
                            'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                          _buildReceiptField('Date:', 
                            DateFormat('dd MMM yyyy').format(donation.date)),
                        ],
                      ),
                      pw.SizedBox(height: 20),
                      pw.Divider(color: PdfColors.grey400),
                      pw.SizedBox(height: 20),
                      
                      // Transaction Details
                      pw.Text(
                        'TRANSACTION DETAILS',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      
                      _buildReceiptRow('Transaction ID:', donation.id),
                      _buildReceiptRow('Date & Time:', 
                        DateFormat('dd MMM yyyy, hh:mm a').format(donation.date)),
                      _buildReceiptRow('Payment Method:', donation.paymentMethod),
                      _buildReceiptRow('Status:', donation.status),
                      
                      pw.SizedBox(height: 20),
                      pw.Divider(color: PdfColors.grey400),
                      pw.SizedBox(height: 20),
                      
                      pw.Text(
                        'DONATION DETAILS',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      
                      _buildReceiptRow('Beneficiary:', donation.charity),
                      _buildReceiptRow('Purpose:', 'Food Donation'),
                      
                      pw.SizedBox(height: 20),
                      pw.Divider(color: PdfColors.grey400),
                      pw.SizedBox(height: 20),
                      
                      // Amount Section with rupee image
                      pw.Container(
                        padding: const pw.EdgeInsets.all(15),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green50,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: PdfColors.green200),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'DONATION AMOUNT',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green900,
                              ),
                            ),
                            pw.Row(
                              children: [
                                pw.Image(
                                  pw.MemoryImage(rupeeImageBytes),
                                  width: 16,
                                  height: 16,
                                ),
                                pw.SizedBox(width: 4),
                                pw.Text(
                                  donation.amount.toStringAsFixed(2),
                                  style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green900,
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
                
                pw.SizedBox(height: 30),
                
                // Thank you message
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Thank You!',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Your generous donation helps us provide meals to those in need. '
                        'Together, we are making a difference in our community.',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.Spacer(),
                
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'MealCircle Foundation',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.Text(
                          'Connecting Donors with Those in Need',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                        ),
                        
                      ],
                    ),
                    pw.Text(
                      'www.mealcircle.org',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Receipt_${donation.id}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Receipt downloaded successfully!',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: _kPrimaryGreen,
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
            content: Text('Error generating receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPDF = false);
      }
    }
  }

  pw.Widget _buildReceiptField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndDownloadPDF(UserProvider userProvider) async {
    setState(() => _isGeneratingPDF = true);

    try {
      final pdf = pw.Document();
      final donations = userProvider.donations;
      
      final rupeeImage = await rootBundle.load('assets/rupee.png');
      final rupeeImageBytes = rupeeImage.buffer.asUint8List();

      double totalDonated = 0;
      int successfulCount = 0;

      for (var donation in donations) {
        if (donation.status == 'Successful') {
          totalDonated += donation.amount;
          successfulCount++;
        }
      }

      final uniqueCharities = donations.map((d) => d.charity).toSet().length;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header section with gradient effect
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
                      'DONATION STATEMENT',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Thank you for your generous contributions!',
                      style: const pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              
              // Statement info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Statement Date:',
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
                        'Statement #',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'STM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
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
              
              // Statistics section with rupee symbol
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.green200),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildPDFStatWithRupee(
                          'Total Donated',
                          totalDonated.toStringAsFixed(2),
                          rupeeImageBytes,
                          true,
                        ),
                        _buildPDFStat(
                          'Successful',
                          '$successfulCount',
                          false,
                        ),
                        _buildPDFStat(
                          'Total Donations',
                          '${donations.length}',
                          false,
                        ),
                        _buildPDFStat(
                          'Charities',
                          '$uniqueCharities',
                          false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              
              // Transaction history header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'TRANSACTION HISTORY',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green900,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              
              // Transaction cards with rupee symbols
              ...donations.asMap().entries.map((entry) {
                return _buildPDFTransactionCardWithRupee(
                  entry.value, 
                  entry.key + 1,
                  rupeeImageBytes,
                );
              }).toList(),
              
              pw.SizedBox(height: 30),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              
              // Footer
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
        name: 'Donation_Statement_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.pdf',
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
                    'Statement generated successfully!',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: _kPrimaryGreen,
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
                    'Error generating statement: $e',
                    style: GoogleFonts.inter(color: Colors.white),
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

  // New helper method for PDF stats with rupee image
  pw.Widget _buildPDFStatWithRupee(
    String label, 
    String value, 
    Uint8List rupeeImage,
    bool isLarge,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Image(
              pw.MemoryImage(rupeeImage),
              width: isLarge ? 18 : 14,
              height: isLarge ? 18 : 14,
            ),
            pw.SizedBox(width: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: isLarge ? 20 : 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),
          ],
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

  pw.Widget _buildPDFStat(String label, String value, bool isLarge) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isLarge ? 20 : 16,
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

  // Updated transaction card with rupee image
  pw.Widget _buildPDFTransactionCardWithRupee(
    DonationTransaction donation,
    int index,
    Uint8List rupeeImage,
  ) {
    final isSuccessful = donation.status == 'Successful';

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
                'Transaction #$index',
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
                  donation.status,
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
          _buildPDFInfoRow('Date & Time:', 
            DateFormat('MMM d, yyyy hh:mm a').format(donation.date)),
          _buildPDFInfoRowWithRupee(
            'Amount:', 
            donation.amount.toStringAsFixed(2),
            rupeeImage,
          ),
          _buildPDFInfoRow('Charity/Shelter:', donation.charity),
          _buildPDFInfoRow('Payment Method:', donation.paymentMethod),
          pw.SizedBox(height: 8),
          pw.Divider(height: 16, color: PdfColors.grey400),
          pw.Text(
            'Transaction Details:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _buildPDFInfoRow('Transaction ID:', donation.id),
          _buildPDFInfoRow('Status:', donation.status),
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
            width: 110,
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

  pw.Widget _buildPDFInfoRowWithRupee(
    String label, 
    String value,
    Uint8List rupeeImage,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
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
            child: pw.Row(
              children: [
                pw.Image(
                  pw.MemoryImage(rupeeImage),
                  width: 10,
                  height: 10,
                ),
                pw.SizedBox(width: 2),
                pw.Text(
                  value,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundCream,
      appBar: _buildAppBar(),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: _kPrimaryGreen,
            child: Column(
              children: [
                _buildStats(userProvider),
                _buildFilterSection(userProvider),
                Expanded(
                  child: userProvider.donations.isEmpty
                      ? _buildEmptyState()
                      : _buildDonationsList(userProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kPrimaryGreen, _kPrimaryGreen.withOpacity(0.85)],
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
                    'Payment History',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return IconButton(
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
                      onPressed: _isGeneratingPDF || userProvider.donations.isEmpty
                          ? null
                          : () => _generateAndDownloadPDF(userProvider),
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

  Widget _buildStats(UserProvider userProvider) {
    double totalDonated = 0;
    int successfulCount = 0;

    for (var donation in userProvider.donations) {
      if (donation.status == 'Successful') {
        totalDonated += donation.amount;
        successfulCount++;
      }
    }

    final uniqueCharities = userProvider.donations
        .map((d) => d.charity)
        .toSet()
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kPrimaryGreen, _kPrimaryGreen.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kPrimaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Donated',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${totalDonated.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Successful',
                successfulCount.toString(),
                Icons.check_circle,
              ),
              _buildStatDivider(),
              _buildStatItem(
                'Donations',
                userProvider.donations.length.toString(),
                Icons.receipt,
              ),
              _buildStatDivider(),
              _buildStatItem(
                'Charities',
                uniqueCharities.toString(),
                Icons.favorite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildFilterSection(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction History',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                },
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => _filterOptions
                    .map(
                      (option) => PopupMenuItem(
                        value: option,
                        child: Text(
                          option,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: _selectedFilter == option
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _selectedFilter == option
                                ? _kPrimaryGreen
                                : _kTextDark,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _kCardWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kBorderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list, size: 18, color: _kTextLight),
                      const SizedBox(width: 6),
                      Text(
                        _selectedFilter,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kTextDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: _kTextLight,
                      ),
                    ],
                  ),                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your donation transaction history',
            style: GoogleFonts.inter(fontSize: 13, color: _kTextLight),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kPrimaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history, size: 48, color: _kPrimaryGreen),
            ),
            const SizedBox(height: 24),
            Text(
              'No donations found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No donation records found yet. Make your first donation today!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _kTextLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryGreen,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Donate Now',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsList(UserProvider userProvider) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final donations = userProvider.donations;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: donations.length,
      itemBuilder: (context, index) {
        final donation = donations[index];
        return _buildDonationCard(donation, isMobile);
      },
    );
  }

  Widget _buildDonationCard(DonationTransaction donation, bool isMobile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _kCardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDonationDetails(donation),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMobileDonationCard(donation),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDonationCard(DonationTransaction donation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.charity,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy • hh:mm a').format(donation.date),
                    style: GoogleFonts.inter(fontSize: 12, color: _kTextLight),
                  ),
                ],
              ),
            ),
            Text(
              '₹${donation.amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kTextDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: _kBorderLight),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paid via ${donation.paymentMethod}',
              style: GoogleFonts.inter(fontSize: 12, color: _kTextLight),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _kSuccessLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 12, color: _kPrimaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    donation.status,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _kPrimaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDonationDetails(DonationTransaction donation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kSuccessMedium.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: _kSuccessMedium, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Successful',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM d, yyyy • hh:mm a').format(donation.date),
              style: GoogleFonts.inter(fontSize: 13, color: _kTextLight),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kBackgroundCream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Transaction ID', donation.id),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Amount',
                    '₹${donation.amount.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Charity/Shelter', donation.charity),
                  const SizedBox(height: 16),
                  _buildDetailRow('Payment Method', donation.paymentMethod),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _generateReceiptPDF(donation);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _kPrimaryGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, color: _kPrimaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Download Receipt',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _kPrimaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: _kTextLight)),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _kTextDark,
          ),
        ),
      ],
    );
  }
}