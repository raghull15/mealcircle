import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import 'Payment_history.dart';

const Color _kPrimaryGreen = Color(0xFF00B562);
const Color _kAccentOrange = Color(0xFFFF6B35);
const Color _kBackgroundCream = Color(0xFFFFFBF7);
const Color _kCardWhite = Color(0xFFFFFFFF);
const Color _kTextDark = Color(0xFF1C1C1C);
const Color _kTextLight = Color(0xFF6B7280);
const Color _kBorderLight = Color(0xFFE5E7EB);

class PaymentsScreen extends StatefulWidget {
  final Map<String, dynamic>? fundRequest;

  const PaymentsScreen({super.key, this.fundRequest});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  String? _selectedAmount;
  String _customAmount = '';
  String? _selectedShelter;

  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _customerIdController = TextEditingController();

  String? _selectedBank;
  bool _isProcessing = false;

  final List<String> _amounts = ['50', '100', '500', '1000', '2000', 'Custom'];
  final List<String> _shelters = [
    'Orphanage',
    'Old Age Home',
    'Animal Shelter',
    'Community Kitchen',
    'General Donation',
  ];

  final List<String> _banks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // If fund request exists, set default values
    if (widget.fundRequest != null) {
      _selectedShelter = widget.fundRequest!['shelterName'];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _upiController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _customerIdController.dispose();
    super.dispose();
  }

  String? get _finalAmount {
    if (_selectedAmount == 'Custom') {
      return _customAmount.isNotEmpty ? _customAmount : null;
    }
    return _selectedAmount;
  }

