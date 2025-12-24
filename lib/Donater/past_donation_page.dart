import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/services/user_profile_page.dart';
import 'package:mealcircle/Donater/past_donation_detail_page.dart';
import 'package:mealcircle/Donater/Donate_screen.dart';
import 'package:mealcircle/Donater/past_donation_manager.dart';

import 'package:mealcircle/shared/design_system.dart';

// Traditional color scheme replacements handled by AppColors and AppTypography

class PastDonation {
  final Map<String, dynamic> shelterItem;
  final String foodType;
  final int quantity;
  final DateTime donationDate;
  final String status;
  final String recipientName;
  final String recipientAddress;
  final String recipientPhone;
  final bool deliveryByDonor;
  final String? cancellationReason;
  String? donorEmail;

  PastDonation({
    required this.shelterItem,
    required this.foodType,
    required this.quantity,
    required this.donationDate,
    required this.status,
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientPhone,
    required this.deliveryByDonor,
    this.cancellationReason,
    this.donorEmail,
  });
}

class PastDonationsPage extends StatefulWidget {
  const PastDonationsPage({super.key});

  @override
  State<PastDonationsPage> createState() => _PastDonationsPageState();
}

class _PastDonationsPageState extends State<PastDonationsPage> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final PastDonationManager _manager = PastDonationManager();
  bool _isLoading = true;
  bool _selectionMode = false;
  Set<PastDonation> _selectedDonations = {};

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDonations() async {
    await _manager.loadDonations();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleDonationSelection(PastDonation donation) {
    setState(() {
      if (_selectedDonations.contains(donation)) {
        _selectedDonations.remove(donation);
        if (_selectedDonations.isEmpty) _selectionMode = false;
      } else {
        _selectedDonations.add(donation);
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      searchQuery = "";
    });
  }

  Future<void> _deleteSelectedDonations() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: Colors.red, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Delete Records',
                      style: AppTypography.labelLarge(color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to delete ${_selectedDonations.length} record(s)? This action cannot be undone.',
                style: AppTypography.bodySmall(color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTypography.labelMedium(color: AppColors.textDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        elevation: 2,
                      ),
                      child: Text(
                        'Delete',
                        style: AppTypography.labelMedium(color: Colors.white),
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

    if (confirm != true) return;

    setState(() => _isLoading = true);
    for (var donation in _selectedDonations) {
      await _manager.deleteDonation(donation);
    }

    setState(() {
      _selectedDonations.clear();
      _selectionMode = false;
      _isLoading = false;
    });
  }

  List<PastDonation> get _filteredDonations {
    final allDonations = _manager.allDonations;
    if (searchQuery.isEmpty) return allDonations;
    return allDonations.where((donation) {
      return donation.shelterItem["name"].toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          donation.foodType.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
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
                _selectionMode
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 24),
                        onPressed: () => setState(() {
                          _selectionMode = false;
                          _selectedDonations.clear();
                        }),
                      )
                    : IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DonateScreen()),
                        ),
                      ),
                Expanded(
                  child: Text(
                    _selectionMode
                        ? "${_selectedDonations.length} Selected"
                        : "Past Donations",
                    style: AppTypography.headingMedium(color: Colors.white),
                  ),
                ),
                if (_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 24),
                    onPressed: _selectedDonations.isEmpty
                        ? null
                        : _deleteSelectedDonations,
                  )
                else
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline,
                          color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UserProfilePage()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => searchQuery = v),
          style: AppTypography.bodySmall(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: "Search by shelter or food type...",
            hintStyle: AppTypography.bodySmall(color: AppColors.textLight),
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.textLight),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: AppColors.textLight, size: 20),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildDonationItem(PastDonation donation) {
    final bool isCancelled = donation.status == "Cancelled";
    final Color statusColor = isCancelled
        ? Colors.red.shade400
        : Colors.green.shade400;
    final IconData statusIcon =
        isCancelled ? Icons.cancel_rounded : Icons.check_circle_rounded;
    final bool isSelected = _selectedDonations.contains(donation);

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
        child: GestureDetector(
          onLongPress: () {
            setState(() {
              _selectionMode = true;
              _toggleDonationSelection(donation);
            });
          },
          onTap: () {
            if (_selectionMode) {
              _toggleDonationSelection(donation);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PastDonationDetailPage(donation: donation),
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryGreen.withOpacity(0.08) : AppColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.primaryGreen, width: 2)
                  : Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_selectionMode)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Checkbox(
                      value: isSelected,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (_) => _toggleDonationSelection(donation),
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: donation.shelterItem["image"] != null && donation.shelterItem["image"]!.isNotEmpty
                      ? (donation.shelterItem["image"]!.startsWith('http')
                          ? Image.network(
                              donation.shelterItem["image"],
                              fit: BoxFit.cover,
                              height: 110,
                              width: 80,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                            )
                          : Image.file(
                              File(donation.shelterItem["image"]),
                              fit: BoxFit.cover,
                              height: 100,
                              width: 80,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                            ))
                      : _buildPlaceholderIcon(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                donation.shelterItem["name"],
                                style: AppTypography.labelLarge(color: isSelected ? AppColors.primaryGreen : AppColors.textDark),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(statusIcon, size: 10, color: statusColor),
                                  const SizedBox(width: 2),
                                  Text(
                                    donation.status,
                                    style: AppTypography.labelSmall(color: statusColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Donated: ${donation.foodType}",
                          style: AppTypography.bodySmall(color: isSelected ? AppColors.primaryGreen : AppColors.textLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${donation.quantity} servings",
                          style: AppTypography.bodySmall(color: isSelected ? AppColors.primaryGreen : AppColors.textLight),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM dd, yyyy')
                              .format(donation.donationDate),
                          style: AppTypography.caption(color: isSelected ? AppColors.primaryGreen : AppColors.textLight.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildPlaceholderIcon() {
    return Container(
      color: AppColors.borderLight,
      height: 90,
      width: 75,
      child: Icon(Icons.home_rounded, size: 30, color: AppColors.textLight),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded,
                size: 50, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 16),
          Text(
            "No Past Donations",
            style: AppTypography.headingSmall(color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            "Your donation history will appear here",
            style: AppTypography.bodySmall(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 3,
              ),
            )
          : Column(
              children: [
                if (!_selectionMode) _buildSearchBar(),
                Expanded(
                  child: _filteredDonations.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: 16,
                          ),
                          itemCount: _filteredDonations.length,
                          itemBuilder: (context, index) {
                            return _buildDonationItem(
                              _filteredDonations[index],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}