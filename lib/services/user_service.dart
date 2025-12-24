import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import 'firebase_service.dart';

class UserService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  UserModel? _currentUser;
  
  /// Get current user
  UserModel? get currentUser => _currentUser;

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseService _firebase = FirebaseService();
  
  /// Get current user UID (Mocked)
  String? get currentUid => _currentUser?.uid;

  /// Save user locally (SharedPreferences)
  Future<bool> saveUser(UserModel user) async {
    try {
      // 1. Update local state
      _currentUser = user;
      
      // 3. Save locally (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      
      String userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      await prefs.setBool(_isLoggedInKey, true);

      print('✅ User profile saved locally');
      return true;
    } catch (e) {
      print('❌ Error saving user: $e');
      return false;
    }
  }

  /// Load user from local storage
  Future<UserModel?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        Map<String, dynamic> userMap = jsonDecode(userJson);
        _currentUser = UserModel.fromJson(userMap);
      }

      return _currentUser;
    } catch (e) {
      print('❌ Error loading user: $e');
      return null;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    return await saveUser(user);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
      _currentUser = null;
      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Error logging out: $e');
    }
  }

  Future<bool> updateUserType(String userType) async {
    if (_currentUser != null) {
      _currentUser!.userType = userType;
      return await saveUser(_currentUser!);
    }
    return false;
  }

  /// Mock validation check
  Future<bool> validateLogin(String email, String password) async {
    try {
      print('⚠️ Local Mock Login Mode');
      // allow any password for testing
      final mockUser = UserModel(
        email: email,
        name: email.split('@')[0],
        memberSince: DateTime.now().toString().split(' ')[0],
        uid: 'local_uid_${email.hashCode}',
      );
      await saveUser(mockUser);
      return true;
    } catch (e) {
      print('❌ Error in validateLogin: $e');
      return false;
    }
  }

  /// Check if email exists locally
  Future<bool> emailExists(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final localUser = UserModel.fromJson(jsonDecode(userJson));
        return localUser.email == email;
      }
      return false;
    } catch (e) {
      print('❌ Error in emailExists: $e');
      return false;
    }
  }

  Future<bool> updateProfileImage(String imagePath) async {
    if (_currentUser != null) {
      _currentUser!.profileImagePath = imagePath;
      return await saveUser(_currentUser!);
    }
    return false;
  }

  /// Add a donation transaction
  Future<bool> addDonation({
    required int quantity,
    required String shelterName,
    required String shelterId,
  }) async {
    final user = await loadUser();
    if (user != null) {
      user.addDonation(quantity: quantity, shelterName: shelterName);
      return await saveUser(user);
    }
    return false;
  }

  /// Add multiple donation transactions at once
  Future<bool> addMultipleDonations(List<Map<String, dynamic>> donationDataList) async {
    final user = await loadUser();
    if (user != null) {
      for (var data in donationDataList) {
        user.addDonation(
          quantity: data['quantity'] as int,
          shelterName: data['shelterName'] as String,
        );
      }
      return await saveUser(user);
    }
    return false;
  }

  /// Get statistics for the current user
  Future<Map<String, int>> getStatistics() async {
    final user = await loadUser();
    return {
      'totalDonations': user?.totalDonations ?? 0,
      'mealsProvided': user?.mealsProvided ?? 0,
      'sheltersHelped': user?.sheltersHelped ?? 0,
    };
  }

  Future<bool> resetStatistics() async {
    final user = await loadUser();
    if (user != null) {
      user.resetStatistics();
      return await saveUser(user);
    }
    return false;
  }
}

