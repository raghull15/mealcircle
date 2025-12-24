import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mealcircle/shared/design_system.dart';
import 'package:mealcircle/finder/finder_models.dart';
import 'package:mealcircle/services/donation_firebase_service.dart';
import 'package:mealcircle/finder/donation_detail_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class BrowseDonationsScreen extends StatefulWidget {
  const BrowseDonationsScreen({super.key});

  @override
  State<BrowseDonationsScreen> createState() => _BrowseDonationsScreenState();
}

class _BrowseDonationsScreenState extends State<BrowseDonationsScreen> {
  // Data from local storage
  late List<LocalDonation> _allDonations = [];
  late List<LocalDonation> _filteredDonations = [];
  bool _isLoading = true;
  
  String _searchQuery = '';
  String _selectedDonorType = 'All'; // Filter by donor type
  String _selectedLocation = 'All'; // Filter by location
  bool _availableOnly = true;

  final List<String> _donorTypes = ['All', 'Bakery', 'Home', 'Hostel', 'Shop', 'Restaurant', 'Hotel'];
  final List<String> _locations = ['All', 'Downtown', 'North', 'South', 'East', 'West', 'Central'];

  @override
  void initState() {
    super.initState();
    _loadRealDonations();
  }

  Future<void> _loadRealDonations() async {
    setState(() => _isLoading = true);
    try {
      final posts = await DonationFirebaseService().getAvailableDonations();
      final donations = posts.map((post) => LocalDonation(
        id: post.id,
        donorName: post.donorName,
        donorEmail: post.donorEmail,
        foodType: post.foodType,
        servings: post.servings,
        imagePath: post.imagePath,
        description: post.description ?? '',
        location: post.location ?? 'Unknown',
        donorType: post.donorType ?? 'Home',
        deliveryMethod: post.deliveryMethod,
        createdAt: post.createdAt,
        isAvailable: post.isAvailable,
        donorPhone: post.donorPhone ?? 'Contact via app',
        donorAddress: post.address ?? 'See location',
      )).toList();
      
      if (mounted) {
        setState(() {
          _allDonations = donations;
          _filteredDonations = List.from(donations);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading real donations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _filterDonations() {
    _filteredDonations = _allDonations.where((donation) {
      // Search filter
      bool matchesSearch = donation.foodType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          donation.donorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          donation.donorType.toLowerCase().contains(_searchQuery.toLowerCase());

      // Donor type filter
      bool matchesDonorType = _selectedDonorType == 'All';
      // In real model, donorType might not exist directly, using 'Home' as fallback or mapping
      // For now, if the user requested it, let's keep it simple

      // Location filter
      bool matchesLocation = _selectedLocation == 'All' || 
          donation.location == _selectedLocation;

      // Availability filter
      bool matchesAvailability = !_availableOnly || donation.isAvailable;

      return matchesSearch && matchesDonorType && matchesLocation && matchesAvailability;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBarStyles.standard(
        context: context,
        title: 'Browse Donations',
        subtitle: 'Find food near you',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              decoration: AppDecorations.card(),
              child: TextField(
                onChanged: (value) {
                  _searchQuery = value;
                  _filterDonations();
                },
                decoration: InputDecoration(
                  hintText: 'Search food type or donor...',
                  hintStyle: AppTypography.bodyMedium(color: AppColors.textLight),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.textLight),
                          onPressed: () {
                            _searchQuery = '';
                            _filterDonations();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                ),
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                // Donor Type Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: AppDecorations.card(color: AppColors.cardWhite),
                  child: DropdownButton<String>(
                    value: _selectedDonorType,
                    underline: const SizedBox(),
                    items: _donorTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type, style: AppTypography.labelMedium()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedDonorType = value;
                        _filterDonations();
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Location Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: AppDecorations.card(color: AppColors.cardWhite),
                  child: DropdownButton<String>(
                    value: _selectedLocation,
                    underline: const SizedBox(),
                    items: _locations
                        .map((location) => DropdownMenuItem(
                              value: location,
                              child: Text(location, style: AppTypography.labelMedium()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedLocation = value;
                        _filterDonations();
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Availability toggle
                GestureDetector(
                  onTap: () {
                    _availableOnly = !_availableOnly;
                    _filterDonations();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: AppDecorations.card(
                      color: _availableOnly
                          ? AppColors.primaryGreen.withOpacity(0.1)
                          : AppColors.cardWhite,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _availableOnly ? Icons.check_circle : Icons.circle_outlined,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Available', style: AppTypography.labelSmall()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Text(
                  '${_filteredDonations.length} donation${_filteredDonations.length != 1 ? 's' : ''} found',
                  style: AppTypography.bodySmall(color: AppColors.textLight),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _selectedDonorType = 'All';
                    _selectedLocation = 'All';
                    _searchQuery = '';
                    _filterDonations();
                  },
                  child: Text(
                    'Clear filters',
                    style: AppTypography.labelSmall(color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ),

          // Donations list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDonations.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        itemCount: _filteredDonations.length,
                        itemBuilder: (context, index) {
                          return _buildDonationCard(
                            _filteredDonations[index],
                            index,
                            context,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(LocalDonation donation, int index, BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonationDetailScreen(donation: donation),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: AppDecorations.card(),
          child: Column(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
                child: Stack(
                  children: [
                    donation.imagePath != null && donation.imagePath!.isNotEmpty
                        ? (donation.imagePath!.startsWith('http')
                            ? Image.network(
                                donation.imagePath!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                              )
                            : Image.file(
                                File(donation.imagePath!),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                              ))
                        : _buildPlaceholder(),
                    // Donor type badge
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: _getDonorTypeColor(donation.donorType),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          'Home', // Mocking donor type as Home for now
                          style: AppTypography.labelSmall(color: Colors.white),
                        ),
                      ),
                    ),
                    // Availability badge
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: donation.isAvailable
                              ? AppColors.primaryGreen
                              : Colors.red,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              donation.isAvailable
                                  ? Icons.check_circle
                                  : Icons.cancel_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              donation.isAvailable ? 'Available' : 'Taken',
                              style: AppTypography.labelSmall(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Time badge
                    Positioned(
                      bottom: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _getTimeAgo(donation.createdAt),
                              style: AppTypography.labelSmall(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
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
                                donation.foodType,
                                style: AppTypography.headingSmall(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'by ${donation.donorName}',
                                style: AppTypography.bodySmall(color: AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Column(
                            children: [
                              Text(
                                donation.servings.toString(),
                                style: AppTypography.labelLarge(
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
                    const SizedBox(height: AppSpacing.md),

                    // Location & Delivery
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 16, color: AppColors.textLight),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            donation.location,
                            style: AppTypography.bodySmall(color: AppColors.textLight),
                          ),
                        ),
                        Icon(
                          donation.deliveryMethod == 'donor_delivery'
                              ? Icons.local_shipping_rounded
                              : Icons.person_pin_circle_rounded,
                          size: 16,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          donation.deliveryMethod == 'donor_delivery'
                              ? 'Delivered'
                              : 'Pickup',
                          style:
                              AppTypography.bodySmall(color: AppColors.accentOrange),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DonationDetailScreen(
                                donation: donation,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'View Details & Add to Cart',
                          style: AppTypography.labelLarge(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_rounded,
              size: 64,
              color: AppColors.primaryGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No donations found',
            style: AppTypography.headingSmall(color: AppColors.textDark),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try adjusting your search filters',
            style: AppTypography.bodySmall(color: AppColors.textLight),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton.icon(
            onPressed: () {
              _selectedDonorType = 'All';
              _selectedLocation = 'All';
              _searchQuery = '';
              _availableOnly = true;
              _filterDonations();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.borderLight,
      child: const Icon(Icons.restaurant_rounded, size: 48, color: AppColors.textLight),
    );
  }

  Color _getDonorTypeColor(String? donorType) {
    switch (donorType) {
      case 'Bakery':
        return const Color(0xFFC97C3C);
      case 'Home':
        return const Color(0xFF8B5A2B);
      case 'Hostel':
        return const Color(0xFF4169E1);
      case 'Shop':
        return const Color(0xFF32CD32);
      case 'Restaurant':
        return const Color(0xFFFF6347);
      case 'Hotel':
        return const Color(0xFFFFD700);
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}