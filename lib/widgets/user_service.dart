import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

class UserService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _uniqueSheltersKey = 'unique_shelters';

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      await prefs.setBool(_isLoggedInKey, true);
      _currentUser = user;
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  Future<UserModel?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString(_userKey);
      if (userJson != null) {
        Map<String, dynamic> userMap = jsonDecode(userJson);
        _currentUser = UserModel.fromJson(userMap);
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Error loading user: $e');
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
    _currentUser = null;
  }

  Future<bool> updateUserType(String userType) async {
    if (_currentUser != null) {
      _currentUser!.userType = userType;
      return await saveUser(_currentUser!);
    }
    return false;
  }

  Future<bool> updateProfileImage(String imagePath) async {
    if (_currentUser != null) {
      _currentUser!.profileImagePath = imagePath;
      return await saveUser(_currentUser!);
    }
    return false;
  }

  Future<bool> emailExists(String email) async {
    final savedUser = await loadUser();
    return savedUser?.email == email;
  }

  Future<bool> validateLogin(String email, String password) async {
    final savedUser = await loadUser();
    if (savedUser != null) {
      return savedUser.email == email && savedUser.password == password;
    }
    return false;
  }

  Future<Set<String>> _getUniqueShelters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sheltersJson = prefs.getString(_uniqueSheltersKey);
      if (sheltersJson != null) {
        final List<dynamic> sheltersList = jsonDecode(sheltersJson);
        return sheltersList.cast<String>().toSet();
      }
      return {};
    } catch (e) {
      print('Error loading unique shelters: $e');
      return {};
    }
  }

  Future<void> _saveUniqueShelters(Set<String> shelters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sheltersJson = jsonEncode(shelters.toList());
      await prefs.setString(_uniqueSheltersKey, sheltersJson);
    } catch (e) {
      print('Error saving unique shelters: $e');
    }
  }

  Future<bool> addDonation({
    required int quantity,
    required String shelterName,
    required String shelterId,
  }) async {
    if (_currentUser == null) {
      await loadUser();
    }

    if (_currentUser != null) {
      _currentUser!.totalDonations++;
      _currentUser!.mealsProvided += quantity;

      final uniqueShelters = await _getUniqueShelters();
      final wasNew = uniqueShelters.add(shelterId);

      if (wasNew) {
        _currentUser!.sheltersHelped++;
        await _saveUniqueShelters(uniqueShelters);
      }

      return await saveUser(_currentUser!);
    }
    return false;
  }

  Future<bool> addMultipleDonations(
    List<Map<String, dynamic>> donations,
  ) async {
    if (_currentUser == null) {
      await loadUser();
    }

    if (_currentUser != null) {
      final uniqueShelters = await _getUniqueShelters();

      for (var donation in donations) {
        if (donation['isCancelled'] != true) {
          _currentUser!.totalDonations++;
          _currentUser!.mealsProvided += (donation['quantity'] as int? ?? 0);

          final shelterId =
              donation['shelterId'] as String? ??
              donation['shelterName'] as String? ??
              'unknown';
          uniqueShelters.add(shelterId);
        }
      }

      _currentUser!.sheltersHelped = uniqueShelters.length;
      await _saveUniqueShelters(uniqueShelters);

      return await saveUser(_currentUser!);
    }
    return false;
  }

  Future<Map<String, int>> getStatistics() async {
    if (_currentUser == null) {
      await loadUser();
    }

    return {
      'totalDonations': _currentUser?.totalDonations ?? 0,
      'mealsProvided': _currentUser?.mealsProvided ?? 0,
      'sheltersHelped': _currentUser?.sheltersHelped ?? 0,
    };
  }

  Future<bool> resetStatistics() async {
    if (_currentUser == null) {
      await loadUser();
    }

    if (_currentUser != null) {
      _currentUser!.totalDonations = 0;
      _currentUser!.mealsProvided = 0;
      _currentUser!.sheltersHelped = 0;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_uniqueSheltersKey);

      return await saveUser(_currentUser!);
    }
    return false;
  }
}
