import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationModel {
  String id;
  String title;
  String message;
  DateTime timestamp;
  bool isRead;
  String type;
  String? shelterName;
  String? shelterImage;
  String? shelterLocation;
  Map<String, dynamic>? shelterData; 

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'general',
    this.shelterName,
    this.shelterImage,
    this.shelterLocation,
    this.shelterData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'shelterName': shelterName,
      'shelterImage': shelterImage,
      'shelterLocation': shelterLocation,
      'shelterData': shelterData,
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
      shelterName: json['shelterName'],
      shelterImage: json['shelterImage'],
      shelterLocation: json['shelterLocation'],
      shelterData: json['shelterData'] != null 
          ? Map<String, dynamic>.from(json['shelterData']) 
          : null,
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

  Future<bool> createShelterRequestNotification({
    required String shelterName,
    required String shelterImage,
    required String shelterLocation,
    required int requestedServings,
    required Map<String, dynamic> shelterData,
  }) async {
    final notification = NotificationModel(
      id: generateId(),
      title: 'Food Request from $shelterName',
      message: '$shelterName has requested food for $requestedServings people. Can you help?',
      timestamp: DateTime.now(),
      type: 'request',
      shelterName: shelterName,
      shelterImage: shelterImage,
      shelterLocation: shelterLocation,
      shelterData: shelterData,
    );

    return await addNotification(notification);
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
        title: 'Food Request from Hope Orphanage',
        message: 'Hope Orphanage has requested food for 30 people. Can you help?',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: 'request',
        shelterName: 'Hope Orphanage',
        shelterImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLlsqWwsG2mrxkfJPEhFHIPXyyhrpccHz7_Q&s',
        shelterLocation: 'Kosapet, Chn-600100',
        shelterData: {
          "id": 0,
          "name": "Hope Orphanage",
          "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLlsqWwsG2mrxkfJPEhFHIPXyyhrpccHz7_Q&s",
          "distance": "2.3 km away",
          "location": "Kosapet, Chn-600100",
          "fullAddress": "No:100/30, Kellys Street, Kosapet, Chennai-600100",
          "address": "No:100/30, Kellys Street, Kosapet, Chennai-600100",
          "phone": "9876540000",
          "contactName": "Hope Orphanage Coordinator",
          "managerName": "Hope Orphanage Manager",
          "contactAge": 35,
          "contactService": "Manager",
          "contactDetails": "Experienced in managing shelter operations and donations.",
          "totalPeople": 50,
          "groupDetails": "Family-oriented shelter with community programs.",
          "selected": false,
        },
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Urgent: Serenity Old Age Home needs support',
        message: 'Serenity Old Age Home has requested immediate food for 25 elderly residents.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: 'request',
        shelterName: 'Serenity Old Age Home',
        shelterImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7lTg_IbnzEZUzD2nTYHUujXC0Pr4gZdINP5QOMhrGI-OSjxVRhvwuSCLq9TbUw09hRwc&usqp=CAU',
        shelterLocation: 'Purasaiwalkam, Chn-600110',
        shelterData: {
          "id": 1,
          "name": "Serenity Old Age Home",
          "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7lTg_IbnzEZUzD2nTYHUujXC0Pr4gZdINP5QOMhrGI-OSjxVRhvwuSCLq9TbUw09hRwc&usqp=CAU",
          "distance": "3.7 km away",
          "location": "Purasaiwalkam, Chn-600110",
          "fullAddress": "No:110/31, Vadamalai Street, Purasaiwalkam, Chennai-600110",
          "address": "No:110/31, Vadamalai Street, Purasaiwalkam, Chennai-600110",
          "phone": "9876540001",
          "contactName": "Serenity Old Age Home Coordinator",
          "managerName": "Serenity Old Age Home Manager",
          "contactAge": 36,
          "contactService": "Coordinator",
          "contactDetails": "Experienced in managing shelter operations and donations.",
          "totalPeople": 60,
          "groupDetails": "Family-oriented shelter with community programs.",
          "selected": false,
        },
      ),
      NotificationModel(
        id: 'notif_4',
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