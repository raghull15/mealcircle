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
import 'package:mealcircle/services/user_profile_page.dart';
import 'package:mealcircle/services/user_service.dart';

import 'package:mealcircle/shared/design_system.dart';

// Traditional color scheme replacements handled by AppColors and AppTypography

class RecipientsScreen extends StatefulWidget {
  const RecipientsScreen({super.key});

  @override
  State<RecipientsScreen> createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> with SingleTickerProviderStateMixin {
  final CartManager _cartManager = CartManager();
  final _postService = DonorPostService();
  final _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  List<DonorPost> _myDonations = [];
  bool _isLoadingDonations = true;
  late AnimationController _animationController;

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

  // Fixed names for each shelter
  static const List<String> _shelterNames = [
    "Hope Orphanage",
    "Serenity Old Age Home",
    "Casper's Animal Shelter",
    "Unity Community Shelter",
    "Rainbow Child Home",
    "Sunshine Orphanage",
    "Golden Years Home",
    "Paws & Care Shelter",
    "Haven Community Center",
    "Little Stars Child Home",
    "Bright Future Orphanage",
    "Silver Oak Senior Home",
    "Friends of Animals",
    "Helping Hands Shelter",
    "Children's Paradise"
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
      final fullAddress = "No:$houseNo/${(30 + index).toString().padLeft(2,'0')}, $street, $area, Chennai-$pincode";
      
      return {
        "id": index,
        "name": _shelterNames[index],
        "image": base["image"]!,
        "distance": "$distance km away",
        "location": shortAddress,
        "fullAddress": fullAddress,
        "address": fullAddress,
        "phone": "98765${40000 + index}",
        "contactName": "${_shelterNames[index]} Coordinator",
        "managerName": "${_shelterNames[index]} Manager",
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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadMyDonations();
    for (final shelter in shelters) {
      _cartManager.registerItem(shelter);
      shelter["selected"] = _cartManager.isSelected(shelter);
    }
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cartManager.removeListener(_onCartChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMyDonations() async {
    setState(() => _isLoadingDonations = true);
    final user = await _userService.loadUser();
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
    if (mounted) {
      setState(() {
        for (final shelter in shelters) {
          shelter["selected"] = _cartManager.isSelected(shelter);
        }
      });
    }
  }

  Future<void> _callNumber(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: AppTypography.bodyMedium(color: AppColors.textWhite)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _navigateToCartScreen({required List<Map<String, dynamic>> items}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartScreen(cartItems: items)),
    ).then((shouldRefresh) {
      // Refresh the cart state when returning from cart screen
      if (shouldRefresh == true) {
        _onCartChanged();
        setState(() {}); // Force rebuild to update UI
      }
    });
  }

  void _showEmptyCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.shopping_cart_outlined, color: AppColors.accentOrange, size: 28),
            const SizedBox(width: 12),
            Text("Cart is Empty", style: AppTypography.headingSmall(color: AppColors.textDark)),
          ],
        ),
        content: Text(
          "No shelters selected yet. Browse and select shelters to add them to your cart.",
          style: AppTypography.bodySmall(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: AppTypography.labelLarge(color: AppColors.primaryGreen)),
          )
        ],
      ),
    );
  }

  void _toggleShelterSelection(Map<String, dynamic> shelter) {
    _cartManager.toggleSelection(shelter);
    final bool isSelected = _cartManager.isSelected(shelter);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.remove_circle,
              color: AppColors.textWhite,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isSelected
                    ? '${shelter["name"]} added to cart'
                    : '${shelter["name"]} removed from cart',
                style: AppTypography.bodyMedium(color: AppColors.textWhite),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: isSelected ? AppColors.primaryGreen : AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      searchQuery = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredShelters = shelters.where((shelter) {
      final name = shelter["name"] as String;
      return name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primaryGreen,
        backgroundColor: AppColors.cardWhite,
        child: CustomScrollView(
          slivers: [
            _buildModernAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildMyDonationsSection(),
                  const SizedBox(height: 20),
                  _buildCreateDonationButton(),
                  if (searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSheltersHeader(filteredShelters.length),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            if (searchQuery.isNotEmpty)
              filteredShelters.isEmpty
                  ? SliverToBoxAdapter(
                      child: _buildNoResultsFound(),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildModernShelterCard(filteredShelters[index], index),
                          childCount: filteredShelters.length,
                        ),
                      ),
                    ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Reload donations
    await _loadMyDonations();
    
    // Refresh cart state
    _onCartChanged();
    
    // Small delay for smooth animation
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {});
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.refresh_rounded, color: AppColors.textWhite, size: 20),
              const SizedBox(width: 12),
              Text(
                'Refreshed successfully',
                style: AppTypography.bodyMedium(
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          "Find Recipients",
          style: AppTypography.headingLarge(color: AppColors.textWhite),
        ),
        background: Container(
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
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 20),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DonateScreen()),
        ),
      ),
      actions: [
        _buildModernCartIcon(),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: AppColors.textWhite, size: 20),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserProfilePage()),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildModernCartIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, color: AppColors.textWhite, size: 20),
          ),
          onPressed: () {
            if (_cartManager.cartCount == 0) {
              _showEmptyCartDialog();
            } else {
              _navigateToCartScreen(items: _cartManager.cartItems);
            }
          },
        ),
        if (_cartManager.cartCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentOrange.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                _cartManager.cartCount.toString(),
                style: AppTypography.labelMedium(color: AppColors.textWhite),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBlack.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => searchQuery = v),
          style: AppTypography.bodyMedium(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: "Search for shelters...",
            hintStyle: AppTypography.bodySmall(color: AppColors.textLight),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight, size: 22),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.textLight, size: 20),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 60,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No shelters found',
            style: AppTypography.headingMedium(color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different name',
            style: AppTypography.bodySmall(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.clear, color: AppColors.textWhite, size: 20),
            label: Text(
              'Clear Search',
              style: AppTypography.labelLarge(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyDonationsSection() {
    if (_isLoadingDonations) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 3),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.primaryGreen.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.restaurant_rounded, color: AppColors.textWhite, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'My Food Donations',
                style: AppTypography.headingSmall(color: AppColors.textDark),
              ),
              const Spacer(),
              if (_myDonations.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_myDonations.length}',
                    style: AppTypography.labelMedium(color: AppColors.primaryGreen),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_myDonations.isEmpty)
          _buildEmptyDonationsState()
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _myDonations.length,
              itemBuilder: (context, index) => _buildModernDonationCard(_myDonations[index], index),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyDonationsState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant_menu_rounded, size: 32, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 16),
          Text(
            'No donations yet',
            style: AppTypography.headingSmall(color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Start sharing meals with those in need',
            style: AppTypography.bodySmall(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernDonationCard(DonorPost post, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBlack.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: post.imagePath != null
                      ? Image.file(
                          File(post.imagePath!),
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen.withOpacity(0.2),
                                AppColors.accentOrange.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: Icon(Icons.restaurant, size: 40, color: AppColors.textLight),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: post.isAvailable ? AppColors.primaryGreen : AppColors.errorRed,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (post.isAvailable ? AppColors.primaryGreen : AppColors.errorRed).withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      post.isAvailable ? 'Available' : 'Unavailable',
                      style: AppTypography.labelSmall(color: AppColors.textWhite),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.foodType,
                          style: AppTypography.bodyMedium(color: AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.people_rounded, size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              '${post.servings} servings',
                              style: AppTypography.labelSmall(color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: AppColors.accentOrange),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(post.createdAt),
                          style: AppTypography.labelSmall(color: AppColors.accentOrange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentOrange, AppColors.accentOrange.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateDonationPostScreen()),
            );
            if (result == true && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.textWhite, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Donation posted successfully!',
                        style: AppTypography.labelMedium(color: AppColors.textWhite),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
              _loadMyDonations();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded, color: AppColors.textWhite, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Post Your Food Donation',
                  style: AppTypography.headingMedium(color: AppColors.textWhite),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheltersHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on_rounded, color: AppColors.accentOrange, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Nearby Shelters',
            style: AppTypography.headingSmall(color: AppColors.textDark),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelMedium(color: AppColors.accentOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernShelterCard(Map<String, dynamic> shelter, int index) {
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

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 200 + (index * 30)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.05) : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBlack.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: () => _navigateToCartScreen(items: [shelter]),
            onLongPress: () => _toggleShelterSelection(shelter),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.2),
                              AppColors.accentOrange.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.home_rounded, size: 40, color: AppColors.textLight),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: AppTypography.headingSmall(color: AppColors.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check, color: AppColors.textWhite, size: 16),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: AppTypography.bodySmall(color: AppColors.textLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.directions_walk_rounded, size: 12, color: AppColors.primaryGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    distance,
                                    style: AppTypography.labelSmall(color: AppColors.primaryGreen),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.person_outline_rounded,
                              color: AppColors.primaryGreen,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PersonDetailScreen(
                                    name: contactName,
                                    age: contactAge,
                                    service: contactService,
                                    details: contactDetails,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              icon: Icons.groups_rounded,
                              color: AppColors.accentOrange,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GroupDetailScreen(
                                    shelterName: name,
                                    totalPeople: totalPeople,
                                    details: groupDetails,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              icon: Icons.phone_rounded,
                              color: Colors.blue,
                              onTap: () => _callNumber(phone),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}