import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/Donater/notification_screen.dart';
import 'package:mealcircle/finder/finder_notification_screen.dart';
import 'package:mealcircle/finder/my_orders_screen.dart';
import 'package:mealcircle/services/user_service.dart';
import 'package:mealcircle/services/edit_profile_page.dart';
import 'package:mealcircle/finder/finder_support_screen.dart';
import 'package:mealcircle/finder/finder_about_us_page.dart';
import 'package:mealcircle/main.dart';

const Color _kPrimaryGreen = Color(0xFF00B562);
const Color _kAccentOrange = Color(0xFFFF6B35);
const Color _kBackgroundCream = Color(0xFFFFFBF7);
const Color _kCardWhite = Color(0xFFFFFFFF);
const Color _kTextDark = Color(0xFF1C1C1C);
const Color _kTextLight = Color(0xFF6B7280);
const Color _kBorderLight = Color(0xFFE5E7EB);

class FinderUserProfilePage extends StatefulWidget {
  const FinderUserProfilePage({super.key});

  @override
  State<FinderUserProfilePage> createState() => _FinderUserProfilePageState();
}

class _FinderUserProfilePageState extends State<FinderUserProfilePage>
    with SingleTickerProviderStateMixin {
  final _userService = UserService();
  late AnimationController _animationController;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = _userService.currentUser;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.fullAddress.isNotEmpty
          ? user.fullAddress
          : "${user.addressLine1 ?? ''}, ${user.city ?? ''}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;

    return Scaffold(
      backgroundColor: _kBackgroundCream,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (user?.shelterImagePath != null && user!.shelterImagePath!.isNotEmpty)
              _buildShelterBanner(user.shelterImagePath!),
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildFinderStatsRow(user),
                  const SizedBox(height: 24),
                  _buildProfileDetails(),
                  const SizedBox(height: 20),
                  _buildSettingsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
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
                    'My Profile',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    ).then((_) {
                      setState(() {
                        _loadUserData();
                      });
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShelterBanner(String imagePath) {
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        image: DecorationImage(
          image: imagePath.startsWith('http')
              ? NetworkImage(imagePath)
              : FileImage(File(imagePath)) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_kPrimaryGreen, _kAccentOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimaryGreen.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCardWhite,
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: _kPrimaryGreen.withOpacity(0.1),
                  backgroundImage:
                      user?.profileImagePath != null &&
                          user!.profileImagePath!.isNotEmpty
                      ? (user.profileImagePath!.startsWith('http')
                          ? NetworkImage(user.profileImagePath!)
                          : FileImage(File(user.profileImagePath!))) as ImageProvider
                      : null,
                  child:
                      user?.profileImagePath == null ||
                          user!.profileImagePath!.isEmpty
                      ? Text(
                          (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: _kPrimaryGreen,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.name ?? 'User Name',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kTextDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _kPrimaryGreen.withOpacity(0.2),
                    _kPrimaryGreen.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag, color: _kPrimaryGreen, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Active Finder',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kPrimaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinderStatsRow(user) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '0',
              'Meals Received',
              Icons.restaurant,
              _kPrimaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '0',
              'Active Orders',
              Icons.shopping_bag,
              _kAccentOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '0',
              'Rating',
              Icons.star,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _kTextLight,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
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
                  child: Icon(Icons.person, color: _kPrimaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailField('Name', _nameController, Icons.badge),
            const SizedBox(height: 16),
            _buildDetailField('Email', _emailController, Icons.email),
            const SizedBox(height: 16),
            _buildDetailField('Phone', _phoneController, Icons.phone),
            const SizedBox(height: 16),
            _buildDetailField(
              'Address',
              _addressController,
              Icons.location_on,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
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
            color: _isEditing ? _kBackgroundCream : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isEditing ? _kBorderLight : Colors.transparent,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: _isEditing,
            maxLines: maxLines,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: _kTextDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _kTextLight, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 700),
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.settings, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Settings & Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              'My Orders',
              Icons.shopping_bag,
              _kPrimaryGreen,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                );
              },
            ),
            _buildSettingTile(
              'Past Orders',
              Icons.history,
              _kAccentOrange,
              () {
              },
            ),
            _buildSettingTile(
              'Notifications',
              Icons.notifications,
              Colors.blue,
              ()  {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FinderNotificationScreen()),
              );
            },
            ),
            _buildSettingTile('Help & Support', Icons.help, Colors.purple, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FinderSupportScreen()),
              );
            }),
            _buildSettingTile('About Us', Icons.info, Colors.teal, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FinderAboutUsPage()),
              );
            }),
            _buildSettingTile(
              'Logout',
              Icons.logout,
              Colors.red,
              () => _showLogoutDialog(),
              isDanger: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDanger ? Colors.red : _kTextDark,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: _kTextLight),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'Logout?',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?',
                style: GoogleFonts.inter(fontSize: 14, color: _kTextLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: _kBorderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _kTextDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyApp()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
      ),
    );
  }
}