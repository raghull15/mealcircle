import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _kPrimaryColor = Color(0xFF2AC962);

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  String? _selectedSubject;
  bool _isSubmitting = false;

  final List<String> _subjects = [
    'Technical Issue',
    'Donation Query',
    'Account Problem',
    'General Inquiry',
    'Feedback',
  ];

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I donate food?',
      'answer': 'Go to Donate Screen, tap "Donate Food", select shelters, fill details, and confirm your donation.',
    },
    {
      'question': 'Can I donate money?',
      'answer': 'Yes! Go to Donate Screen and tap "Payments" to donate money via UPI, Card, or Net Banking.',
    },
    {
      'question': 'How do I edit my profile?',
      'answer': 'Go to your profile, tap the edit icon at the top right, make changes, and save.',
    },
    {
      'question': 'How do I see past donations?',
      'answer': 'Go to your profile and tap "View Past Donations" to see your donation history.',
    },
    {
      'question': 'What if I need to cancel a donation?',
      'answer': 'Contact the shelter directly using the phone icon, or reach out to us through this support form.',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmitting = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 10),
              Text('Submitted', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Thank you for contacting us! We\'ll get back to you within 24 hours.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: Text('OK', style: GoogleFonts.playfairDisplay(color: _kPrimaryColor)),
            ),
          ],
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    setState(() => _selectedSubject = null);
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@mealcircle.com',
      query: 'subject=Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppInfoCard(),
            const SizedBox(height: 20),
            _buildContactForm(),
            const SizedBox(height: 20),
            _buildFAQSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
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
                    'Help & Support',
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

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: _kPrimaryColor,
            child: Icon(Icons.support_agent, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'MealCircle Support',
            style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactButton(
                icon: Icons.email,
                label: 'Email',
                onTap: _launchEmail,
              ),
              _buildContactButton(
                icon: Icons.phone,
                label: 'Call',
                onTap: () {},
              ),
              _buildContactButton(
                icon: Icons.chat,
                label: 'Chat',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _kPrimaryColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person, color: _kPrimaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kPrimaryColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your name';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'your@email.com',
                prefixIcon: const Icon(Icons.email, color: _kPrimaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kPrimaryColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: InputDecoration(
                labelText: 'Subject',
                prefixIcon: const Icon(Icons.category, color: _kPrimaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kPrimaryColor, width: 2),
                ),
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject, style: GoogleFonts.poppins(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSubject = value),
              validator: (value) => value == null ? 'Please select a subject' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Describe your issue or inquiry',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kPrimaryColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your message';
                if (value.length < 10) return 'Message too short';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Submit',
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
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        question,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            answer,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}