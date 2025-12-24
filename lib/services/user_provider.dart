import 'package:flutter/foundation.dart';
import 'user_model.dart';
import 'user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  double get balance => _currentUser?.balance ?? 5000;
  List<DonationTransaction> get transactions => _currentUser?.transactions ?? [];
  List<DonationTransaction> get donations => transactions; // Alias for backward compatibility

  Future<void> initialize() async {
    _currentUser = await _userService.loadUser();
    notifyListeners();
  }

  Future<void> setUserType(String userType) async {
    _currentUser ??= UserModel();
    _currentUser!.userType = userType;
    _currentUser!.email = 'user@mealcircle.com'; // Default email for mock, should be handled by Auth
    await _userService.saveUser(_currentUser!);
    notifyListeners();
  }

  Future<void> completeProfile({
    required String name,
    required String phone,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String pincode,
    required String subType,
    String? profileImagePath,
  }) async {
    _currentUser ??= UserModel();
    _currentUser!
      ..name = name
      ..phone = phone
      ..addressLine1 = addressLine1
      ..addressLine2 = addressLine2
      ..city = city
      ..state = state
      ..pincode = pincode
      ..preferredDonationType = subType // subType field in UserData maps to preferredDonationType in UserModel
      ..profileImagePath = profileImagePath;
    
    await _userService.saveUser(_currentUser!);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? profileImagePath,
  }) async {
    if (_currentUser == null) return;

    if (name != null) _currentUser!.name = name;
    if (phone != null) _currentUser!.phone = phone;
    if (addressLine1 != null) _currentUser!.addressLine1 = addressLine1;
    if (addressLine2 != null) _currentUser!.addressLine2 = addressLine2;
    if (city != null) _currentUser!.city = city;
    if (state != null) _currentUser!.state = state;
    if (pincode != null) _currentUser!.pincode = pincode;
    if (profileImagePath != null) _currentUser!.profileImagePath = profileImagePath;

    await _userService.saveUser(_currentUser!);
    notifyListeners();
  }

  Future<void> addDonation({
    required double amount,
    required String charity,
    required String paymentMethod,
  }) async {
    if (_currentUser == null) {
      print('❌ Cannot add donation: currentUser is null');
      return;
    }

    final remainingBalance = _currentUser!.balance - amount;
    if (remainingBalance < 0) {
      throw Exception('Insufficient balance');
    }

    _currentUser!.balance = remainingBalance;
    _currentUser!.transactions.add(
      DonationTransaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        charity: charity,
        paymentMethod: paymentMethod,
        status: 'Successful',
        date: DateTime.now(),
      ),
    );

    _currentUser!.transactions.sort((a, b) => b.date.compareTo(a.date));
    await _userService.saveUser(_currentUser!);
    print('✅ Donation added: $amount to $charity, total transactions: ${_currentUser!.transactions.length}');
    notifyListeners();
  }

  Future<void> logout() async {
    await _userService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _userService.logout();
    _currentUser = null;
    notifyListeners();
  }
  
  // Method to manually reload user data from service
  Future<void> refresh() async {
    _currentUser = await _userService.loadUser();
    notifyListeners();
  }
}