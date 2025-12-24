import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'finder_models.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:mealcircle/shared/design_system.dart';
import 'package:mealcircle/finder/finder_cart_manager.dart';
import 'package:mealcircle/finder/finder_cart_screen.dart';
import 'browse_donations_screen.dart';

class DonationDetailScreen extends StatefulWidget {
  final LocalDonation donation;

  const DonationDetailScreen({
    super.key,
    required this.donation,
  });

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  // Finder details (auto-filled)
  late TextEditingController _finderNameController;
  late TextEditingController _finderEmailController;
  late TextEditingController _finderPhoneController;
  late TextEditingController _finderAddressController;
  late TextEditingController _requestedServingsController;
  late TextEditingController _notesController;

  String _selectedDeliveryMethod = 'donor_delivery'; // Default
  int _maxServings = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with dummy finder data
    _finderNameController = TextEditingController(text: 'Rahul Kumar');
    _finderEmailController = TextEditingController(text: 'rahul@example.com');
    _finderPhoneController = TextEditingController(text: '+91 9876543200');
    _finderAddressController = TextEditingController(
      text: '456 Park Avenue, Central District, City - 600100',
    );
    _requestedServingsController = TextEditingController(text: '10');
    _notesController = TextEditingController();
    _maxServings = widget.donation.servings;
  }

  @override
  void dispose() {
    _finderNameController.dispose();
    _finderEmailController.dispose();
    _finderPhoneController.dispose();
    _finderAddressController.dispose();
    _requestedServingsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_finderNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    int requestedServings = int.tryParse(_requestedServingsController.text) ?? 10;
    if (requestedServings > _maxServings) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxServings servings available'),
        ),
      );
      return;
    }

    // Create cart item with finder details
    final cartItem = FinderCartItem(
      donation: widget.donation,
      requestedServings: requestedServings,
      notes: _notesController.text,
      finderName: _finderNameController.text,
      finderEmail: _finderEmailController.text,
      finderPhone: _finderPhoneController.text,
      finderAddress: _finderAddressController.text,
      selectedDeliveryMethod: _selectedDeliveryMethod,
    );

    // Add to cart via provider
    final cartManager = Provider.of<FinderCartManager>(context, listen: false);
    cartManager.addCartItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart!'),
        backgroundColor: AppColors.primaryGreen,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FinderCartScreen()),
            );
          },
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBarStyles.standard(
        context: context,
        title: 'Donation Details',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Donation Image
            widget.donation.imagePath != null && widget.donation.imagePath!.isNotEmpty
                ? (widget.donation.imagePath!.startsWith('http')
                    ? Image.network(
                        widget.donation.imagePath!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                      )
                    : Image.file(
                        File(widget.donation.imagePath!),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                      ))
                : _buildImagePlaceholder(),

            // Donation Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Servings
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.donation.foodType,
                              style: AppTypography.headingLarge(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'by ${widget.donation.donorName}',
                              style: AppTypography.bodyMedium(
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.donation.servings.toString(),
                              style: AppTypography.displaySmall(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            Text(
                              'servings',
                              style: AppTypography.bodySmall(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: AppDecorations.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: AppTypography.headingSmall(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          widget.donation.description,
                          style: AppTypography.bodyMedium(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Donor Info
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: AppDecorations.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donor Information',
                          style: AppTypography.headingSmall(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildInfoRow(
                          Icons.person_rounded,
                          'Name',
                          widget.donation.donorName,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildInfoRow(
                          Icons.phone_rounded,
                          'Phone',
                          widget.donation.donorPhone,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildInfoRow(
                          Icons.email_rounded,
                          'Email',
                          widget.donation.donorEmail,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildInfoRow(
                          Icons.location_on_rounded,
                          'Address',
                          widget.donation.donorAddress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Delivery Method Info
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentOrange.withOpacity(0.1),
                          AppColors.accentOrange.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.accentOrange.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            widget.donation.deliveryMethod == 'donor_delivery'
                                ? Icons.local_shipping_rounded
                                : Icons.person_pin_circle_rounded,
                            color: AppColors.accentOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Method',
                                style: AppTypography.labelMedium(),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                widget.donation.deliveryMethod == 'donor_delivery'
                                    ? 'Donor will deliver the food'
                                    : 'You can pick up the food',
                                style: AppTypography.bodySmall(
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Divider
                  Divider(
                    color: AppColors.borderLight,
                    height: AppSpacing.lg,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Finder Details Form
                  Text(
                    'Your Details',
                    style: AppTypography.headingMedium(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Name
                  _buildTextFormField(
                    label: 'Your Name',
                    controller: _finderNameController,
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Email
                  _buildTextFormField(
                    label: 'Email Address',
                    controller: _finderEmailController,
                    icon: Icons.email_rounded,
                    readOnly: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Phone
                  _buildTextFormField(
                    label: 'Phone Number',
                    controller: _finderPhoneController,
                    icon: Icons.phone_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Address
                  _buildTextFormField(
                    label: 'Delivery Address',
                    controller: _finderAddressController,
                    icon: Icons.location_on_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Requested Servings
                  _buildTextFormField(
                    label: 'Requested Servings (max: $_maxServings)',
                    controller: _requestedServingsController,
                    icon: Icons.restaurant_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Delivery Method Selection
                  Text(
                    'How would you prefer to receive the food?',
                    style: AppTypography.labelMedium(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildDeliveryMethodOption(
                    'Donor Delivery',
                    'Donor will deliver food to your address',
                    Icons.local_shipping_rounded,
                    'donor_delivery',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildDeliveryMethodOption(
                    'Self Pickup',
                    'You will pick up from donor location',
                    Icons.person_pin_circle_rounded,
                    'finder_pickup',
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Special Notes
                  _buildTextFormField(
                    label: 'Special Notes (Optional)',
                    controller: _notesController,
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                    hintText: 'Any dietary restrictions or special requirements?',
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall(color: AppColors.textLight),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: AppTypography.bodyMedium(color: AppColors.textDark),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium()),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: AppDecorations.card(),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            minLines: maxLines,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.bodySmall(color: AppColors.textLight),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: AppColors.textLight),
              contentPadding: const EdgeInsets.all(AppSpacing.lg),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryMethodOption(
    String title,
    String subtitle,
    IconData icon,
    String value,
  ) {
    bool isSelected = _selectedDeliveryMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.1)
              : AppColors.cardWhite,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withOpacity(0.15)
                    : AppColors.borderLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryGreen : AppColors.textLight,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: AppColors.borderLight,
      child: const Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.textLight),
    );
  }
}


