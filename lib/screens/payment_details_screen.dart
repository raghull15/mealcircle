import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/widgets/logo.dart';
import 'payment_success.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String planName;
  final String planPrice;
  final String planPeriod;

  const PaymentDetailsScreen({
    super.key,
    required this.planName,
    required this.planPrice,
    required this.planPeriod,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'card';
  bool _saveCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2AC962),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(child: SizedBox()),
                  const MealCircleLogo(size: 50),
                  const Expanded(child: SizedBox()),
                  const SizedBox(width: 48), 
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE8E5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${widget.planName} Plan",
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Billed ${widget.planPeriod}",
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                widget.planPrice,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2AC962),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          "Personal Details",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: "Full Name",
                          hint: "Enter your full name",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: "Email Address",
                          hint: "Enter your email",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: "Phone Number",
                          hint: "Enter your phone number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        Text(
                          "Payment Method",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildPaymentMethodCard('card', 'Credit/Debit Card', Icons.credit_card),
                        const SizedBox(height: 12),
                        _buildPaymentMethodCard('upi', 'UPI', Icons.account_balance_wallet),
                        const SizedBox(height: 12),
                        _buildPaymentMethodCard('netbanking', 'Net Banking', Icons.account_balance),

                        if (_selectedPaymentMethod == 'card') ...[
                          const SizedBox(height: 24),
                          _buildTextField(
                            label: "Card Number",
                            hint: "1234 5678 9012 3456",
                            icon: Icons.credit_card,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter card number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: "Expiry Date",
                                  hint: "MM/YY",
                                  icon: Icons.calendar_today,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  label: "CVV",
                                  hint: "123",
                                  icon: Icons.lock_outline,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _saveCard,
                                onChanged: (value) => setState(() => _saveCard = value!),
                                activeColor: const Color(0xFF2AC962),
                              ),
                              Text(
                                "Save card for future payments",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (_selectedPaymentMethod == 'upi') ...[
                          const SizedBox(height: 24),
                          _buildTextField(
                            label: "UPI ID",
                            hint: "yourname@upi",
                            icon: Icons.alternate_email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter UPI ID';
                              }
                              return null;
                            },
                          ),
                        ],

                        if (_selectedPaymentMethod == 'netbanking') ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: 'hdfc',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                items: [
                                  'hdfc',
                                  'icici',
                                  'sbi',
                                  'axis',
                                  'kotak',
                                ].map((bank) => DropdownMenuItem(
                                  value: bank,
                                  child: Text(bank.toUpperCase()),
                                )).toList(),
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2AC962),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentSuccessScreen(
                                      planName: widget.planName,
                                      amount: widget.planPrice,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Pay ${widget.planPrice}",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, size: 16, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(
                              "Secured by 256-bit SSL encryption",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.playfairDisplay(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black26),
          ),
          child: TextFormField(
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.playfairDisplay(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.playfairDisplay(
                fontSize: 15,
                color: Colors.black45,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF2AC962)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String value, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2AC962) : Colors.black26,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF2AC962).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF2AC962) : Colors.black54,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2AC962),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}