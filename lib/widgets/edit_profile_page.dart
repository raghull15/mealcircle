import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'user_service.dart';

const Color _kPrimaryColor = Color(0xFF2AC962);

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        currentUser.preferredDonationType = _preferredDonationType;
        currentUser.deliveryMethod = _deliveryMethod;
        currentUser.notificationsEnabled = _notificationsEnabled;

        bool success = await _userService.updateUser(currentUser);

        if (mounted) {
          setState(() => _isLoading = false);

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); 
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update profile'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E5),
      appBar: _buildTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileImagePicker(),
              const SizedBox(height: 30),
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
              const SizedBox(height: 20),
              _buildSection(
                title: 'Address',
                icon: Icons.home,
                children: [
                  _buildTextField(
                    controller: _addressLine1Controller,
                    label: 'Address Line 1',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressLine2Controller,
                    label: 'Address Line 2',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _pincodeController,
                    label: 'Pincode',
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_userService.currentUser?.userType == 'Donor')
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
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Delivery Method',
                      icon: Icons.delivery_dining,
                      value: _deliveryMethod,
                      items: ['Self Delivery', 'Pickup', 'Both'],
                      onChanged: (value) {
                        setState(() => _deliveryMethod = value);
                      },
                    ),
                    const SizedBox(height: 16),
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
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar() {
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Edit Profile",
            style: GoogleFonts.imFellGreatPrimerSc(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: _kPrimaryColor,
            backgroundImage: _profileImagePath != null
                ? FileImage(File(_profileImagePath!))
                : null,
            child: _profileImagePath == null
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
                Icons.camera_alt,
                size: 20,
                color: _kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
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
          const SizedBox(height: 20),
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
      style: GoogleFonts.playfairDisplay(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.playfairDisplay(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        prefixIcon: Icon(icon, size: 20, color: _kPrimaryColor),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.playfairDisplay(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        prefixIcon: Icon(icon, size: 20, color: _kPrimaryColor),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kPrimaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.playfairDisplay(fontSize: 15),
          ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _kPrimaryColor,
          ),
        ],
      ),
    );
  }
}