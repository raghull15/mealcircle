import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationModel {
  String id;
  String title;
  String message;
  DateTime timestamp;
  bool isRead;
  String type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'general',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? 'general',
    );
  }
}

class NotificationService {
  static const String _key = 'notifications_list';

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_key);
      
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        return notificationsList.map((json) => NotificationModel.fromJson(json)).toList();
      }
      
      await _initializeSampleNotifications();
      return await getNotifications();
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  Future<bool> addNotification(NotificationModel notification) async {
    try {
      final notifications = await getNotifications();
      notifications.insert(0, notification);

      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_key, notificationsJson);
      return true;
    } catch (e) {
      print('Error adding notification: $e');
      return false;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      
      if (index != -1) {
        notifications[index].isRead = true;

        final prefs = await SharedPreferences.getInstance();
        final notificationsJson = jsonEncode(notifications.map((n) => n.toJson()).toList());
        await prefs.setString(_key, notificationsJson);
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == notificationId);

      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_key, notificationsJson);
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      return true;
    } catch (e) {
      print('Error clearing notifications: $e');
      return false;
    }
  }

  Future<void> _initializeSampleNotifications() async {
    final sampleNotifications = [
      NotificationModel(
        id: 'notif_1',
        title: 'Welcome to MealCircle!',
        message: 'Thank you for joining our community. Start making a difference today!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'welcome',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Donation Request',
        message: 'Orphanage has requested food for 20 people. Can you help?',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: 'request',
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Donation Confirmed',
        message: 'Your donation to Old Age Home has been confirmed. Thank you!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'confirmation',
        isRead: true,
      ),
    ];

    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = jsonEncode(sampleNotifications.map((n) => n.toJson()).toList());
    await prefs.setString(_key, notificationsJson);
  }

  String generateId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}';
  }
}