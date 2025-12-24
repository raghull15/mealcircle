import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

/// Model for donor food posts stored locally
class DonorPostFirebase {
  String id;
  String donorEmail;
  String donorName;
  String? donorPhone;
  String foodType;
  int servings;
  String? imagePath;
  String? description;
  String? address;
  String? location;
  String? donorType;
  String deliveryMethod; // 'donor_delivery' or 'finder_pickup'
  DateTime createdAt;
  bool isAvailable;
  String? orderedBy;
  List<String> requestedBy;

  DonorPostFirebase({
    required this.id,
    required this.donorEmail,
    required this.donorName,
    this.donorPhone,
    required this.foodType,
    required this.servings,
    this.imagePath,
    this.description,
    this.address,
    this.location,
    this.donorType,
    this.deliveryMethod = 'donor_delivery',
    required this.createdAt,
    this.isAvailable = true,
    this.orderedBy,
    List<String>? requestedBy,
  }) : requestedBy = requestedBy ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorEmail': donorEmail,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'foodType': foodType,
      'servings': servings,
      'imagePath': imagePath,
      'description': description,
      'address': address,
      'location': location,
      'donorType': donorType,
      'deliveryMethod': deliveryMethod,
      'createdAt': createdAt.toIso8601String(),
      'isAvailable': isAvailable,
      'orderedBy': orderedBy,
      'requestedBy': requestedBy,
    };
  }

  factory DonorPostFirebase.fromJson(Map<String, dynamic> json) {
    return DonorPostFirebase(
      id: json['id'] ?? '',
      donorEmail: json['donorEmail'] ?? '',
      donorName: json['donorName'] ?? 'Anonymous',
      donorPhone: json['donorPhone'],
      foodType: json['foodType'] ?? '',
      servings: json['servings'] ?? 0,
      imagePath: json['imagePath'],
      description: json['description'],
      address: json['address'],
      location: json['location'],
      donorType: json['donorType'],
      deliveryMethod: json['deliveryMethod'] ?? 'donor_delivery',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isAvailable: json['isAvailable'] ?? true,
      orderedBy: json['orderedBy'],
      requestedBy: List<String>.from(json['requestedBy'] ?? []),
    );
  }
}

/// Local service for managing donor food donations
class DonationFirebaseService {
  static final DonationFirebaseService _instance = DonationFirebaseService._internal();
  factory DonationFirebaseService() => _instance;
  DonationFirebaseService._internal();

  static const String _storageKey = 'local_donations';
  final FirebaseService _firebase = FirebaseService();

  Future<List<DonorPostFirebase>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => DonorPostFirebase.fromJson(item)).toList();
  }

  Future<void> _saveAll(List<DonorPostFirebase> donations) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(donations.map((d) => d.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  /// Create a new donation post
  Future<bool> createDonation(DonorPostFirebase donation) async {
    try {
      final donations = await _loadAll();
      donations.add(donation);
      await _saveAll(donations);
      print('✅ Donation saved locally: ${donation.id}');
      return true;
    } catch (e) {
      print('❌ Error saving donation locally: $e');
      return false;
    }
  }

  /// Get all available donations as a stream
  Stream<List<DonorPostFirebase>> getAvailableDonationsStream() async* {
    // In local mode, we just return the current list as a single-event stream
    // For a real stream, we'd need a StreamController
    final donations = await _loadAll();
    yield donations.where((d) => d.isAvailable).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get all available donations (one-time fetch)
  Future<List<DonorPostFirebase>> getAvailableDonations() async {
    try {
      final donations = await _loadAll();
      return donations.where((d) => d.isAvailable).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('❌ Error fetching donations: $e');
      return [];
    }
  }

  /// Get donations by location
  Future<List<DonorPostFirebase>> getDonationsByLocation(String location) async {
    try {
      final donations = await _loadAll();
      return donations.where((d) => d.isAvailable && d.location == location).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('❌ Error fetching donations by location: $e');
      return [];
    }
  }

  /// Get a single donation by ID
  Future<DonorPostFirebase?> getDonationById(String id) async {
    try {
      final donations = await _loadAll();
      return donations.firstWhere((d) => d.id == id);
    } catch (e) {
      print('❌ Error fetching donation: $e');
      return null;
    }
  }

  /// Get donations by donor email
  Future<List<DonorPostFirebase>> getDonationsByDonor(String donorEmail) async {
    try {
      final donations = await _loadAll();
      return donations.where((d) => d.donorEmail == donorEmail).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('❌ Error fetching donor donations: $e');
      return [];
    }
  }

  /// Mark donation as ordered by a finder
  Future<bool> markAsOrdered(String donationId, String finderEmail) async {
    try {
      final donations = await _loadAll();
      final index = donations.indexWhere((d) => d.id == donationId);
      if (index != -1) {
        donations[index].isAvailable = false;
        donations[index].orderedBy = finderEmail;
        await _saveAll(donations);
        print('✅ Donation marked as ordered locally: $donationId');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error marking donation as ordered: $e');
      return false;
    }
  }

  /// Update donation
  Future<bool> updateDonation(DonorPostFirebase donation) async {
    try {
      final donations = await _loadAll();
      final index = donations.indexWhere((d) => d.id == donation.id);
      if (index != -1) {
        donations[index] = donation;
        await _saveAll(donations);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating donation: $e');
      return false;
    }
  }

  /// Delete donation
  Future<bool> deleteDonation(String donationId) async {
    try {
      final donations = await _loadAll();
      donations.removeWhere((d) => d.id == donationId);
      await _saveAll(donations);
      return true;
    } catch (e) {
      print('❌ Error deleting donation: $e');
      return false;
    }
  }

  /// Generate a unique donation ID
  String generateDonationId() {
    return _firebase.generateId('donation');
  }
}

