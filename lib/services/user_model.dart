class DonationTransaction {
  final String id;
  final double amount;
  final String charity;
  final String paymentMethod;
  final String status;
  final DateTime date;

  DonationTransaction({
    required this.id,
    required this.amount,
    required this.charity,
    required this.paymentMethod,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'charity': charity,
    'paymentMethod': paymentMethod,
    'status': status,
    'date': date.toIso8601String(),
  };

  factory DonationTransaction.fromJson(Map<String, dynamic> json) =>
      DonationTransaction(
        id: json['id'],
        amount: json['amount'].toDouble(),
        charity: json['charity'],
        paymentMethod: json['paymentMethod'],
        status: json['status'],
        date: DateTime.parse(json['date']),
      );
}

class UserModel {
  String? uid;
  String? email;
  String? password;
  String? name;
  String? phone;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? pincode;
  String? userType;
  String? profileImagePath;
  String? shelterImagePath;
  int totalDonations;
  int mealsProvided;
  int sheltersHelped;
  String? memberSince;
  String? preferredDonationType;
  String? deliveryMethod;
  bool notificationsEnabled;
  double balance;
  String? fcmToken;
  List<DonationTransaction> transactions;

  UserModel({
    this.uid,
    this.email,
    this.password,
    this.name,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pincode,
    this.userType,
    this.profileImagePath,
    this.shelterImagePath,
    this.totalDonations = 0,
    this.mealsProvided = 0,
    this.sheltersHelped = 0,
    this.memberSince,
    this.preferredDonationType = 'Cooked Food',
    this.deliveryMethod = 'Self Delivery',
    this.notificationsEnabled = true,
    this.balance = 5000,
    this.fcmToken,
    List<DonationTransaction>? transactions,
  }) : transactions = transactions ?? [];

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'userType': userType,
      'profileImagePath': profileImagePath,
      'shelterImagePath': shelterImagePath,
      'totalDonations': totalDonations,
      'mealsProvided': mealsProvided,
      'sheltersHelped': sheltersHelped,
      'memberSince': memberSince,
      'preferredDonationType': preferredDonationType,
      'deliveryMethod': deliveryMethod,
      'notificationsEnabled': notificationsEnabled,
      'balance': balance,
      'fcmToken': fcmToken,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      phone: json['phone'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      userType: json['userType'],
      profileImagePath: json['profileImagePath'],
      shelterImagePath: json['shelterImagePath'],
      totalDonations: json['totalDonations'] ?? 0,
      mealsProvided: json['mealsProvided'] ?? 0,
      sheltersHelped: json['sheltersHelped'] ?? 0,
      memberSince: json['memberSince'],
      preferredDonationType: json['preferredDonationType'] ?? 'Cooked Food',
      deliveryMethod: json['deliveryMethod'] ?? 'Self Delivery',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      balance: (json['balance'] ?? 5000).toDouble(),
      fcmToken: json['fcmToken'],
      transactions: json['transactions'] != null
          ? List<DonationTransaction>.from(
              (json['transactions'] as List).map(
                (t) => DonationTransaction.fromJson(t as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  String get fullAddress {
    List<String> addressParts = [];
    if (addressLine1 != null && addressLine1!.isNotEmpty) {
      addressParts.add(addressLine1!);
    }
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      addressParts.add(addressLine2!);
    }
    if (city != null && city!.isNotEmpty) {
      addressParts.add(city!);
    }
    if (state != null && state!.isNotEmpty) {
      addressParts.add(state!);
    }
    if (pincode != null && pincode!.isNotEmpty) {
      addressParts.add(pincode!);
    }
    return addressParts.join(', ');
  }

  String get location {
    List<String> locationParts = [];
    if (city != null && city!.isNotEmpty) {
      locationParts.add(city!);
    }
    if (state != null && state!.isNotEmpty) {
      locationParts.add(state!);
    }
    return locationParts.join(', ');
  }

  String? get address => fullAddress;
  set address(String? value) {
    if (value != null && value.isNotEmpty) {
      addressLine1 = value;
    }
  }

  void addDonation({required int quantity, required String shelterName}) {
    totalDonations++;
    mealsProvided += quantity;
    sheltersHelped++;
  }

  void resetStatistics() {
    totalDonations = 0;
    mealsProvided = 0;
    sheltersHelped = 0;
  }
}
