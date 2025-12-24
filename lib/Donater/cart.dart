  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:mealcircle/Donater/cart_confirmation.dart';
  import 'package:mealcircle/Donater/cart_manager.dart';
  import 'package:mealcircle/services/user_service.dart';

  import 'package:mealcircle/shared/design_system.dart';

// Modern color scheme (consistent with recipients.dart replaced by DesignSystem)

  class CartScreen extends StatefulWidget {
    final List<Map<String, dynamic>> cartItems;

    const CartScreen({super.key, required this.cartItems});

    @override
    State<CartScreen> createState() => _CartScreenState();
  }

  class _CartScreenState extends State<CartScreen> {
    late List<Map<String, dynamic>> _items;
    late Map<int, TextEditingController> _foodTypeControllers;
    late Map<int, TextEditingController> _quantityControllers;
    late Map<int, TextEditingController> _dateTimeControllers;
    late Map<int, TextEditingController> _recipientNameControllers;
    late Map<int, TextEditingController> _addressControllers;
    late Map<int, TextEditingController> _phoneControllers;
    late Map<int, bool> _deliveryByDonorMap;
    
    final _userService = UserService();
    final _cartManager = CartManager();

    @override
    void initState() {
      super.initState();
      _items = List.from(widget.cartItems);
      _initializeControllers();
    }

    void _initializeControllers() {
      _foodTypeControllers = {};
      _quantityControllers = {};
      _dateTimeControllers = {};
      _recipientNameControllers = {};
      _addressControllers = {};
      _phoneControllers = {};
      _deliveryByDonorMap = {};

      for (int i = 0; i < _items.length; i++) {
        _foodTypeControllers[i] = TextEditingController();
        _quantityControllers[i] = TextEditingController(text: '1');
        _dateTimeControllers[i] = TextEditingController();
        _recipientNameControllers[i] = TextEditingController();
        _addressControllers[i] = TextEditingController();
        _phoneControllers[i] = TextEditingController();
        _deliveryByDonorMap[i] = true; // Default: donor will deliver
        
        // Initialize with shelter data (for donor delivery - show recipient)
        _loadShelterData(i);
      }
    }

    void _loadUserData(int index) {
      final user = _userService.currentUser;
      if (user != null) {
        _recipientNameControllers[index]!.text = user.name ?? '';
        
        // Build full address
        String fullAddress = '';
        if (user.addressLine1 != null && user.addressLine1!.isNotEmpty) {
          fullAddress = user.addressLine1!;
        }
        if (user.addressLine2 != null && user.addressLine2!.isNotEmpty) {
          fullAddress += fullAddress.isNotEmpty ? ', ${user.addressLine2}' : user.addressLine2!;
        }
        if (user.city != null && user.city!.isNotEmpty) {
          fullAddress += fullAddress.isNotEmpty ? ', ${user.city}' : user.city!;
        }
        if (user.state != null && user.state!.isNotEmpty) {
          fullAddress += fullAddress.isNotEmpty ? ', ${user.state}' : user.state!;
        }
        if (user.pincode != null && user.pincode!.isNotEmpty) {
          fullAddress += fullAddress.isNotEmpty ? ' - ${user.pincode}' : user.pincode!;
        }
        
        _addressControllers[index]!.text = fullAddress;
        _phoneControllers[index]!.text = user.phone ?? '';
      }
    }

    void _loadShelterData(int index) {
      if (index >= _items.length) return;
      
      final shelter = _items[index];
      _recipientNameControllers[index]!.text = shelter['managerName'] ?? shelter['contactName'] ?? '';
      _addressControllers[index]!.text = shelter['fullAddress'] ?? shelter['address'] ?? shelter['location'] ?? '';
      _phoneControllers[index]!.text = shelter['phone'] ?? '';
    }

    void _onDeliveryMethodChanged(int index, bool isDeliveryByDonor) {
      setState(() {
        _deliveryByDonorMap[index] = isDeliveryByDonor;
      });

      // CORRECTED LOGIC:
      // If donor will deliver -> Show RECIPIENT (shelter) info
      // If recipient will pickup -> Show DONOR (user) info
      if (isDeliveryByDonor) {
        // Donor will deliver -> Show recipient/shelter information
        _loadShelterData(index);
      } else {
        // Recipient will pickup -> Show donor/user information
        _loadUserData(index);
      }
    }

    @override
    void dispose() {
      _foodTypeControllers.values.forEach((controller) => controller.dispose());
      _quantityControllers.values.forEach((controller) => controller.dispose());
      _dateTimeControllers.values.forEach((controller) => controller.dispose());
      _recipientNameControllers.values.forEach((controller) => controller.dispose());
      _addressControllers.values.forEach((controller) => controller.dispose());
      _phoneControllers.values.forEach((controller) => controller.dispose());
      super.dispose();
    }

    void _removeItem(int index) {
      if (index >= _items.length) return;
      
      final removedItem = _items[index];
      
      setState(() {
        // Remove from local list
        _items.removeAt(index);
        
        // Remove from CartManager - this will notify listeners
        _cartManager.removeItem(removedItem);
        
        // Dispose controllers for removed item
        _foodTypeControllers[index]?.dispose();
        _quantityControllers[index]?.dispose();
        _dateTimeControllers[index]?.dispose();
        _recipientNameControllers[index]?.dispose();
        _addressControllers[index]?.dispose();
        _phoneControllers[index]?.dispose();
        
        // Remove from maps
        _foodTypeControllers.remove(index);
        _quantityControllers.remove(index);
        _dateTimeControllers.remove(index);
        _recipientNameControllers.remove(index);
        _addressControllers.remove(index);
        _phoneControllers.remove(index);
        _deliveryByDonorMap.remove(index);
        
        // Rebuild controller maps with correct indices
        _rebuildControllerMaps();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Item removed from cart',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1200),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      
      // If cart is empty, go back
      if (_items.isEmpty && mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate changes
          }
        });
      }
    }

    void _rebuildControllerMaps() {
      // Create temporary maps with correct indices
      final tempFoodTypeControllers = <int, TextEditingController>{};
      final tempQuantityControllers = <int, TextEditingController>{};
      final tempDateTimeControllers = <int, TextEditingController>{};
      final tempRecipientNameControllers = <int, TextEditingController>{};
      final tempAddressControllers = <int, TextEditingController>{};
      final tempPhoneControllers = <int, TextEditingController>{};
      final tempDeliveryByDonorMap = <int, bool>{};

      // Get all keys and sort them
      final sortedKeys = _foodTypeControllers.keys.toList()..sort();
      
      // Reassign to sequential indices
      for (int i = 0; i < _items.length && i < sortedKeys.length; i++) {
        final oldKey = sortedKeys[i];
        if (_foodTypeControllers.containsKey(oldKey)) {
          tempFoodTypeControllers[i] = _foodTypeControllers[oldKey]!;
          tempQuantityControllers[i] = _quantityControllers[oldKey]!;
          tempDateTimeControllers[i] = _dateTimeControllers[oldKey]!;
          tempRecipientNameControllers[i] = _recipientNameControllers[oldKey]!;
          tempAddressControllers[i] = _addressControllers[oldKey]!;
          tempPhoneControllers[i] = _phoneControllers[oldKey]!;
          tempDeliveryByDonorMap[i] = _deliveryByDonorMap[oldKey] ?? true;
        }
      }

      // Replace old maps with new ones
      _foodTypeControllers = tempFoodTypeControllers;
      _quantityControllers = tempQuantityControllers;
      _dateTimeControllers = tempDateTimeControllers;
      _recipientNameControllers = tempRecipientNameControllers;
      _addressControllers = tempAddressControllers;
      _phoneControllers = tempPhoneControllers;
      _deliveryByDonorMap = tempDeliveryByDonorMap;
    }

    Widget _buildTextField({
      required String label,
      required String hint,
      required TextEditingController controller,
      required IconData icon,
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium(color: AppColors.textLight),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textLight.withOpacity(0.6),
              ),
              prefixIcon: Icon(icon, size: 18, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.backgroundCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    void _selectDateTime(int index) async {
      if (index >= _items.length) return;

      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryGreen,
                onPrimary: Colors.white,
                surface: AppColors.cardWhite,
              ),
            ),
            child: child!,
          );
        },
      );

      if (date != null && mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primaryGreen,
                  onPrimary: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (time != null && _dateTimeControllers.containsKey(index)) {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _dateTimeControllers[index]!.text =
              dateTime.toString().split('.')[0];
        }
      }
    }

    Widget _buildCartItemCard(int index) {
      if (index >= _items.length) return const SizedBox.shrink();
      
      final shelter = _items[index];
      final isDeliveryByDonor = _deliveryByDonorMap[index] ?? true;

      return TweenAnimationBuilder(
        duration: Duration(milliseconds: 300 + (index * 50)),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Shelter Header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.08),
                      AppColors.accentOrange.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        shelter['image'] ?? 'https://via.placeholder.com/50',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen.withOpacity(0.2),
                                AppColors.accentOrange.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.home_rounded,
                            size: 24,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shelter['name'] ?? 'Shelter',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 12, color: AppColors.textLight),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  shelter['location'] ?? 'N/A',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: Colors.red.shade600, size: 20),
                      onPressed: () => _removeItem(index),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Donation Details',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Food Type',
                      hint: 'e.g., Rice, Vegetables',
                      controller: _foodTypeControllers[index]!,
                      icon: Icons.restaurant_rounded,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Quantity (servings)',
                            hint: '1',
                            controller: _quantityControllers[index]!,
                            icon: Icons.local_dining_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Date/Time',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _selectDateTime(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundCream,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 16, color: AppColors.textLight),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _dateTimeControllers[index]!
                                                  .text.isNotEmpty
                                              ? _dateTimeControllers[index]!.text
                                              : 'Select date',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: _dateTimeControllers[index]!
                                                    .text.isNotEmpty
                                                ? AppColors.textDark
                                                : AppColors.textLight,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 18),
                    
                    // MOVED: Contact Information section now BEFORE Delivery Method
                    Text(
                      isDeliveryByDonor ? 'Recipient Information' : 'Donor Information',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: isDeliveryByDonor ? 'Recipient Name' : 'Your Name',
                      hint: 'Full name',
                      controller: _recipientNameControllers[index]!,
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Address',
                      hint: 'Full address',
                      controller: _addressControllers[index]!,
                      icon: Icons.location_on_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Phone Number',
                      hint: 'Contact number',
                      controller: _phoneControllers[index]!,
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 18),
                    Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 18),
                    
                    // Delivery Method section now comes AFTER contact info
                    Text(
                      'Delivery Method',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCream,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<bool>(
                            value: true,
                            groupValue: isDeliveryByDonor,
                            onChanged: (value) {
                              _onDeliveryMethodChanged(index, value ?? true);
                            },
                            title: Row(
                              children: [
                                Icon(Icons.local_shipping_rounded,
                                    size: 18, color: AppColors.primaryGreen),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'I will deliver the food',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            activeColor: AppColors.primaryGreen,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                          ),
                          Divider(color: AppColors.borderLight, height: 1),
                          RadioListTile<bool>(
                            value: false,
                            groupValue: isDeliveryByDonor,
                            onChanged: (value) {
                              _onDeliveryMethodChanged(index, value ?? true);
                            },
                            title: Row(
                              children: [
                                Icon(Icons.person_pin_circle_rounded,
                                    size: 18, color: AppColors.accentOrange),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Recipient will pick up',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            activeColor: AppColors.accentOrange,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                          ),
                        ],
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

    bool _validateCart() {
      for (int i = 0; i < _items.length; i++) {
        if (!_foodTypeControllers.containsKey(i) ||
            !_quantityControllers.containsKey(i) ||
            !_dateTimeControllers.containsKey(i) ||
            !_recipientNameControllers.containsKey(i) ||
            !_addressControllers.containsKey(i) ||
            !_phoneControllers.containsKey(i)) {
          return false;
        }
        
        if (_foodTypeControllers[i]!.text.isEmpty ||
            _quantityControllers[i]!.text.isEmpty ||
            _dateTimeControllers[i]!.text.isEmpty ||
            _recipientNameControllers[i]!.text.isEmpty ||
            _addressControllers[i]!.text.isEmpty ||
            _phoneControllers[i]!.text.isEmpty) {
          return false;
        }
      }
      return true;
    }

    void _proceedToConfirmation() {
      if (!_validateCart()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please fill all required fields',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.accentOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      final donations = <DonationItem>[];
      for (int i = 0; i < _items.length; i++) {
        donations.add(
          DonationItem(
            shelterItem: _items[i],
            foodType: _foodTypeControllers[i]!.text,
            quantity: int.parse(_quantityControllers[i]!.text),
            dateTime: _dateTimeControllers[i]!.text,
            recipientName: _recipientNameControllers[i]!.text,
            recipientAddress: _addressControllers[i]!.text,
            recipientPhone: _phoneControllers[i]!.text,
            deliveryByDonor: _deliveryByDonorMap[i] ?? true,
          ),
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationConfirmationPage(confirmedDonations: donations),
        ),
      );
    }

    PreferredSizeWidget _buildTopBar(BuildContext context) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen,
                AppColors.primaryGreen.withOpacity(0.85),
              ],
            ),
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
                    onPressed: () => Navigator.pop(context, true), // Return true to refresh
                  ),
                  Expanded(
                    child: Text(
                      'Donation Cart',
                      style: AppTypography.headingMedium(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentOrange.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      '${_items.length}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final isMobile = MediaQuery.of(context).size.width < 600;

      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, true); // Return true to trigger refresh
          return false;
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundCream,
          appBar: _buildTopBar(context),
          body: _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: AppColors.textLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cart is empty',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add shelters to get started',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    children: [
                      ..._items.asMap().entries.map((entry) {
                        return _buildCartItemCard(entry.key);
                      }).toList(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size.fromHeight(50),
                            elevation: 2,
                          ),
                          onPressed: _proceedToConfirmation,
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.white),
                          label: Text(
                            'Proceed to Confirmation',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      );
    }
  }