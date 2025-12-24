import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

/// Model for notifications stored locally
class NotificationFirebase {
  String id;
  String recipientEmail;
  String recipientType; // 'donor' or 'finder'
  String title;
  String message;
  String type; // 'food_donation', 'money_donation', 'order_update', 'welcome', 'request'
  DateTime timestamp;
  bool isRead;
  Map<String, dynamic>? data; // Additional data (donation/order details)

  NotificationFirebase({
    required this.id,
    required this.recipientEmail,
    required this.recipientType,
    required this.title,
    required this.message,
    this.type = 'general',
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientEmail': recipientEmail,
      'recipientType': recipientType,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  factory NotificationFirebase.fromJson(Map<String, dynamic> json) {
    return NotificationFirebase(
      id: json['id'] ?? '',
      recipientEmail: json['recipientEmail'] ?? '',
      recipientType: json['recipientType'] ?? 'finder',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      data: json['data'] != null 
          ? Map<String, dynamic>.from(json['data']) 
          : null,
    );
  }
}

/// Local service for managing notifications
class NotificationFirebaseService {
  static final NotificationFirebaseService _instance = NotificationFirebaseService._internal();
  factory NotificationFirebaseService() => _instance;
  NotificationFirebaseService._internal();

  static const String _storageKey = 'local_notifications';
  final FirebaseService _firebase = FirebaseService();

  Future<List<NotificationFirebase>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => NotificationFirebase.fromJson(item)).toList();
  }

  Future<void> _saveAll(List<NotificationFirebase> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  /// Create a new notification
  Future<bool> createNotification(NotificationFirebase notification) async {
    try {
      final notifications = await _loadAll();
      notifications.add(notification);
      await _saveAll(notifications);
      print('✅ Notification created locally: ${notification.id}');
      return true;
    } catch (e) {
      print('❌ Error creating notification locally: $e');
      return false;
    }
  }

  /// Get notifications for a user
  Stream<List<NotificationFirebase>> getNotificationsStream(String email) async* {
    final notifications = await _loadAll();
    yield notifications.where((n) => n.recipientEmail == email).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get notifications for a user (one-time fetch)
  Future<List<NotificationFirebase>> getNotifications(String email) async {
    try {
      final notifications = await _loadAll();
      return notifications.where((n) => n.recipientEmail == email).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return [];
    }
  }

  /// Get notifications by type for a user
  Future<List<NotificationFirebase>> getNotificationsByType(String email, String type) async {
    try {
      final notifications = await _loadAll();
      return notifications.where((n) => n.recipientEmail == email && n.type == type).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('❌ Error fetching notifications by type: $e');
      return [];
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(String email) async {
    try {
      final notifications = await _loadAll();
      return notifications.where((n) => n.recipientEmail == email && !n.isRead).length;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final notifications = await _loadAll();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index].isRead = true;
        await _saveAll(notifications);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead(String email) async {
    try {
      final notifications = await _loadAll();
      for (var n in notifications) {
        if (n.recipientEmail == email) {
          n.isRead = true;
        }
      }
      await _saveAll(notifications);
      return true;
    } catch (e) {
      print('❌ Error marking all as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final notifications = await _loadAll();
      notifications.removeWhere((n) => n.id == notificationId);
      await _saveAll(notifications);
      print('✅ Notification deleted locally: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Clear all notifications for a user
  Future<bool> clearAllNotifications(String email) async {
    try {
      final notifications = await _loadAll();
      notifications.removeWhere((n) => n.recipientEmail == email);
      await _saveAll(notifications);
      print('✅ All notifications cleared locally for $email');
      return true;
    } catch (e) {
      print('❌ Error clearing notifications: $e');
      return false;
    }
  }

  /// Clear all notifications wrapper
  Future<bool> clearAll({required String email}) async {
    return await clearAllNotifications(email);
  }

  // Helper methods for creating specific notification types

  /// Notify finder about new food donation
  Future<bool> notifyFinderNewDonation({
    required String finderEmail,
    required String donorName,
    required String foodType,
    required int servings,
    required String location,
    Map<String, dynamic>? donationData,
  }) async {
    return await createNotification(NotificationFirebase(
      id: generateNotificationId(),
      recipientEmail: finderEmail,
      recipientType: 'finder',
      title: 'New Food Available!',
      message: '$donorName is donating $foodType ($servings servings) near $location',
      type: 'food_donation',
      timestamp: DateTime.now(),
      data: donationData,
    ));
  }

  /// Notify donor about new order
  Future<bool> notifyDonorNewOrder({
    required String donorEmail,
    required String finderName,
    required String foodType,
    required int quantity,
    Map<String, dynamic>? orderData,
  }) async {
    return await createNotification(NotificationFirebase(
      id: generateNotificationId(),
      recipientEmail: donorEmail,
      recipientType: 'donor',
      title: 'New Order Received!',
      message: '$finderName has requested $foodType ($quantity servings)',
      type: 'order_update',
      timestamp: DateTime.now(),
      data: orderData,
    ));
  }

  /// Notify finder about order status update
  Future<bool> notifyFinderOrderUpdate({
    required String finderEmail,
    required String orderId,
    required String status,
    required String foodType,
  }) async {
    String statusMessage;
    switch (status) {
      case 'confirmed':
        statusMessage = 'Your order for $foodType has been confirmed!';
        break;
      case 'in_transit':
        statusMessage = 'Your order for $foodType is on the way!';
        break;
      case 'delivered':
        statusMessage = 'Your order for $foodType has been delivered!';
        break;
      case 'cancelled':
        statusMessage = 'Your order for $foodType has been cancelled.';
        break;
      default:
        statusMessage = 'Your order status has been updated.';
    }

    return await createNotification(NotificationFirebase(
      id: generateNotificationId(),
      recipientEmail: finderEmail,
      recipientType: 'finder',
      title: 'Order Update',
      message: statusMessage,
      type: 'order_update',
      timestamp: DateTime.now(),
      data: {'orderId': orderId, 'status': status},
    ));
  }

  /// Notify finder about money donation received
  Future<bool> notifyFinderMoneyDonation({
    required String finderEmail,
    required String donorName,
    required double amount,
    Map<String, dynamic>? donationData,
  }) async {
    return await createNotification(NotificationFirebase(
      id: generateNotificationId(),
      recipientEmail: finderEmail,
      recipientType: 'finder',
      title: 'Money Donation Received!',
      message: '$donorName has donated ₹${amount.toStringAsFixed(0)} to you',
      type: 'money_donation',
      timestamp: DateTime.now(),
      data: donationData,
    ));
  }

  /// Generate a unique notification ID
  String generateNotificationId() {
    return _firebase.generateId('notif');
  }
}
