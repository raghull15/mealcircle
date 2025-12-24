import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import 'user_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final UserService _userService = UserService();

  static const String _resetCodesKey = 'password_reset_codes';

  /// Mock Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    return {
      'success': true,
      'message': 'Google sign in successful (Mock)',
      'user': null, // Firebase user object is now null
    };
  }

  /// Mock Sign in with Facebook
  Future<Map<String, dynamic>> signInWithFacebook() async {
    return {
      'success': true,
      'message': 'Facebook sign in successful (Mock)',
      'user': null,
    };
  }

  /// Mock Sign in with Twitter
  Future<Map<String, dynamic>> signInWithTwitter() async {
    return {
      'success': true,
      'message': 'Twitter sign in successful (Mock)',
      'user': null,
    };
  }

  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    try {
      final existingUser = await _userService.loadUser();
      
      if (existingUser == null || existingUser.email != email) {
        return {'success': false, 'message': 'Email not found'};
      }

      final code = _generateResetCode();
      await _saveResetCode(email, code);

      return {
        'success': true,
        'message': 'Reset code sent (Mock)',
        'code': code,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      final savedCode = await _getResetCode(email);
      
      if (savedCode == null) {
        return {'success': false, 'message': 'No reset code found'};
      }

      if (savedCode != code) {
        return {'success': false, 'message': 'Invalid reset code'};
      }

      return {'success': true, 'message': 'Code verified'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      final user = await _userService.loadUser();
      
      if (user == null || user.email != email) {
        return {'success': false, 'message': 'User not found'};
      }

      user.password = newPassword;
      await _userService.saveUser(user);
      await _deleteResetCode(email);

      return {'success': true, 'message': 'Password reset successful'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  String _generateResetCode() {
    return (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
  }

  Future<void> _saveResetCode(String email, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final codes = await _getAllResetCodes();
    codes[email] = {
      'code': code,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_resetCodesKey, jsonEncode(codes));
  }

  Future<String?> _getResetCode(String email) async {
    final codes = await _getAllResetCodes();
    final codeData = codes[email];
    
    if (codeData != null) {
      final timestamp = codeData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now - timestamp < 600000) {
        return codeData['code'] as String;
      } else {
        await _deleteResetCode(email);
      }
    }
    
    return null;
  }

  Future<Map<String, dynamic>> _getAllResetCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final codesJson = prefs.getString(_resetCodesKey);
    if (codesJson != null) {
      return Map<String, dynamic>.from(jsonDecode(codesJson));
    }
    return {};
  }

  Future<void> _deleteResetCode(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final codes = await _getAllResetCodes();
    codes.remove(email);
    await prefs.setString(_resetCodesKey, jsonEncode(codes));
  }

  Future<void> signOut() async {
    await _userService.logout();
  }
}
