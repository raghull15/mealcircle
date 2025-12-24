import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

/// Model for money donations stored locally
class MoneyDonationFirebase {
  String donationId;
  String donorEmail;
  String donorName;
  String shelterName;
  String? shelterEmail;
  double amount;
  String paymentMethod;
  String status; // 'pending', 'completed', 'failed'
  DateTime createdAt;
  String? transactionId;
  String? notes;

  MoneyDonationFirebase({
    required this.donationId,
    required this.donorEmail,
    required this.donorName,
    required this.shelterName,
    this.shelterEmail,
    required this.amount,
    required this.paymentMethod,
    this.status = 'completed',
    required this.createdAt,
    this.transactionId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'donationId': donationId,
      'donorEmail': donorEmail,
      'donorName': donorName,
      'shelterName': shelterName,
      'shelterEmail': shelterEmail,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'transactionId': transactionId,
      'notes': notes,
    };
  }

  factory MoneyDonationFirebase.fromJson(Map<String, dynamic> json) {
    return MoneyDonationFirebase(
      donationId: json['donationId'] ?? '',
      donorEmail: json['donorEmail'] ?? '',
      donorName: json['donorName'] ?? 'Anonymous',
      shelterName: json['shelterName'] ?? '',
      shelterEmail: json['shelterEmail'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Unknown',
      status: json['status'] ?? 'completed',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      transactionId: json['transactionId'],
      notes: json['notes'],
    );
  }
}

/// Local service for managing money donations
class MoneyDonationFirebaseService {
  static final MoneyDonationFirebaseService _instance = MoneyDonationFirebaseService._internal();
  factory MoneyDonationFirebaseService() => _instance;
  MoneyDonationFirebaseService._internal();

  static const String _storageKey = 'local_money_donations';
  final FirebaseService _firebase = FirebaseService();

  Future<List<MoneyDonationFirebase>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => MoneyDonationFirebase.fromJson(item)).toList();
  }

  Future<void> _saveAll(List<MoneyDonationFirebase> donations) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(donations.map((d) => d.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  /// Create a new money donation record
  Future<bool> createMoneyDonation(MoneyDonationFirebase donation) async {
    try {
      final donations = await _loadAll();
      donations.add(donation);
      await _saveAll(donations);
      print('✅ Money donation saved locally: ${donation.donationId}');
      return true;
    } catch (e) {
      print('❌ Error saving money donation: $e');
      return false;
    }
  }

  /// Get donations received by a shelter
  Stream<List<MoneyDonationFirebase>> getDonationsForShelterStream(String shelterName) async* {
    final donations = await _loadAll();
    yield donations.where((d) => d.shelterName == shelterName).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get donations received by a shelter (one-time fetch)
  Future<List<MoneyDonationFirebase>> getDonationsForShelter(String shelterName) async {
    try {
      final donations = await _loadAll();
      return donations.where((d) => d.shelterName == shelterName).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('❌ Error fetching shelter donations: $e');
      return [];
    }
  }

  /// Get donations received by email
  Future<List<MoneyDonationFirebase>> getDonationsForEmail(String email) async {
    try {
      final donations = await _loadAll();
      return donations.where((d) => d.shelterEmail == email).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('❌ Error fetching donations by email: $e');
      return [];
    }
  }

  /// Get donations made by a donor
  Future<List<MoneyDonationFirebase>> getDonationsByDonor(String donorEmail) async {
    try {
      final donations = await _loadAll();
      return donations.where((d) => d.donorEmail == donorEmail).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('❌ Error fetching donor money donations: $e');
      return [];
    }
  }

  /// Get total received by a shelter
  Future<double> getTotalReceivedByShelter(String shelterName) async {
    try {
      final donations = await getDonationsForShelter(shelterName);
      return donations
          .where((d) => d.status == 'completed')
          .fold<double>(0, (sum, d) => sum + d.amount);
    } catch (e) {
      print('❌ Error calculating total: $e');
      return 0;
    }
  }

  /// Get total donated by a donor
  Future<double> getTotalDonatedByDonor(String donorEmail) async {
    try {
      final donations = await getDonationsByDonor(donorEmail);
      return donations
          .where((d) => d.status == 'completed')
          .fold<double>(0, (sum, d) => sum + d.amount);
    } catch (e) {
      print('❌ Error calculating total: $e');
      return 0;
    }
  }

  /// Generate a unique donation ID
  String generateDonationId() {
    return _firebase.generateId('money');
  }
}

