import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 
import 'cart_confirmation.dart';

const Color _kPrimaryColor = Color(0xFF2AC962);
const Color _kAccentColor = Colors.orange;
const double _kCardRadius = 16.0;
const double _kPadding = 16.0;

class DonationData {
  final Map<String, dynamic> shelterItem;
  final TextEditingController foodTypeController;
  int quantity;
  final TextEditingController timeController;
  final TextEditingController recipientNameController;
  final TextEditingController recipientAddressController;
  final TextEditingController recipientPhoneController;
  bool deliveryByDonor;

  DonationData({
    required this.shelterItem,
    required this.foodTypeController,
    required this.quantity,
    required this.timeController,
    required this.recipientNameController,
    required this.recipientAddressController,
    required this.recipientPhoneController,
    required this.deliveryByDonor,
  });
}

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({super.key, required  this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  final Map<String, Map<String, String>> _shelterDetails = {
    "Orphanage": {
      "name": "Raghul",
      "address": "No:11/34 Chinna Thambi Street, Kosapet, Chennai-600012",
      "phone": "1234567890",
    },
    "Old Age Home": {
      "name": "Raghul",
      "address": "No:11/34 Chinna Thambi Street, Kosapet, Chennai-600012",
      "phone": "1234567890",
    },
    "Animal Shelter": {
      "name": "Raghul",
      "address": "No:11/34 Chinna Thambi Street, Kosapet, Chennai-600012",
      "phone": "1234567890",
    },
    "Community Shelter": {
      "name": "Raghul",
      "address": "No:11/34 Chinna Thambi Street, Kosapet, Chennai-600012",
      "phone": "1234567890",
    },
    "Child Home": {
      "name": "Raghul",
      "address": "No:11/34 Chinna Thambi Street, Kosapet, Chennai-600012",
      "phone": "1234567890",
    },
  };

  final String _donorName = "Dhanush";
  final String _donorAddress = "No:111/45, Vadamalai Street, Purasaiwalkam, Chennai-600018";
  final String _donorPhone = "0987654321";

  late List<DonationData> _donations;
 
  @override
  void initState() {
    super.initState();
    _donations = widget.cartItems.map((item) {
      final details = _shelterDetails[item["name"]];
      return DonationData(
        shelterItem: item,
        foodTypeController: TextEditingController(),
        quantity: 5,
        timeController: TextEditingController(),
        recipientNameController: TextEditingController(text: details?["name"] ?? ""),
        recipientAddressController: TextEditingController(text: details?["address"] ?? ""),
        recipientPhoneController: TextEditingController(text: details?["phone"] ?? ""),
        deliveryByDonor: true,
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var donation in _donations) {
      donation.foodTypeController.dispose();
      donation.timeController.dispose();
      donation.recipientNameController.dispose();
      donation.recipientAddressController.dispose();
      donation.recipientPhoneController.dispose();
    }
    super.dispose();
  }
  
  void _updateQuantity(int index, int change) {
    setState(() {
      _donations[index].quantity = (_donations[index].quantity + change).clamp(1, 100);
    });
  }

  void _onDeliveryMethodChanged(int index, bool isDonor) {
    setState(() {
      _donations[index].deliveryByDonor = isDonor;
      _populateDeliveryDetails(index);
    });
  }

  void _populateDeliveryDetails(int index) {
    final donation = _donations[index];
    final details = _shelterDetails[donation.shelterItem["name"]];
    
    if (donation.deliveryByDonor) {     
      donation.recipientNameController.text = details?["name"] ?? "";
      donation.recipientAddressController.text = details?["address"] ?? "";
      donation.recipientPhoneController.text = details?["phone"] ?? "";
    } else {
      donation.recipientNameController.text = _donorName;
      donation.recipientAddressController.text = _donorAddress;
      donation.recipientPhoneController.text = _donorPhone;
    }
  }
  
  Future<void> _selectDateTime(BuildContext context, int index) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: _kPrimaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        String dateString = DateFormat('MMM d, yyyy').format(finalDateTime) + 
                            " at " + 
                            DateFormat('h:mm a').format(finalDateTime);

        setState(() {
          _donations[index].timeController.text = dateString;
        });
      }
    }
  }

  void _handleDonate(BuildContext context) {
    List<DonationItem> donationsToSend = [];

    for (int i = 0; i < _donations.length; i++) {
      final donation = _donations[i];

      if (donation.foodTypeController.text.isEmpty ||
          donation.timeController.text.isEmpty ||
          donation.recipientNameController.text.isEmpty ||
          donation.recipientAddressController.text.isEmpty ||
          donation.recipientPhoneController.text.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please fill all fields for donation #${i + 1} (${donation.shelterItem["name"] ?? "Shelter"})',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      donationsToSend.add(DonationItem(
        shelterItem: donation.shelterItem,
        foodType: donation.foodTypeController.text,
        quantity: donation.quantity,
        dateTime: donation.timeController.text, 
        recipientName: donation.recipientNameController.text,
        recipientAddress: donation.recipientAddressController.text,
        recipientPhone: donation.recipientPhoneController.text,
        deliveryByDonor: donation.deliveryByDonor,
      ));
    }

    if (donationsToSend.isNotEmpty) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DonationConfirmationPage(
            confirmedDonations: donationsToSend,
          ),
        ),
      );
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
      decoration: BoxDecoration(
        color: _kPrimaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(0, 3),
            blurRadius: 9,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
              ),
            ),
            Text(
              "Your Cart",
              style: GoogleFonts.imFellGreatPrimerSc(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.person_outline, color: Colors.white, size: 25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCard({required Widget child, Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(_kPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_kCardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildShelterCard(Map<String, dynamic> item, int index) {
    return _buildCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item["image"] ?? "https://via.placeholder.com/150",
              height: 75,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kPrimaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "#${index + 1}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item["name"] ?? "Shelter Name",
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item["distance"] ?? "N/A",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.orange),
                    SizedBox(width: 6),
                    Icon(Icons.group, size: 16, color: Colors.red),
                    SizedBox(width: 6),
                    Icon(Icons.phone, size: 16, color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationInputCard(int index) {
    final donation = _donations[index];
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Donation Details #${index + 1}",
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 20, thickness: 1, color: Colors.black12),
          _buildInputLabel("Food Type:"),
          _buildTextField(
            hintText: "e.g., Pasta, Rice, Meals",
            controller: donation.foodTypeController,
          ),
          const SizedBox(height: 15),
          _buildInputLabel("Quantity (servings):"),
          _buildQuantitySelector(index),
          const SizedBox(height: 15),
          _buildInputLabel("Date/Time Available:"),
          GestureDetector(
            onTap: () => _selectDateTime(context, index),
            child: AbsorbPointer( 
              child: _buildTextField(
                hintText: "Select Date and Time",
                controller: donation.timeController,
                keyboardType: TextInputType.none,
                readOnly: true, 
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailsCard(int index) {
    final donation = _donations[index];
    final isDeliveryByDonor = donation.deliveryByDonor;

    return Column(
      children: [
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel(isDeliveryByDonor ? "Recipient's Name:" : "Donor's Name:"),
              _buildTextField(
                hintText: "Enter name",
                controller: donation.recipientNameController,
              ),
              const SizedBox(height: 15),
              _buildInputLabel(isDeliveryByDonor ? "Recipient's Address:" : "Donor's Address:"),
              _buildTextField(
                hintText: "Enter address",
                controller: donation.recipientAddressController,
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              _buildInputLabel(isDeliveryByDonor ? "Recipient's Phone No.:" : "Donor's Phone No.:"),
              _buildTextField(
                hintText: "Enter phone number",
                keyboardType: TextInputType.phone,
                controller: donation.recipientPhoneController,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Delivery Method:"),
                    const SizedBox(height: 8),
                    _buildToggleRow(
                      label: "Donor will Deliver:",
                      value: isDeliveryByDonor,
                      onChanged: (_) => _onDeliveryMethodChanged(index, true),
                    ),
                    _buildToggleRow(
                      label: "Recipient will pickup:",
                      value: !isDeliveryByDonor,
                      onChanged: (_) => _onDeliveryMethodChanged(index, false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_kCardRadius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_kCardRadius),
                  child: Stack(
                    children: [
                      Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFpCFl6v8Ui52DEjKX_Zh2f5qLKC19VpDKWiUQw84RKlkk8ijjENB0GYbG_hZGQSUG-Uw&usqp=CAU",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stack) => Center(
                          child: Icon(Icons.map, size: 40, color: Colors.grey.shade400),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red.shade700,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(int index) {
    final donation = _donations[index];
    return Row(
      children: [
        _buildRoundButton(Icons.remove, () => _updateQuantity(index, -1)),
        const SizedBox(width: 15),
        Text(
          "${donation.quantity}",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 15),
        _buildRoundButton(Icons.add, () => _updateQuantity(index, 1)),
      ],
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    int maxLines = 1,
    bool readOnly = false, 
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly, 
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        fillColor: Colors.grey.shade50,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kPrimaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onPress) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _kPrimaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: _kPrimaryColor.withOpacity(0.5)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: _kPrimaryColor,
        onPressed: onPress,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
             fontSize: 13,
             fontWeight: FontWeight.w500,
             color: Colors.black87,
            ),
          ),
        ),
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: _kPrimaryColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomDonateBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleDonate(context),
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                label: Text(
                  "Donate Now",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccentColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline, color: _kPrimaryColor),
                label: Text(
                  "Message",
                  style: GoogleFonts.poppins(
                    color: _kPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: _kPrimaryColor, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildDonationSections() {
    List<Widget> sections = [];
    for (int i = 0; i < _donations.length; i++) {
      sections.add(_buildDonationSection(i));
      if (i < _donations.length - 1) {
        sections.add(const Divider(height: 40, thickness: 2, color: Colors.black26));
      }
    }
    return sections;
  }

  Widget _buildDonationSection(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShelterCard(_donations[index].shelterItem, index),
        const SizedBox(height: 20),
        _buildDonationInputCard(index),
        const SizedBox(height: 20),
        _buildSectionTitle("Delivery Details:"),
        const SizedBox(height: 10),
        _buildDeliveryDetailsCard(index),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(42, 201, 98, 1),
      body: Column(
        children: [
          _buildTopBar(context),
          const SizedBox(height: 1),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color (0xFFEDE8E5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(1),
                  topRight: Radius.circular(1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_kPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Selected Shelters (${widget.cartItems.length})"),
                    const SizedBox(height: 20),
                    ..._buildDonationSections(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomDonateBar(context),
    );
  }
}
