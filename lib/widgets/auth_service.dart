// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'user_model.dart';
// import 'user_service.dart';

// class AuthService {
//   static final AuthService _instance = AuthService._internal();
//   factory AuthService() => _instance;
//   AuthService._internal();

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final UserService _userService = UserService();

//   static const String _resetCodesKey = 'password_reset_codes';

//   Future<Map<String, dynamic>> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
//       if (googleUser == null) {
//         return {'success': false, 'message': 'Sign in cancelled'};
//       }

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final UserCredential userCredential = await _auth.signInWithCredential(credential);
//       final User? firebaseUser = userCredential.user;

//       if (firebaseUser != null) {
//         final existingUser = await _userService.loadUser();
        
//         if (existingUser?.email != firebaseUser.email) {
//           final newUser = UserModel(
//             email: firebaseUser.email,
//             name: firebaseUser.displayName ?? googleUser.displayName,
//             phone: firebaseUser.phoneNumber,
//             profileImagePath: firebaseUser.photoURL,
//             memberSince: DateTime.now().toString().split(' ')[0],
//           );
          
//           await _userService.saveUser(newUser);
//         }

//         return {
//           'success': true,
//           'message': 'Google sign in successful',
//           'user': firebaseUser,
//         };
//       }

//       return {'success': false, 'message': 'Failed to sign in with Google'};
//     } catch (e) {
//       return {'success': false, 'message': 'Error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> signInWithFacebook() async {
//     try {
//       final LoginResult result = await FacebookAuth.instance.login();

//       if (result.status == LoginStatus.success) {
//         final AccessToken accessToken = result.accessToken!;
        
//         final OAuthCredential credential = FacebookAuthProvider.credential(
//           accessToken.tokenString,
//         );

//         final UserCredential userCredential = await _auth.signInWithCredential(credential);
//         final User? firebaseUser = userCredential.user;

//         if (firebaseUser != null) {
//           final userData = await FacebookAuth.instance.getUserData();
          
//           final existingUser = await _userService.loadUser();
          
//           if (existingUser?.email != firebaseUser.email) {
//             final newUser = UserModel(
//               email: firebaseUser.email ?? userData['email'],
//               name: firebaseUser.displayName ?? userData['name'],
//               profileImagePath: userData['picture']?['data']?['url'],
//               memberSince: DateTime.now().toString().split(' ')[0],
//             );
            
//             await _userService.saveUser(newUser);
//           }

//           return {
//             'success': true,
//             'message': 'Facebook sign in successful',
//             'user': firebaseUser,
//           };
//         }
//       } else if (result.status == LoginStatus.cancelled) {
//         return {'success': false, 'message': 'Sign in cancelled'};
//       }

//       return {'success': false, 'message': 'Failed to sign in with Facebook'};
//     } catch (e) {
//       return {'success': false, 'message': 'Error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> signInWithTwitter() async {
//     try {
//       final TwitterAuthProvider twitterProvider = TwitterAuthProvider();
      
//       final UserCredential userCredential = await _auth.signInWithProvider(twitterProvider);
//       final User? firebaseUser = userCredential.user;

//       if (firebaseUser != null) {
//         final existingUser = await _userService.loadUser();
        
//         if (existingUser?.email != firebaseUser.email) {
//           final newUser = UserModel(
//             email: firebaseUser.email,
//             name: firebaseUser.displayName,
//             profileImagePath: firebaseUser.photoURL,
//             memberSince: DateTime.now().toString().split(' ')[0],
//           );
          
//           await _userService.saveUser(newUser);
//         }

//         return {
//           'success': true,
//           'message': 'Twitter sign in successful',
//           'user': firebaseUser,
//         };
//       }

//       return {'success': false, 'message': 'Failed to sign in with Twitter'};
//     } catch (e) {
//       return {'success': false, 'message': 'Error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
//     try {
//       final existingUser = await _userService.loadUser();
      
//       if (existingUser == null || existingUser.email != email) {
//         return {'success': false, 'message': 'Email not found'};
//       }

//       final code = _generateResetCode();
//       await _saveResetCode(email, code);

//       return {
//         'success': true,
//         'message': 'Reset code sent to your email',
//         'code': code,
//       };
//     } catch (e) {
//       return {'success': false, 'message': 'Error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
//     try {
//       final savedCode = await _getResetCode(email);
      
//       if (savedCode == null) {
//         return {'success': false, 'message': 'No reset code found'};
//       }

//       if (savedCode != code) {
//         return {'success': false, 'message': 'Invalid reset code'};
//       }

//       return {'success': true, 'message': 'Code verified'};
//     } catch (e) {
//       return {'success': false, 'message': 'Error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
//     try {
//       final user = await _userService.loadUser();
      
//       if (user == null || user.email != email) {
//         return {'success': false, 'message': 'User not found'};
//       }

//       user.password = newPassword;
//       await _userService.saveUser(user);
//       await _deleteResetCode(email);

//       return {'success': true, 'message': 'Password reset successful'};
//     } catch (e) {
//       return {'success': false, 'message': 'Error: $e'};
//     }
//   }

//   String _generateResetCode() {
//     return (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
//   }

//   Future<void> _saveResetCode(String email, String code) async {
//     final prefs = await SharedPreferences.getInstance();
//     final codes = await _getAllResetCodes();
//     codes[email] = {
//       'code': code,
//       'timestamp': DateTime.now().millisecondsSinceEpoch,
//     };
//     await prefs.setString(_resetCodesKey, jsonEncode(codes));
//   }

//   Future<String?> _getResetCode(String email) async {
//     final codes = await _getAllResetCodes();
//     final codeData = codes[email];
    
//     if (codeData != null) {
//       final timestamp = codeData['timestamp'] as int;
//       final now = DateTime.now().millisecondsSinceEpoch;
      
//       if (now - timestamp < 600000) {
//         return codeData['code'] as String;
//       } else {
//         await _deleteResetCode(email);
//       }
//     }
    
//     return null;
//   }

//   Future<Map<String, dynamic>> _getAllResetCodes() async {
//     final prefs = await SharedPreferences.getInstance();
//     final codesJson = prefs.getString(_resetCodesKey);
//     if (codesJson != null) {
//       return Map<String, dynamic>.from(jsonDecode(codesJson));
//     }
//     return {};
//   }

//   Future<void> _deleteResetCode(String email) async {
//     final prefs = await SharedPreferences.getInstance();
//     final codes = await _getAllResetCodes();
//     codes.remove(email);
//     await prefs.setString(_resetCodesKey, jsonEncode(codes));
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await FacebookAuth.instance.logOut();
//     await _auth.signOut();
//     await _userService.logout();
//   }
// }