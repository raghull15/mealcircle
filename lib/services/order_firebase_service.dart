import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

/// Model for finder orders stored locally
class FinderOrder {
  String orderId;
  String finderEmail;
  String finderName;
  String? finderPhone;
  String? finderAddress;
  String donationId;
  String donorEmail;
  String donorName;
  String? donorPhone;
  String? donorAddress;
  String foodType;
  int quantity;
  String deliveryMethod; // 'donor_delivery' or 'finder_pickup'
  String orderStatus; // 'pending', 'confirmed', 'in_transit', 'delivered', 'cancelled'
  DateTime createdAt;
  String? scheduledDateTime;
  String? notes;

  FinderOrder({
    required this.orderId,
    required this.finderEmail,
    required this.finderName,
    this.finderPhone,
    this.finderAddress,
    required this.donationId,
    required this.donorEmail,
    required this.donorName,
    this.donorPhone,
    this.donorAddress,
    required this.foodType,
    required this.quantity,
    this.deliveryMethod = 'donor_delivery',
    this.orderStatus = 'pending',
    required this.createdAt,
    this.scheduledDateTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'finderEmail': finderEmail,
      'finderName': finderName,
      'finderPhone': finderPhone,
      'finderAddress': finderAddress,
      'donationId': donationId,
      'donorEmail': donorEmail,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'donorAddress': donorAddress,
      'foodType': foodType,
      'quantity': quantity,
      'deliveryMethod': deliveryMethod,
      'orderStatus': orderStatus,
      'createdAt': createdAt.toIso8601String(),
      'scheduledDateTime': scheduledDateTime,
      'notes': notes,
    };
  }

  factory FinderOrder.fromJson(Map<String, dynamic> json) {
    return FinderOrder(
      orderId: json['orderId'] ?? '',
      finderEmail: json['finderEmail'] ?? '',
      finderName: json['finderName'] ?? '',
      finderPhone: json['finderPhone'],
      finderAddress: json['finderAddress'],
      donationId: json['donationId'] ?? '',
      donorEmail: json['donorEmail'] ?? '',
      donorName: json['donorName'] ?? '',
      donorPhone: json['donorPhone'],
      donorAddress: json['donorAddress'],
      foodType: json['foodType'] ?? '',
      quantity: json['quantity'] ?? 0,
      deliveryMethod: json['deliveryMethod'] ?? 'donor_delivery',
      orderStatus: json['orderStatus'] ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      scheduledDateTime: json['scheduledDateTime'],
      notes: json['notes'],
    );
  }

  /// Get status display text
  String get statusDisplayText {
    switch (orderStatus) {
      case 'pending':
        return 'Pending Confirmation';
      case 'confirmed':
        return 'Confirmed';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// Get delivery method display text
  String get deliveryMethodDisplayText {
    return deliveryMethod == 'donor_delivery' 
        ? 'Donor will deliver' 
        : 'Pickup by finder';
  }
}

/// Local service for managing finder orders
class OrderFirebaseService {
  static final OrderFirebaseService _instance = OrderFirebaseService._internal();
  factory OrderFirebaseService() => _instance;
  OrderFirebaseService._internal();

  static const String _storageKey = 'local_orders';
  final FirebaseService _firebase = FirebaseService();

  Future<List<FinderOrder>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => FinderOrder.fromJson(item)).toList();
  }

  Future<void> _saveAll(List<FinderOrder> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(orders.map((o) => o.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  /// Create a new order
  Future<bool> createOrder(FinderOrder order) async {
    try {
      final orders = await _loadAll();
      orders.add(order);
      await _saveAll(orders);
      print('✅ Order saved locally: ${order.orderId}');
      return true;
    } catch (e) {
      print('❌ Error saving order locally: $e');
      return false;
    }
  }

  /// Get orders by finder email
  Stream<List<FinderOrder>> getFinderOrdersStream(String finderEmail) async* {
    final orders = await _loadAll();
    yield orders.where((o) => o.finderEmail == finderEmail).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get orders by finder email (one-time fetch)
  Future<List<FinderOrder>> getFinderOrders(String finderEmail) async {
    try {
      final orders = await _loadAll();
      return orders.where((o) => o.finderEmail == finderEmail).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('❌ Error fetching finder orders: $e');
      return [];
    }
  }

  /// Get orders by donor email
  Future<List<FinderOrder>> getDonorOrders(String donorEmail) async {
    try {
      final orders = await _loadAll();
      return orders.where((o) => o.donorEmail == donorEmail).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('❌ Error fetching donor orders: $e');
      return [];
    }
  }

  /// Get orders by donor email
  Stream<List<FinderOrder>> getDonorOrdersStream(String donorEmail) async* {
    final orders = await _loadAll();
    yield orders.where((o) => o.donorEmail == donorEmail).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get a single order by ID
  Future<FinderOrder?> getOrderById(String orderId) async {
    try {
      final orders = await _loadAll();
      return orders.firstWhere((o) => o.orderId == orderId);
    } catch (e) {
      print('❌ Error fetching order: $e');
      return null;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final orders = await _loadAll();
      final index = orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        orders[index].orderStatus = status;
        await _saveAll(orders);
        print('✅ Order status updated locally: $orderId -> $status');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating order status: $e');
      return false;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'cancelled');
  }

  /// Confirm order
  Future<bool> confirmOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'confirmed');
  }

  /// Mark order as delivered
  Future<bool> markAsDelivered(String orderId) async {
    return await updateOrderStatus(orderId, 'delivered');
  }

  /// Generate a unique order ID
  String generateOrderId() {
    return _firebase.generateId('order');
  }
}

