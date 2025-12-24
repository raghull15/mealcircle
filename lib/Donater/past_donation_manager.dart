import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealcircle/services/firebase_service.dart';
import 'package:mealcircle/services/user_service.dart';
import 'past_donation_page.dart';

class PastDonationManager {
  static final PastDonationManager _instance = PastDonationManager._internal();
  factory PastDonationManager() => _instance;
  PastDonationManager._internal();

  static const String _storageKey = 'local_past_donations';
  final FirebaseService _firebase = FirebaseService();
  final UserService _userService = UserService();
  List<PastDonation> _pastDonations = [];

  List<PastDonation> get allDonations => List.unmodifiable(_pastDonations);

  Future<List<PastDonation>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) {
      return PastDonation(
        shelterItem: Map<String, dynamic>.from(item['shelterItem']),
        foodType: item['foodType'],
        quantity: item['quantity'],
        donationDate: DateTime.tryParse(item['donationDate'] ?? '') ?? DateTime.now(),
        status: item['status'],
        recipientName: item['recipientName'],
        recipientAddress: item['recipientAddress'],
        recipientPhone: item['recipientPhone'],
        deliveryByDonor: item['deliveryByDonor'],
        cancellationReason: item['cancellationReason'],
        donorEmail: item['donorEmail'],
      );
    }).toList().cast<PastDonation>();
  }

  Future<void> _saveAll(List<PastDonation> donations) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(donations.map((d) => {
      'donorEmail': d.donorEmail,
      'shelterItem': d.shelterItem,
      'foodType': d.foodType,
      'quantity': d.quantity,
      'donationDate': d.donationDate.toIso8601String(),
      'status': d.status,
      'recipientName': d.recipientName,
      'recipientAddress': d.recipientAddress,
      'recipientPhone': d.recipientPhone,
      'deliveryByDonor': d.deliveryByDonor,
      'cancellationReason': d.cancellationReason,
    }).toList());
    await prefs.setString(_storageKey, data);
  }

  Future<void> loadDonations() async {
    try {
      final user = await _userService.loadUser();
      if (user == null) {
        _pastDonations = [];
        return;
      }

      final all = await _loadAll();
      _pastDonations = all
          .where((d) => d.donorEmail == user.email)
          .toList()
        ..sort((a, b) => b.donationDate.compareTo(a.donationDate));
    } catch (e) {
      print('❌ Error loading past donations locally: $e');
      _pastDonations = [];
    }
  }

  Future<void> addDonation(PastDonation donation) async {
    try {
      final user = await _userService.loadUser();
      if (user == null) return;

      // Ensure donorEmail is set
      donation.donorEmail = user.email;

      final all = await _loadAll();
      all.add(donation);
      await _saveAll(all);
      
      _pastDonations.insert(0, donation);
      print('✅ Past donation saved locally');
    } catch (e) {
      print('❌ Error adding past donation locally: $e');
    }
  }

  Future<void> addMultipleDonations(List<PastDonation> donations) async {
    for (var donation in donations) {
      await addDonation(donation);
    }
  }

  Future<void> deleteDonation(PastDonation donation) async {
    try {
      final user = await _userService.loadUser();
      if (user == null) return;

      final all = await _loadAll();
      all.removeWhere((d) => 
        d.donorEmail == user.email && 
        d.donationDate.isAtSameMomentAs(donation.donationDate));
      
      await _saveAll(all);
      
      _pastDonations.removeWhere((d) => 
        d.donationDate.isAtSameMomentAs(donation.donationDate));
    } catch (e) {
      print('❌ Error deleting past donation locally: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final user = await _userService.loadUser();
      if (user == null) return;

      final all = await _loadAll();
      all.removeWhere((d) => d.donorEmail == user.email);
      await _saveAll(all);
      
      _pastDonations.clear();
      print('✅ All past donations cleared locally');
    } catch (e) {
      print('❌ Error clearing past donations locally: $e');
    }
  }
}

