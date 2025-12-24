import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealcircle/services/user_service.dart';
import 'package:mealcircle/services/user_profile_page.dart';

const Color _kPrimaryGreen = Color(0xFF00B562);
const Color _kBackgroundCream = Color(0xFFFFFBF7);
const Color _kAccentOrange = Color(0xFFFF6B35);
const Color _kCardWhite = Color(0xFFFFFFFF);
const Color _kTextDark = Color(0xFF1C1C1C);
const Color _kTextLight = Color(0xFF6B7280);
const Color _kBorderLight = Color(0xFFE5E7EB);

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  String? _profileImagePath;
  String? _shelterImagePath;
  String? _preferredDonationType;
  String? _deliveryMethod;
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _userService.currentUser;
    if (user != null) {
      _nameController = TextEditingController(text: user.name ?? '');
      _emailController = TextEditingController(text: user.email ?? '');
      _phoneController = TextEditingController(text: user.phone ?? '');
      _addressLine1Controller = TextEditingController(text: user.addressLine1 ?? '');
      _addressLine2Controller = TextEditingController(text: user.addressLine2 ?? '');
      _cityController = TextEditingController(text: user.city ?? '');
      _stateController = TextEditingController(text: user.state ?? '');
      _pincodeController = TextEditingController(text: user.pincode ?? '');
      _profileImagePath = user.profileImagePath;
      _shelterImagePath = user.shelterImagePath;
      _preferredDonationType = user.preferredDonationType;
      _deliveryMethod = user.deliveryMethod;
      _notificationsEnabled = user.notificationsEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<String?> _pickImageGeneric() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Choose Photo Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: _kPrimaryGreen),
                title: Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: _kAccentOrange),
                title: Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? image = await _imagePicker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 75);
      return image?.path;
    }
    return null;
  }

  Future<void> _pickProfileImage() async {
    final path = await _pickImageGeneric();
    if (path != null) setState(() => _profileImagePath = path);
  }

  Future<void> _pickShelterImage() async {
    final path = await _pickImageGeneric();
    if (path != null) setState(() => _shelterImagePath = path);
  }
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final currentUser = _userService.currentUser;
      if (currentUser != null) {
        currentUser.name = _nameController.text.trim();
        currentUser.email = _emailController.text.trim();
        currentUser.phone = _phoneController.text.trim();
        currentUser.addressLine1 = _addressLine1Controller.text.trim();
        currentUser.addressLine2 = _addressLine2Controller.text.trim();
        currentUser.city = _cityController.text.trim();
        currentUser.state = _stateController.text.trim();
        currentUser.pincode = _pincodeController.text.trim();
        currentUser.profileImagePath = _profileImagePath;
        currentUser.shelterImagePath = _shelterImagePath;
        currentUser.preferredDonationType = _preferredDonationType;
        currentUser.deliveryMethod = _deliveryMethod;
        currentUser.notificationsEnabled = _notificationsEnabled;

        bool success = await _userService.updateUser(currentUser);

        if (mounted) {
          setState(() => _isLoading = false);

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Profile updated successfully!',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: _kPrimaryGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Failed to update profile',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: _kBackgroundCream,
      appBar: _buildTopBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 14 : 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildProfileImagePicker(),
              if (_userService.currentUser?.userType == 'Finder') ...[
                const SizedBox(height: 24),
                _buildShelterImagePicker(),
              ],
              const SizedBox(height: 24),
              _buildSection(
                title: 'Personal Information',
                icon: Icons.person,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
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
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Address',
                icon: Icons.location_on,
                children: [
                  _buildTextField(
                    controller: _addressLine1Controller,
                    label: 'Address Line 1',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _addressLine2Controller,
                    label: 'Address Line 2',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'State',
                          icon: Icons.map_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _pincodeController,
                    label: 'Pincode',
                    icon: Icons.pin,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              if (_userService.currentUser?.userType == 'Donor') ...[
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Preferences',
                  icon: Icons.settings,
                  children: [
                    _buildDropdownField(
                      label: 'Preferred Donation Type',
                      icon: Icons.restaurant,
                      value: _preferredDonationType,
                      items: ['Cooked Food', 'Raw Food', 'Packaged Food', 'Both'],
                      onChanged: (value) {
                        setState(() => _preferredDonationType = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Delivery Method',
                      icon: Icons.delivery_dining,
                      value: _deliveryMethod,
                      items: ['Self Delivery', 'Pickup', 'Both'],
                      onChanged: (value) {
                        setState(() => _deliveryMethod = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchTile(
                      title: 'Notifications',
                      subtitle: 'Receive notifications about donations',
                      icon: Icons.notifications,
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar() {
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
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
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
                    child: const Icon(Icons.person_outline,
                        color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserProfilePage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return _buildImagePickerTile(
      title: 'Profile Picture',
      path: _profileImagePath,
      onTap: _pickProfileImage,
    );
  }

  Widget _buildShelterImagePicker() {
    return _buildImagePickerTile(
      title: 'Shelter / House Image',
      path: _shelterImagePath,
      onTap: _pickShelterImage,
      isBanner: true,
    );
  }

  Widget _buildImagePickerTile({
    required String title,
    required String? path,
    required VoidCallback onTap,
    bool isBanner = false,
  }) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextDark)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: path != null
              ? Container(
                  height: isBanner ? 150 : 120,
                  width: isBanner ? double.infinity : 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isBanner ? 16 : 60),
                    image: DecorationImage(
                      image: path.startsWith('http') ? NetworkImage(path) : FileImage(File(path)) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  height: isBanner ? 150 : 120,
                  width: isBanner ? double.infinity : 120,
                  decoration: BoxDecoration(
                    color: _kPrimaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isBanner ? 16 : 60),
                    border: Border.all(color: _kPrimaryGreen, width: 2),
                  ),
                  child: Icon(isBanner ? Icons.home_work : Icons.person_add, size: 40, color: _kPrimaryGreen),
                ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
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
                  color: _kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: _kPrimaryGreen),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 13, color: _kTextDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 11,
          color: _kTextLight,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, size: 18, color: _kTextLight),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kPrimaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: GoogleFonts.inter(fontSize: 13, color: _kTextDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 11,
          color: _kTextLight,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, size: 18, color: _kTextLight),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kPrimaryGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: GoogleFonts.inter(fontSize: 13)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: _kPrimaryGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _kTextLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _kPrimaryGreen,
          ),
        ],
      ),
    );
  }
}