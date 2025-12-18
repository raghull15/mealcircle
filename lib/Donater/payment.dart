import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kPrimaryColor = Color(0xFF2AC962);
const Color _kBackgroundColor = Color(0xFFF8F7F5);
const Color _kCardBackground = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1A1A1A);
const Color _kTextSecondary = Color(0xFF666666);

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

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

  final List<String> _amounts = ['50', '100', '500', '1000', 'Custom'];
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _processPayment() async {
    if (_finalAmount == null || _selectedShelter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select amount and charity',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildSuccessDialog(),
      );
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: _kPrimaryColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Successful',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _kTextSecondary,
                        ),
                      ),
                      Text(
                        '₹$_finalAmount',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Donated to',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _kTextSecondary,
                        ),
                      ),
                      Text(
                        _selectedShelter ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for making a difference!',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: _kTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildAmountSection(),
              const SizedBox(height: 20),
              _buildShelterSection(),
              const SizedBox(height: 24),
              _buildPaymentMethodCard(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomSheet: _buildPayButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    const double customHeight = 74.0;
    return PreferredSize(
      preferredSize: const Size.fromHeight(customHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: _kPrimaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: customHeight,
            child: Row(
              children: [
                const SizedBox(width: 4.8),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Donate Money',
                    style: GoogleFonts.imFellGreatPrimerSc(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Donation Amount',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your contribution makes a real difference',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _amounts.map((amount) {
              final isSelected = _selectedAmount == amount;
              return GestureDetector(
                onTap: () => setState(() => _selectedAmount = amount),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimaryColor : _kCardBackground,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? _kPrimaryColor
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _kPrimaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    amount == 'Custom' ? amount : '₹$amount',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : _kTextPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedAmount == 'Custom') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kCardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => _customAmount = value),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: _kTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter custom amount',
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShelterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Charity/Shelter',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose where your donation goes',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _kCardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedShelter,
              isExpanded: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
              hint: Text(
                'Select Charity/Shelter',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              items: _shelters.map((shelter) {
                return DropdownMenuItem(
                  value: shelter,
                  child: Text(
                    shelter,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _kTextPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedShelter = value),
              icon: const Icon(Icons.expand_more, color: _kPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your preferred payment method',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: _kCardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: _kTextSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: _kPrimaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
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
          const SizedBox(height: 16),
          SizedBox(
            height: 380,
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
    );
  }

  Widget _buildUPITab() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _kPrimaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _kPrimaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter your UPI ID to complete the donation',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _kPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _upiController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onTap: _scrollToBottom,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: _kTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'example@upi',
                labelText: 'UPI ID',
                prefixIcon: const Icon(
                  Icons.account_balance_wallet,
                  color: _kPrimaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: _kPrimaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter UPI ID';
                }
                if (!value.contains('@')) {
                  return 'Invalid UPI ID format';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Or Pay via',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _kTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUPIAppIcon(Icons.payment, 'Google Pay'),
                _buildUPIAppIcon(Icons.mobile_screen_share, 'PhonePe'),
                _buildUPIAppIcon(Icons.shopping_bag, 'Paytm'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUPIAppIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _kPrimaryColor.withOpacity(0.1),
                _kPrimaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _kPrimaryColor.withOpacity(0.2),
            ),
          ),
          child: Icon(
            icon,
            size: 32,
            color: _kPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _kTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCardTab() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              textInputAction: TextInputAction.next,
              onTap: _scrollToBottom,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: _kTextPrimary,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                prefixIcon: const Icon(Icons.credit_card, color: _kPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: _kPrimaryColor, width: 2),
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CardNumberFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Card number required';
                if (value.replaceAll(' ', '').length != 16) {
                  return 'Invalid card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    maxLength: 5,
                    textInputAction: TextInputAction.next,
                    onTap: _scrollToBottom,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: _kTextPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Expiry',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: _kPrimaryColor,
                          width: 2,
                        ),
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    inputFormatters: [_ExpiryDateFormatter()],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    onTap: _scrollToBottom,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: _kTextPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: _kPrimaryColor,
                          width: 2,
                        ),
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (value.length != 3) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _cardHolderController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onTap: _scrollToBottom,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: _kTextPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Card Holder Name',
                hintText: 'John Doe',
                prefixIcon: const Icon(Icons.person, color: _kPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: _kPrimaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Cardholder name required';
                }
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedBank,
                isExpanded: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  prefixIcon: const Icon(Icons.account_balance,
                      color: _kPrimaryColor),
                ),
                hint: Text(
                  'Select Bank',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
                items: _banks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(
                      bank,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _kTextPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedBank = value);
                  _scrollToBottom();
                },
                validator: (value) =>
                    value == null ? 'Please select bank' : null,
                icon: const Icon(Icons.expand_more, color: _kPrimaryColor),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onTap: _scrollToBottom,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: _kTextPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Account Number',
                hintText: '1234567890',
                prefixIcon:
                    const Icon(Icons.account_balance, color: _kPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: _kPrimaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Account required';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _ifscController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 11,
              textInputAction: TextInputAction.next,
              onTap: _scrollToBottom,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: _kTextPrimary,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                labelText: 'IFSC Code',
                hintText: 'SBIN0001234',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: _kPrimaryColor, width: 2),
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'IFSC required';
                if (value.length != 11) return 'Invalid IFSC';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _customerIdController,
              textInputAction: TextInputAction.done,
              onTap: _scrollToBottom,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: _kTextPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Customer ID',
                hintText: 'Enter Customer ID',
                prefixIcon: const Icon(Icons.person_outline,
                    color: _kPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: _kPrimaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Customer ID required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryColor,
              disabledBackgroundColor: _kPrimaryColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isProcessing
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Donate ${_finalAmount != null ? "₹$_finalAmount" : "Now"}',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// Custom formatter for card number
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String digitsOnly = newValue.text.replaceAll(' ', '');
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }

    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(digitsOnly[i]);
    }

    return TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String digitsOnly = newValue.text.replaceAll('/', '');
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2) {
        formatted.write('/');
      }
      formatted.write(digitsOnly[i]);
    }

    return TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