  Future<void> _processPayment() async {
    final finalAmount = _finalAmount;
    
    if (finalAmount == null || _selectedShelter == null) {
      _showSnackBar('Please select amount and charity', isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(finalAmount);
    if (amount == null || amount <= 0) {
      _showSnackBar('Invalid amount', isError: true);
      return;
    }

    final userProvider = context.read<UserProvider>();
    if (amount > userProvider.balance) {
      _showSnackBar('Insufficient balance', isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);

      try {
        final paymentMethod = _getSelectedPaymentMethod();
        await userProvider.addDonation(
          amount: amount,
          charity: _selectedShelter!,
          paymentMethod: paymentMethod,
        );
        
        if (mounted) {
          _showSuccessDialog(amount);
        }
      } catch (e) {
        _showSnackBar('Payment failed: ${e.toString()}', isError: true);
      }
    }
  }

  String _getSelectedPaymentMethod() {
    switch (_tabController.index) {
      case 0:
        return 'UPI';
      case 1:
        return 'Credit Card';
      case 2:
        return 'Net Banking';
      default:
        return 'Unknown';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : _kPrimaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kPrimaryGreen, _kPrimaryGreen.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Successful!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kBackgroundCream,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSuccessRow('Amount', '₹${amount.toStringAsFixed(0)}'),
                    const SizedBox(height: 12),
                    _buildSuccessRow('Donated to', _selectedShelter ?? ''),
                    // Show fund progress if from fund request
                    if (widget.fundRequest != null) ...[
                      const SizedBox(height: 12),
                      _buildSuccessRow(
                        'Fund Progress',
                        '${(((widget.fundRequest!['fundRaised'] ?? 0) + amount) / (widget.fundRequest!['fundTarget'] ?? 1) * 100).toStringAsFixed(0)}%'
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for making a difference!',
                style: GoogleFonts.inter(fontSize: 13, color: _kTextLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: _kTextLight)),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _kTextDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFundRequestBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kAccentOrange, _kAccentOrange.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kAccentOrange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volunteer_activism_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.fundRequest!['fundTitle'] ?? 'Fund Request',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.fundRequest!['fundDescription'] ?? 'Help us reach our goal',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${widget.fundRequest!['fundRaised']?.toStringAsFixed(0) ?? 0} of ₹${widget.fundRequest!['fundTarget']?.toStringAsFixed(0) ?? 0}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${((widget.fundRequest!['fundRaised'] ?? 0) / (widget.fundRequest!['fundTarget'] ?? 1) * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (widget.fundRequest!['fundRaised'] ?? 0) /
                      (widget.fundRequest!['fundTarget'] ?? 1),
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Serving ${widget.fundRequest!['servingsPeople'] ?? 0} people',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Fund Request Banner
            if (widget.fundRequest != null)
              _buildFundRequestBanner(),
              
            _buildAmountSection(),
            const SizedBox(height: 20),
            _buildShelterSection(),
            const SizedBox(height: 24),
            _buildPaymentMethodCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildPayButton(),
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
                    widget.fundRequest != null ? 'Help a Cause' : 'Donate Money',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentHistoryScreen(),
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

  Widget _buildAmountSection() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kCardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kAccentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: _kAccentOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Donation Amount',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Your contribution makes a real difference',
              style: GoogleFonts.inter(fontSize: 13, color: _kTextLight),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _amounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAmount = amount),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                _kPrimaryGreen,
                                _kPrimaryGreen.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: isSelected ? null : _kBackgroundCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? _kPrimaryGreen : _kBorderLight,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _kPrimaryGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      amount == 'Custom' ? amount : '₹$amount',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : _kTextDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_selectedAmount == 'Custom') ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: _kBackgroundCream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kBorderLight, width: 1),
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() => _customAmount = value),
                  style: GoogleFonts.inter(fontSize: 16, color: _kTextDark),
                  decoration: InputDecoration(
                    hintText: 'Enter custom amount',
                    prefixText: '₹ ',
                    prefixStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _kTextDark,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      color: _kTextLight,
                    ),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShelterSection() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kCardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kPrimaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.favorite, color: _kPrimaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Charity/Shelter',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Choose where your donation goes',
              style: GoogleFonts.inter(fontSize: 13, color: _kTextLight),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _kBackgroundCream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBorderLight, width: 1),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedShelter,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                hint: Text(
                  'Select Charity/Shelter',
                  style: GoogleFonts.inter(fontSize: 14, color: _kTextLight),
                ),
                items: _shelters.map((shelter) {
                  return DropdownMenuItem(
                    value: shelter,
                    child: Text(
                      shelter,
                      style: GoogleFonts.inter(fontSize: 14, color: _kTextDark),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedShelter = value),
                icon: Icon(Icons.expand_more, color: _kTextLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _kCardWhite,
          borderRadius: BorderRadius.circular(20),
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.payment, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Payment Method',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kTextDark,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: _kBackgroundCream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: _kTextLight,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kPrimaryGreen, _kPrimaryGreen.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: const EdgeInsets.all(6),
                tabs: [
                  Tab(
                    child: Text(
                      'UPI',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Card',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Net Banking',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 420,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUPITab(),
                  _buildCardTab(),
                  _buildNetBankingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUPITab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kPrimaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kPrimaryGreen.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _kPrimaryGreen, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter your UPI ID to complete donation',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _kPrimaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildModernInput(
              controller: _upiController,
              label: 'UPI ID',
              hint: 'example@upi',
              icon: Icons.account_balance_wallet,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter UPI ID';
                if (!value.contains('@')) return 'Invalid UPI ID format';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Or Pay via',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _kTextLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUPIAppIcon('GPay', const Color(0xFF00A86B)),
                _buildUPIAppIcon('PhonePe', const Color(0xFF5F259F)),
                _buildUPIAppIcon('Paytm', const Color(0xFF00BAF2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUPIAppIcon(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCardTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildModernInput(
              controller: _cardNumberController,
              label: 'Card Number',
              hint: '1234 5678 9012 3456',
              icon: Icons.credit_card,
              maxLength: 19,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Card number required';
                if (value.replaceAll(' ', '').length != 16)
                  return 'Invalid card';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModernInput(
                    controller: _expiryController,
                    label: 'Expiry',
                    hint: 'MM/YY',
                    icon: Icons.calendar_today,
                    maxLength: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value))
                        return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernInput(
                    controller: _cvvController,
                    label: 'CVV',
                    hint: '123',
                    icon: Icons.lock,
                    maxLength: 3,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (value.length != 3) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernInput(
              controller: _cardHolderController,
              label: 'Card Holder Name',
              hint: 'John Doe',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Name required';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetBankingTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _kBackgroundCream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBorderLight, width: 1),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedBank,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  prefixIcon: Icon(Icons.account_balance, size: 20),
                ),
                hint: Text(
                  'Select Bank',
                  style: GoogleFonts.inter(fontSize: 14, color: _kTextLight),
                ),
                items: _banks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank, style: GoogleFonts.inter(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedBank = value),
                validator: (value) =>
                    value == null ? 'Please select bank' : null,
              ),
            ),
            const SizedBox(height: 16),
            _buildModernInput(
              controller: _accountNumberController,
              label: 'Account Number',
              hint: '1234567890',
              icon: Icons.account_balance,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildModernInput(
              controller: _ifscController,
              label: 'IFSC Code',
              hint: 'SBIN0001234',
              icon: Icons.code,
              maxLength: 11,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (value.length != 11) return 'Invalid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildModernInput(
              controller: _customerIdController,
              label: 'Customer ID',
              hint: 'Enter Customer ID',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLength = 100,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _kBackgroundCream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorderLight, width: 1),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            maxLength: maxLength,
            style: GoogleFonts.inter(fontSize: 15, color: _kTextDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 14, color: _kTextLight),
              prefixIcon: Icon(icon, color: _kTextLight, size: 20),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _kAccentOrange,
                    _kAccentOrange.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _kAccentOrange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isProcessing ? null : _processPayment,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _isProcessing
                        ? const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _finalAmount != null
                                    ? 'Donate ₹$_finalAmount'
                                    : 'Donate Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}