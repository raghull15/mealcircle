import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'cart.dart';
import 'cart_manager.dart';
import 'Donate_screen.dart';
import 'person_details_screen.dart';
import 'group_details_screen.dart';
import 'create_donation_post_screen.dart';
import 'donor_post_model.dart';
import 'donor_post_service.dart';
import 'package:mealcircle/widgets/user_profile_page.dart';
import 'package:mealcircle/widgets/user_service.dart';

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
  final _postService = DonorPostService();
  final _userService = UserService();
  List<DonorPost> _myDonations = [];
  bool _isLoadingDonations = true;

  static const List<Map<String, String>> _baseShelterRequests = [
    {
      "name": "Orphanage",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLlsqWwsG2mrxkfJPEhFHIPXyyhrpccHz7_Q&s"
    },
    {
      "name": "Old Age Home",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7lTg_IbnzEZUzD2nTYHUujXC0Pr4gZdINP5QOMhrGI-OSjxVRhvwuSCLq9TbUw09hRwc&usqp=CAU"
    },
    {
      "name": "Animal Shelter",
      "image": "https://content.jdmagicbox.com/comp/agra/l1/0562px562.x562.221109224605.g6l1/catalogue/caspers-home-agra-animal-shelters-Iqe4iHd7DM.jpg"
    },
    {
      "name": "Community Shelter",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFpCFl6v8Ui52DEjKX_Zh2f5qLKC19VpDKWiUQw84RKlkk8ijjENB0GYbG_hZGQSUG-Uw&usqp=CAU"
    },
    {
      "name": "Child Home",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRB-Ococj4hY8qNslFjfmTA_HO8rGXTFu4wDA&s"
    },
  ];

  static const List<String> _streets = [
    "Kellys Street", "Vadamalai Street", "Chinna Thambi Street", "Anna Salai", "Mount Road"
  ];

  static const List<String> _areas = [
    "Kosapet", "Purasaiwalkam", "Egmore", "Teynampet", "Nungambakkam"
  ];

  late final List<Map<String, dynamic>> shelters = List.generate(
    15,
    (index) {
      final base = _baseShelterRequests[index % _baseShelterRequests.length];
      final distance = (1 + Random().nextDouble() * 10).toStringAsFixed(1);
      final houseNo = 100 + (index * 10 + Random().nextInt(50));
      final street = _streets[index % _streets.length];
      final area = _areas[index % _areas.length];
      final pincode = 600000 + (100 + index * 10);
      
      final shortAddress = "$area, Chn-$pincode";
      
      return {
        "id": index,
        "name": base["name"]!,
        "image": base["image"]!,
        "distance": "$distance miles away",
        "location": shortAddress,
        "fullAddress": "No:$houseNo/${(30 + index).toString().padLeft(2,'0')}, $street, $area, Chn-$pincode",
        "phone": "98765${40000 + index}",
        "contactName": "${base["name"]} Coordinator",
        "contactAge": 35 + (index % 10),
        "contactService": index % 3 == 0 ? "Manager" : index % 3 == 1 ? "Coordinator" : "Supervisor",
        "contactDetails": "Experienced in managing shelter operations and donations.",
        "totalPeople": 50 + (index * 10),
        "groupDetails": "Family-oriented shelter with community programs.",
        "selected": false,
      };
    },
  );

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadMyDonations();
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

  Future<void> _loadMyDonations() async {
    setState(() => _isLoadingDonations = true);
    final user = _userService.currentUser;
    if (user != null && user.email != null) {
      final posts = await _postService.getUserPosts(user.email!);
      if (mounted) {
        setState(() {
          _myDonations = posts;
          _isLoadingDonations = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingDonations = false);
      }
    }
  }

  void _onCartChanged() {
    setState(() {
      for (final shelter in shelters) {
        shelter["selected"] = _cartManager.isSelected(shelter);
      }
    });
  }

  Future<void> _callNumber(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open dialer')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
      backgroundColor: const Color(0xFFEDE8E5),
      appBar: _buildTopAppBar(context),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMyDonationsSection(),
                  const SizedBox(height: 15),
                  _buildCreateDonationButton(),
                  if (searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Available Shelters (${filteredShelters.length})',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...filteredShelters.map((shelter) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      child: _buildShelterListItem(shelter),
                    )),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyDonationsSection() {
    if (_isLoadingDonations) {
      return Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(
          child: CircularProgressIndicator(color: _kPrimaryColor),
        ),
      );
    }

    if (_myDonations.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
          children: [
            Icon(Icons.restaurant, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'No donations posted yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Post your first donation below!',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.fastfood, color: _kPrimaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'My Food Donations',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _myDonations.length,
            itemBuilder: (context, index) {
              return _buildDonationCard(_myDonations[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDonationCard(DonorPost post) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              if (post.imagePath != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.file(
                    File(post.imagePath!),
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Icon(Icons.restaurant, size: 40, color: Colors.grey.shade500),
                ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: post.isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.isAvailable ? 'Available' : 'Unavailable',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.foodType,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people, size: 12, color: _kPrimaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '${post.servings}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(post.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  Widget _buildCreateDonationButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateDonationPostScreen(),
            ),
          );
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Donation posted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadMyDonations();
          }
        },
        icon: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 24),
        label: Text(
          'Post Your Food Donation',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccentColor,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildShelterListItem(Map<String, dynamic> shelter) {
    final String name = shelter["name"] as String;
    final String location = shelter["location"] as String;
    final String distance = shelter["distance"] as String;
    final String imageUrl = shelter["image"] as String;
    final String phone = shelter["phone"] as String;
    final String contactName = shelter["contactName"] as String;
    final int contactAge = shelter["contactAge"] as int;
    final String contactService = shelter["contactService"] as String;
    final String contactDetails = shelter["contactDetails"] as String;
    final int totalPeople = shelter["totalPeople"] as int;
    final String groupDetails = shelter["groupDetails"] as String;
    final bool isSelected = _cartManager.isSelected(shelter);

    return GestureDetector(
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
                height: 90,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[300]),
              ),
            ),
            const SizedBox(width: 13),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PersonDetailScreen(
                                  name: contactName,
                                  age: contactAge,
                                  service: contactService,
                                  details: contactDetails,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.person, 
                              size: 16, 
                              color: Color(0xFF2AC962)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupDetailScreen(
                                  shelterName: name,
                                  totalPeople: totalPeople,
                                  details: groupDetails,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.group, 
                              size: 16, 
                              color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _callNumber(phone),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.phone, 
                              size: 16, 
                              color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$location • $distance",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
    );
  }

  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    const double customHeight = 74.0;

    return PreferredSize(
      preferredSize: const Size.fromHeight(customHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: _kPrimaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: customHeight,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const DonateScreen(),
                ),
              );
            },
          ),
          title: Text(
            "Find Recipients",
            style: GoogleFonts.imFellGreatPrimerSc(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            _buildCartIcon(),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.person_outline,
                  color: Colors.white, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserProfilePage(),
                  ),
                );
              }
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCartIcon() {
    return SizedBox(
      width: 16,
      height: 24,
      child: Stack(
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
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          if (_cartManager.cartCount > 0)
            Positioned(
              right: -10,
              top: -12,
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 38,
        child: TextField(
          onChanged: (v) {
            setState(() => searchQuery = v);
          },
          style: GoogleFonts.poppins(fontSize: 12),
          decoration: InputDecoration(
            hintText: "Search shelters...",
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      setState(() => searchQuery = "");
                    },
                  )
                : null,
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
}