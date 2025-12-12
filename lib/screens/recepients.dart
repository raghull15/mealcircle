import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart.dart';
import 'cart_manager.dart';
import 'home_screen.dart'; 

const Color _kPrimaryColor = Color(0xFF2AC962);
const Color _kAccentColor = Colors.orange;
const Color _kSelectedColor = Color(0xFFE6F8EE);

class RecipientsScreen extends StatefulWidget {
  const RecipientsScreen({super.key});

  @override
  State<RecipientsScreen> createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> {
  final CartManager _cartManager = CartManager();

  static const List<Map<String, String>> _baseShelterRequests = [
    {
      "name": "Orphanage",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLlsqWwsG2mrxkfJPEhFHIPXyyhrpccHz7_Q&s"
    },
    {
      "name": "Old Age Home",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7lTg_IbnzEZUzD2nTYHUujXC0Pr4gZdINP5QOMhrGI-OSjxVRhvwuSCLq9TbUw09hRwc&usqp=CAU"
    },
    {
      "name": "Animal Shelter",
      "image":
          "https://content.jdmagicbox.com/comp/agra/l1/0562px562.x562.221109224605.g6l1/catalogue/caspers-home-agra-animal-shelters-Iqe4iHd7DM.jpg"
    },
    {
      "name": "Community Shelter",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFpCFl6v8Ui52DEjKX_Zh2f5qLKC19VpDKWiUQw84RKlkk8ijjENB0GYbG_hZGQSUG-Uw&usqp=CAU"
    },
    {
      "name": "Child Home",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRB-Ococj4hY8qNslFjfmTA_HO8rGXTFu4wDA&s"
    },
  ];

  static const List<String> _locations = [
    "Chennai, Tamil Nadu",
    "Bangalore, Karnataka",
    "Hyderabad, Telangana",
    "Mumbai, Maharashtra",
    "Delhi, India",
    "Kolkata, West Bengal",
    "Pune, Maharashtra",
    "Jaipur, Rajasthan",
  ];

  late final List<Map<String, dynamic>> shelters = List.generate(
    15,
    (index) {
      final base = _baseShelterRequests[index % _baseShelterRequests.length];
      final distance = (1 + Random().nextDouble() * 10).toStringAsFixed(1);
      return {
        "name": base["name"]!,
        "image": base["image"]!,
        "distance": "$distance miles away",
        "location": _locations[index % _locations.length],
        "selected": false,
      };
    },
  );

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    for (final shelter in shelters) {
      _cartManager.registerItem(shelter);
      shelter["selected"] = _cartManager.isSelected(shelter);
    }
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {
      for (final shelter in shelters) {
        shelter["selected"] = _cartManager.isSelected(shelter);
      }
    });
  }

  void _navigateToCartScreen({required List<Map<String, dynamic>> items}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(cartItems: items),
      ),
    );
  }

  void _showEmptyCartDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cart is Empty"),
          content: const Text("No items are selected."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  void _toggleShelterSelection(Map<String, dynamic> shelter) {
    _cartManager.toggleSelection(shelter);

    final bool isSelected = _cartManager.isSelected(shelter);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSelected
              ? '${shelter["name"]} added to cart'
              : '${shelter["name"]} removed from cart',
        ),
        duration: const Duration(milliseconds: 800),
        backgroundColor: isSelected ? _kPrimaryColor : _kAccentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredShelters = shelters.where((shelter) {
      final name = shelter["name"] as String;
      return name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: _kPrimaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context),
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredShelters.length,
                itemBuilder: (context, index) {
                  final shelter = filteredShelters[index];
                  return _buildShelterListItem(shelter);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
      decoration: BoxDecoration(
        color: _kPrimaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 1,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                );
              },
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
            ),
          ),
          Text(
            "Find Recipients",
            style: GoogleFonts.imFellGreatPrimerSc(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCartIcon(),
                const SizedBox(width: 12),
                const Icon(Icons.person_outline, color: Colors.white, size: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            if (_cartManager.cartCount == 0) {
              _showEmptyCartDialog();
              return;
            }
            _navigateToCartScreen(items: _cartManager.cartItems);
          },
          child: const Icon(Icons.shopping_cart_outlined,
              color: Colors.white, size: 25),
        ),
        if (_cartManager.cartCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: _kAccentColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                _cartManager.cartCount.toString(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 38,
        child: TextField(
          onChanged: (v) => setState(() => searchQuery = v),
          style: GoogleFonts.poppins(fontSize: 12),
          decoration: InputDecoration(
            hintText: "Search shelters...",
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
            prefixIcon: const Icon(Icons.search, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            constraints: const BoxConstraints(minHeight: 38, maxHeight: 38),
          ),
        ),
      ),
    );
  }

  Widget _buildShelterListItem(Map<String, dynamic> shelter) {
    final String name = shelter["name"] as String;
    final String location = shelter["location"] as String;
    final String distance = shelter["distance"] as String;
    final String imageUrl = shelter["image"] as String;
    final bool isSelected = _cartManager.isSelected(shelter);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _navigateToCartScreen(items: [shelter]),
        onLongPress: () => _toggleShelterSelection(shelter),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? _kSelectedColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Image.network(
                  imageUrl,
                  height: 78,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.person, size: 16, color: _kAccentColor),
                          SizedBox(width: 6),
                          Icon(Icons.group, size: 16, color: Colors.red),
                          SizedBox(width: 6),
                          Icon(Icons.phone, size: 16, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$location • $distance",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child:
                      Icon(Icons.check_circle, color: _kPrimaryColor, size: 26),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
