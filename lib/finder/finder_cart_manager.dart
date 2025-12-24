import 'package:flutter/foundation.dart';
import 'package:mealcircle/finder/finder_models.dart';

/// Enhanced Cart Manager for Finder with all details
class FinderCartManager extends ChangeNotifier {
  static final FinderCartManager _instance = FinderCartManager._internal();
  factory FinderCartManager() => _instance;
  FinderCartManager._internal();

  final List<FinderCartItem> _items = [];

  /// Get all cart items
  List<FinderCartItem> get items => List.unmodifiable(_items);

  /// Get cart item count
  int get itemCount => _items.length;

  /// Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => _items.isNotEmpty;

  /// Get total servings requested
  int get totalServings => 
      _items.fold<int>(0, (sum, item) => sum + item.requestedServings);

  /// Get total number of different donations
  int get totalDonations => _items.length;

  /// Check if a donation is already in cart
  bool isInCart(String donationId) {
    return _items.any((item) => item.donation.id == donationId);
  }

  /// Add item to cart with all finder details
  void addCartItem(FinderCartItem item) {
    // Check if donation already in cart
    final existingIndex = _items.indexWhere(
      (cartItem) => cartItem.donation.id == item.donation.id,
    );

    if (existingIndex != -1) {
      // Update existing item
      _items[existingIndex].requestedServings = item.requestedServings;
      _items[existingIndex].notes = item.notes;
      _items[existingIndex].finderName = item.finderName;
      _items[existingIndex].finderEmail = item.finderEmail;
      _items[existingIndex].finderPhone = item.finderPhone;
      _items[existingIndex].finderAddress = item.finderAddress;
      _items[existingIndex].selectedDeliveryMethod = item.selectedDeliveryMethod;
    } else {
      // Add new item
      _items.add(item);
    }

    notifyListeners();
  }

  /// Add donation to cart (simplified version)
  void addItem(
    LocalDonation donation, {
    int? requestedServings,
    String? notes,
    required String finderName,
    required String finderEmail,
    required String finderPhone,
    required String finderAddress,
    required String selectedDeliveryMethod,
  }) {
    addCartItem(
      FinderCartItem(
        donation: donation,
        requestedServings: requestedServings,
        notes: notes,
        finderName: finderName,
        finderEmail: finderEmail,
        finderPhone: finderPhone,
        finderAddress: finderAddress,
        selectedDeliveryMethod: selectedDeliveryMethod,
      ),
    );
  }

  /// Remove item by donation ID
  void removeItem(String donationId) {
    _items.removeWhere((item) => item.donation.id == donationId);
    notifyListeners();
  }

  /// Remove item by index
  void removeItemAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Update requested servings for a donation
  void updateServings(String donationId, int servings) {
    final index = _items.indexWhere((item) => item.donation.id == donationId);
    if (index != -1) {
      _items[index].requestedServings = servings;
      notifyListeners();
    }
  }

  /// Update notes for a donation
  void updateNotes(String donationId, String notes) {
    final index = _items.indexWhere((item) => item.donation.id == donationId);
    if (index != -1) {
      _items[index].notes = notes;
      notifyListeners();
    }
  }

  /// Update delivery method for a donation
  void updateDeliveryMethod(String donationId, String deliveryMethod) {
    final index = _items.indexWhere((item) => item.donation.id == donationId);
    if (index != -1) {
      _items[index].selectedDeliveryMethod = deliveryMethod;
      notifyListeners();
    }
  }

  /// Update finder details for a cart item
  void updateFinderDetails(
    String donationId, {
    String? finderName,
    String? finderEmail,
    String? finderPhone,
    String? finderAddress,
  }) {
    final index = _items.indexWhere((item) => item.donation.id == donationId);
    if (index != -1) {
      if (finderName != null) _items[index].finderName = finderName;
      if (finderEmail != null) _items[index].finderEmail = finderEmail;
      if (finderPhone != null) _items[index].finderPhone = finderPhone;
      if (finderAddress != null) _items[index].finderAddress = finderAddress;
      notifyListeners();
    }
  }

  /// Get item by donation ID
  FinderCartItem? getItem(String donationId) {
    try {
      return _items.firstWhere((item) => item.donation.id == donationId);
    } catch (_) {
      return null;
    }
  }

  /// Get item by index
  FinderCartItem? getItemAt(int index) {
    if (index >= 0 && index < _items.length) {
      return _items[index];
    }
    return null;
  }

  /// Get cart summary for display
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'totalDonations': totalDonations,
      'totalServings': totalServings,
      'items': _items.map((item) => {
            'donorName': item.donation.donorName,
            'foodType': item.donation.foodType,
            'servings': item.requestedServings,
            'deliveryMethod': item.selectedDeliveryMethod,
            'finderName': item.finderName,
          }).toList(),
    };
  }

  /// Get all cart data for checkout
  Map<String, dynamic> getCheckoutData() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'totalItems': itemCount,
      'totalServings': totalServings,
      'items': _items.map((item) => item.toJson()).toList(),
      'summary': getCartSummary(),
    };
  }

  /// Clear entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Clear cart with notification
  void clearCartWithFeedback() {
    clearCart();
    // Feedback is handled in UI
  }
}