import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'recepients.dart';
import 'cart.dart';
import 'cart_manager.dart';

const Color _kPrimaryColor = Color(0xFF2AC962);
const Color _kAccentColor = Colors.orange;

class DonateFoodScreen extends StatefulWidget {
  const DonateFoodScreen({super.key});

  @override
  State<DonateFoodScreen> createState() => _DonateFoodScreenState();
}

class _DonateFoodScreenState extends State<DonateFoodScreen> {
  final Random random = Random();
  final CartManager _cartManager = CartManager();
  late final List<Map<String, dynamic>> requests;
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    final baseRequests = [
      {
        "name": "Orphanage",
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCXxNDifffRsdFFxBr4SV5z_EOGi3SLLfrbw&s"
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
    final locations = [
      "Chennai, Tamil Nadu",
      "Bangalore, Karnataka",
      "Hyderabad, Telangana",
      "Mumbai, Maharashtra",
      "Delhi, India",
      "Kolkata, West Bengal",
      "Pune, Maharashtra",
      "Jaipur, Rajasthan",
      "Chennai, Tamil Nadu",
      "Bangalore, Karnataka",
      "Hyderabad, Telangana",
      "Mumbai, Maharashtra",
      "Delhi, India",
      "Kolkata, West Bengal",
      "Pune, Maharashtra",
    ];

    requests = List.generate(15, (index) {
      final base = baseRequests[index % baseRequests.length];
      final distance = (1 + random.nextDouble() * 4).toStringAsFixed(1);
      return {
        "name": base["name"]!,
        "image": base["image"]!,
        "distance": "$distance miles away",
        "location": locations[index],
        "selected": false,
      };
    });

    for (var request in requests) {
      _cartManager.registerItem(request);
      request["selected"] = _cartManager.isSelected(request);
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
      for (var request in requests) {
        request["selected"] = _cartManager.isSelected(request);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedRequests = isExpanded ? requests : requests.take(6).toList();
    return Scaffold(
      backgroundColor: _kPrimaryColor,
      body: Column(
        children: [
          _buildTopBar(context),
          const SizedBox(height: 12),
          _mealCircleBox(context),
          const SizedBox(height: 12),
          _recentRequestsButton(
            isExpanded: isExpanded,
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: displayedRequests.length,
              itemBuilder: (context, index) {
                final request = displayedRequests[index];
                return _requestButton(
                  request: request,
                  name: request["name"]!,
                  distance: request["distance"]!,
                  image: request["image"]!,
                  isSelected: _cartManager.isSelected(request),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
      decoration: BoxDecoration(
        color: _kPrimaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 3),
            blurRadius: 3,
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
              "Donate Food",
              style: GoogleFonts.imFellGreatPrimerSc(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_cartManager.cartCount == 0) {
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
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CartScreen(
                                cartItems: _cartManager.cartItems,
                              ),
                            ),
                          );
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
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.person_outline,
                        color: Colors.white, size: 25),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealCircleBox(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text(
              "Meal Circle",
              style: GoogleFonts.imFellGreatPrimerSc(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _topButton(
                  label: "Find Recipients",
                  color: _kAccentColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecipientsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _topButton(
                  label: "Past Donations",
                  color: _kPrimaryColor,
                  onPressed: () => debugPrint("Past Donations Clicked"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _topButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label,
          style: GoogleFonts.playfairDisplay(
              fontSize: 15, color: Colors.white)),
    );
  }

  Widget _recentRequestsButton({
    required bool isExpanded,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Recent Requests",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(width: 4),
              Icon(
                isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _requestButton({
    required Map<String, dynamic> request,
    required String name,
    required String distance,
    required String image,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CartScreen(
                cartItems: [request],
              ),
            ),
          );
        },
        onLongPress: () {
          _cartManager.toggleSelection(request);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _cartManager.isSelected(request)
                    ? 'Added to cart'
                    : 'Removed from cart',
              ),
              duration: const Duration(milliseconds: 800),
              backgroundColor: _cartManager.isSelected(request)
                  ? _kPrimaryColor
                  : _kAccentColor,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE6F8EE) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14)),
                child: Image.network(image,
                    height: 90, width: 120, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.person, size: 16, color: _kAccentColor),
                          SizedBox(width: 6),
                          Icon(Icons.group, size: 16, color: Colors.red),
                          SizedBox(width: 6),
                          Icon(Icons.phone, size: 16, color: _kPrimaryColor),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("$name • $distance",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.check_circle, color: _kPrimaryColor, size: 26),
                ),
            ],
          ),
        ),
      ),
    );
  }
}