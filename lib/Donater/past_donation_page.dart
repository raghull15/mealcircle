import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/widgets/user_profile_page.dart';
import 'package:mealcircle/Donater/past_donation_detail_page.dart';
import 'package:mealcircle/Donater/Donate_screen.dart';
import 'package:mealcircle/Donater/past_donation_manager.dart';

const Color _kPrimaryColor = Color(0xFF2AC962);

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
  });
}

class PastDonationsPage extends StatefulWidget {
  const PastDonationsPage({super.key});

  @override
  State<PastDonationsPage> createState() => _PastDonationsPageState();
}

class _PastDonationsPageState extends State<PastDonationsPage> {
  String searchQuery = "";
  final PastDonationManager _manager = PastDonationManager();
  bool _isLoading = true;
  bool _selectionMode = false;
  Set<PastDonation> _selectedDonations = {};

  @override
  void initState() {
    super.initState();
    _loadDonations();
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

  Future<void> _deleteSelectedDonations() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirm Delete",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete ${_selectedDonations.length} records?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E5),
      appBar: _buildTopBar(context),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _kPrimaryColor),
            )
          : Column(
              children: [
                if (!_selectionMode) ...[
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 15),
                ],
                Expanded(
                  child: _filteredDonations.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(74.0),
      child: Container(
        decoration: const BoxDecoration(
          color: _kPrimaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              offset: Offset(0, .2),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 74,
          automaticallyImplyLeading: false,
          leading: _selectionMode
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 26),
                  onPressed: () => setState(() {
                    _selectionMode = false;
                    _selectedDonations.clear();
                  }),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DonateScreen()),
                  ),
                ),
          title: Text(
            _selectionMode
                ? "${_selectedDonations.length} Selected"
                : "Past Donations",
            style: GoogleFonts.imFellGreatPrimerSc(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_selectionMode)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: _selectedDonations.isEmpty
                    ? null
                    : _deleteSelectedDonations,
              )
            else
              IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfilePage()),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
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
            hintText: "Search by keyword or location...",
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            prefixIcon: const Icon(Icons.search, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
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
    final IconData statusIcon = isCancelled ? Icons.cancel : Icons.check_circle;
    final bool isSelected = _selectedDonations.contains(donation);

    final double cardHeight = _selectionMode ? 90 : 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 10),
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
                builder: (_) => PastDonationDetailPage(donation: donation),
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? _kPrimaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: _kPrimaryColor, width: 2)
                : null,
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
              if (_selectionMode)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Checkbox(
                    value: isSelected,
                    activeColor: _kPrimaryColor,
                    onChanged: (_) => _toggleDonationSelection(donation),
                  ),
                ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: cardHeight,
                  width: cardHeight,
                  child: Image.network(
                    donation.shelterItem["image"],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[300]),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
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
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? _kPrimaryColor
                                    : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 3),
                                Text(
                                  donation.status,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Donated: ${donation.foodType}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isSelected
                              ? _kPrimaryColor
                              : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        "${donation.quantity} servings",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isSelected
                              ? _kPrimaryColor
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat(
                          'MMMM dd, yyyy',
                        ).format(donation.donationDate),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isSelected
                              ? _kPrimaryColor
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
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
          Icon(Icons.history, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No Past Donations",
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            "Your donation history will appear here",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
