import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/Donater/past_donation_page.dart';
import 'user_model.dart';
import 'user_service.dart';
import 'edit_profile_page.dart';
import 'package:mealcircle/Frontscreens/login_screen.dart';
import 'package:mealcircle/Donater/my_donation_screen.dart';

const Color _kPrimaryColor = Color(0xFF2AC962);

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _userService = UserService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final user = await _userService.loadUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.playfairDisplay(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.playfairDisplay(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.playfairDisplay(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );

    if (result == true) {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFEDE8E5),
        appBar: _buildTopBar(context),
        body: const Center(
          child: CircularProgressIndicator(color: _kPrimaryColor),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEDE8E5),
        appBar: _buildTopBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Failed to load user data',
                style: GoogleFonts.playfairDisplay(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: Text(
                  'Retry',
                  style: GoogleFonts.playfairDisplay(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E5),
      appBar: _buildTopBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildProfileImage(),
            const SizedBox(height: 20),
            Text(
              _currentUser!.name ?? 'User',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildUserTypeBadge(),
            const SizedBox(height: 30),
            _buildInfoCard(
              title: 'Personal Information',
              icon: Icons.person,
              children: [
                _buildInfoRow(
                  'Email',
                  _currentUser!.email ?? 'Not provided',
                  Icons.email,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  'Phone',
                  _currentUser!.phone ?? 'Not provided',
                  Icons.phone,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  'Location',
                  _currentUser!.location.isNotEmpty
                      ? _currentUser!.location
                      : 'Not provided',
                  Icons.location_on,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_currentUser!.fullAddress.isNotEmpty)
              _buildInfoCard(
                title: 'Address',
                icon: Icons.home,
                children: [
                  _buildAddressRow(
                    _currentUser!.addressLine1 ?? '',
                    _currentUser!.addressLine2 ?? '',
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (_currentUser!.userType == 'Donor')
              _buildInfoCard(
                title: 'Donation Statistics',
                icon: Icons.analytics,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          '${_currentUser!.totalDonations}',
                          'Total Donations',
                          Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          '${_currentUser!.mealsProvided}',
                          'Meals Donated',
                          Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          '${_currentUser!.sheltersHelped}',
                          'Shelters Helped',
                          Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          _getMemberDuration(),
                          'Member Since',
                          Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (_currentUser!.userType == 'Donor')
              _buildInfoCard(
                title: 'Preferences',
                icon: Icons.settings,
                children: [
                  _buildPreferenceRow(
                    'Preferred Donation Type',
                    _currentUser!.preferredDonationType ?? 'Not set',
                    Icons.restaurant,
                  ),
                  const Divider(height: 24),
                  _buildPreferenceRow(
                    'Delivery Method',
                    _currentUser!.deliveryMethod ?? 'Not set',
                    Icons.delivery_dining,
                  ),
                  const Divider(height: 24),
                  _buildPreferenceRow(
                    'Notification',
                    _currentUser!.notificationsEnabled ? 'Enabled' : 'Disabled',
                    Icons.notifications,
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (_currentUser!.userType == 'Donor')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyDonationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.restaurant_menu, color: Colors.white),
                  label: Text(
                    'My Donation Posts',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            if (_currentUser!.userType == 'Donor') const SizedBox(height: 12),
            if (_currentUser!.userType == 'Donor')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PastDonationsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history, color: Colors.white),
                  label: Text(
                    'View Past Donations',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            if (_currentUser!.userType == 'Donor') const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Logout',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getMemberDuration() {
    if (_currentUser!.memberSince == null) return 'N/A';

    try {
      final memberDate = DateTime.parse(_currentUser!.memberSince!);
      final now = DateTime.now();
      final difference = now.difference(memberDate);

      if (difference.inDays < 30) {
        return '${difference.inDays} Days';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} Months';
      } else {
        return '${(difference.inDays / 365).floor()} Years';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _navigateToEditProfile,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: _kPrimaryColor,
            backgroundImage: _currentUser!.profileImagePath != null
                ? FileImage(File(_currentUser!.profileImagePath!))
                : null,
            child: _currentUser!.profileImagePath == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _kPrimaryColor, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                size: 20,
                color: _kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimaryColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _currentUser!.userType == 'Donor'
                ? Icons.volunteer_activism
                : Icons.restaurant,
            color: _kPrimaryColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _currentUser!.userType ?? 'User',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    const double customHeight = 74.0;

    return PreferredSize(
      preferredSize: const Size.fromHeight(customHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: _kPrimaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 3.5),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: customHeight,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "My Profile",
            style: GoogleFonts.imFellGreatPrimerSc(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 26),
              onPressed: _navigateToEditProfile,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: _kPrimaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow(String line1, String line2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (line1.isNotEmpty)
                Text(
                  line1,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _kPrimaryColor,
          ),
        ),
      ],
    );
  }
}