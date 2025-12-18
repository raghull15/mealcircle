import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/widgets/logo.dart';
import 'package:mealcircle/widgets/user_service.dart';
import 'package:mealcircle/widgets/profile_completion_flow.dart';

class UserTypeSelectionFlow extends StatefulWidget {
  const UserTypeSelectionFlow({super.key});

  @override
  State<UserTypeSelectionFlow> createState() => _UserTypeSelectionFlowState();
}

class _UserTypeSelectionFlowState extends State<UserTypeSelectionFlow> {
  int? _selectedType;
  double _opacity = 0;
  final _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1;
      });
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedType == null) return;

    setState(() => _isLoading = true);

    String userType = _selectedType == 0 ? 'Donor' : 'Receiver';
    bool success = await _userService.updateUserType(userType);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileCompletionScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save selection. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2AC962),
      body: SafeArea(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: _opacity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const MealCircleLogo(size: 180),
                  const SizedBox(height: 40),
                  Text(
                    "How would you like\nto make a difference?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Choose your role to get started",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildTypeCard(
                    index: 0,
                    title: "I Want to Donate",
                    subtitle: "Share food with those in need",
                    icon: Icons.volunteer_activism_rounded,
                    features: [
                      "Donate surplus food",
                      "Help reduce food waste",
                      "Make an impact in your community",
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTypeCard(
                    index: 1,
                    title: "I Need Food",
                    subtitle: "Find available food donations",
                    icon: Icons.restaurant_rounded,
                    features: [
                      "Discover nearby food donations",
                      "Get notified of new donations",
                      "Access nutritious meals",
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedType != null
                            ? const Color(0xFFD1EBD0)
                            : Colors.white.withOpacity(0.3),
                        foregroundColor: Colors.black87,
                        elevation: _selectedType != null ? 6 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: (_selectedType != null && !_isLoading) ? _handleContinue : null,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black87,
                              ),
                            )
                          : Text(
                              "Continue",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _selectedType != null
                                    ? Colors.black87
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> features,
  }) {
    final isSelected = _selectedType == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFEDE8E5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFD1EBD0) : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.15 : 0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2AC962) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2AC962) : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.circle_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isSelected ? const Color(0xFF2AC962) : Colors.grey.shade400,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}