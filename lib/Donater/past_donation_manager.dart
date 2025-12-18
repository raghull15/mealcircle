import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealcircle/Donater/past_donation_page.dart';

class PastDonationManager {
  static final PastDonationManager _instance = PastDonationManager._internal();
  factory PastDonationManager() => _instance;
  PastDonationManager._internal();

  static const String _storageKey = 'past_donations';
  List<PastDonation> _pastDonations = [];

  List<PastDonation> get allDonations => List.unmodifiable(_pastDonations);

  Future<void> loadDonations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? donationsJson = prefs.getString(_storageKey);

      if (donationsJson != null) {
        final List<dynamic> decodedList = json.decode(donationsJson);
        _pastDonations = decodedList.map((item) {
          return PastDonation(
            shelterItem: Map<String, dynamic>.from(item['shelterItem']),
            foodType: item['foodType'],
            quantity: item['quantity'],
            donationDate: DateTime.parse(item['donationDate']),
            status: item['status'],
            recipientName: item['recipientName'],
            recipientAddress: item['recipientAddress'],
            recipientPhone: item['recipientPhone'],
            deliveryByDonor: item['deliveryByDonor'],
            cancellationReason: item['cancellationReason'],
          );
        }).toList();
      }
    } catch (e) {
      print('Error loading donations: $e');
      _pastDonations = [];
    }
  }

  Future<void> _saveDonations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> donationsList = _pastDonations.map((
        donation,
      ) {
        return {
          'shelterItem': donation.shelterItem,
          'foodType': donation.foodType,
          'quantity': donation.quantity,
          'donationDate': donation.donationDate.toIso8601String(),
          'status': donation.status,
          'recipientName': donation.recipientName,
          'recipientAddress': donation.recipientAddress,
          'recipientPhone': donation.recipientPhone,
          'deliveryByDonor': donation.deliveryByDonor,
          'cancellationReason': donation.cancellationReason,
        };
      }).toList();

      final String donationsJson = json.encode(donationsList);
      await prefs.setString(_storageKey, donationsJson);
    } catch (e) {
      print('Error saving donations: $e');
    }
  }

  Future<void> addDonation(PastDonation donation) async {
    _pastDonations.insert(0, donation);
    await _saveDonations();
  }

  Future<void> addMultipleDonations(List<PastDonation> donations) async {
    for (var donation in donations) {
      _pastDonations.insert(0, donation);
    }
    await _saveDonations();
  }

  Future<void> deleteDonation(PastDonation donation) async {
    _pastDonations.remove(donation);
    await _saveDonations();
  }

  Future<void> clearAll() async {
    _pastDonations.clear();
    await _saveDonations();
  }
}
