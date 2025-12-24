import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealcircle/shared/design_system.dart';
import 'package:mealcircle/services/donation_firebase_service.dart';
import 'package:mealcircle/services/user_provider.dart';
import 'package:mealcircle/Donater/donor_post_service.dart';
import 'package:mealcircle/services/firebase_service.dart';
import 'package:provider/provider.dart';

class CreateDonationPostScreen extends StatefulWidget {
  const CreateDonationPostScreen({super.key});

  @override
  State<CreateDonationPostScreen> createState() =>
      _CreateDonationPostScreenState();
}

class _CreateDonationPostScreenState extends State<CreateDonationPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();

  final _imagePicker = ImagePicker();
  final _postService = DonorPostService();

  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  void _loadUserAddress() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          if (user.fullAddress.isNotEmpty) {
            _addressController.text = user.fullAddress;
          }
          if (user.location.isNotEmpty) {
            _locationController.text = user.location;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _foodTypeController.dispose();
    _servingsController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text('Failed to pick image: $e'),
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

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: AppTypography.headingSmall(color: AppColors.textDark),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt, color: AppColors.primaryGreen, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Camera',
                              style: AppTypography.labelMedium(color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.accentOrange.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library, color: AppColors.accentOrange, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Gallery',
                              style: AppTypography.labelMedium(color: AppColors.textDark),
                            ),
                          ],
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

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;
    
    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser;
    if (user == null || user.email == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in again to post')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    // Use local image path
    String? imageUrl = _imagePath;

    final post = DonorPostFirebase(
      id: DonationFirebaseService().generateDonationId(),
      donorEmail: user.email!,
      donorName: user.name ?? 'Anonymous',
      donorPhone: user.phone,
      foodType: _foodTypeController.text.trim(),
      servings: int.parse(_servingsController.text.trim()),
      imagePath: imageUrl,
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      location: _locationController.text.trim(),
      donorType: user.userType,
      createdAt: DateTime.now(),
    );

    final success = await DonationFirebaseService().createDonation(post);

    if (mounted) {
      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text('Donation posted successfully!'),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
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
                Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text('Failed to post donation'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildModernTextField(
                controller: _foodTypeController,
                label: 'Food Type',
                hint: 'e.g., Biryani, Pizza, Rice & Curry',
                icon: Icons.restaurant,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter food type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: _servingsController,
                label: 'Number of Servings',
                hint: 'e.g., 10',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of servings';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Additional details about the food',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: _addressController,
                label: 'Pickup Address',
                hint: 'Enter full address',
                icon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'City, State',
                icon: Icons.place,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryGreen.withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Create Donation Post',
                              style: AppTypography.headingMedium(color: Colors.white),
                            ),
                          ],
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

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryGreen, AppColors.primaryGreen.withOpacity(0.85)],
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
                    'Donation post',
                    style: AppTypography.headingMedium(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: _showImageSourceDialog,
        child: Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, size: 48, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to add food photo',
                      style: AppTypography.headingSmall(color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Camera or Gallery',
                      style: AppTypography.labelSmall(color: AppColors.textLight),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium(color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              style: AppTypography.bodyMedium(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.labelSmall(color: AppColors.textLight),
                prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                errorStyle: AppTypography.labelSmall(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}