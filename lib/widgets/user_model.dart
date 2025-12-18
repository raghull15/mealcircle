class UserModel {
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
  int totalDonations;
  int mealsProvided;
  int sheltersHelped;
  String? memberSince;
  String? preferredDonationType;
  String? deliveryMethod;
  bool notificationsEnabled;

  UserModel({
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
    this.totalDonations = 0,
    this.mealsProvided = 0,
    this.sheltersHelped = 0,
    this.memberSince,
    this.preferredDonationType = 'Cooked Food',
    this.deliveryMethod = 'Self Delivery',
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
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
      'totalDonations': totalDonations,
      'mealsProvided': mealsProvided,
      'sheltersHelped': sheltersHelped,
      'memberSince': memberSince,
      'preferredDonationType': preferredDonationType,
      'deliveryMethod': deliveryMethod,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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
      totalDonations: json['totalDonations'] ?? 0,
      mealsProvided: json['mealsProvided'] ?? 0,
      sheltersHelped: json['sheltersHelped'] ?? 0,
      memberSince: json['memberSince'],
      preferredDonationType: json['preferredDonationType'] ?? 'Cooked Food',
      deliveryMethod: json['deliveryMethod'] ?? 'Self Delivery',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
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
