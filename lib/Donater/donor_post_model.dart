class DonorPost {
  String id;
  String donorEmail;
  String donorName;
  String? donorPhone;
  String foodType;
  int servings;
  String? imagePath;
  String? description;
  String? address;
  String? location;
  String deliveryMethod;
  DateTime createdAt;
  bool isAvailable;
  List<String> requestedBy;

  DonorPost({
    required this.id,
    required this.donorEmail,
    required this.donorName,
    this.donorPhone,
    required this.foodType,
    required this.servings,
    this.imagePath,
    this.description,
    this.address,
    this.location,
    required this.deliveryMethod,
    required this.createdAt,
    this.isAvailable = true,
    List<String>? requestedBy,
  }) : requestedBy = requestedBy ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorEmail': donorEmail,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'foodType': foodType,
      'servings': servings,
      'imagePath': imagePath,
      'description': description,
      'address': address,
      'location': location,
      'deliveryMethod': deliveryMethod,
      'createdAt': createdAt.toIso8601String(),
      'isAvailable': isAvailable,
      'requestedBy': requestedBy,
    };
  }

  factory DonorPost.fromJson(Map<String, dynamic> json) {
    return DonorPost(
      id: json['id'],
      donorEmail: json['donorEmail'],
      donorName: json['donorName'],
      donorPhone: json['donorPhone'],
      foodType: json['foodType'],
      servings: json['servings'],
      imagePath: json['imagePath'],
      description: json['description'],
      address: json['address'],
      location: json['location'],
      deliveryMethod: json['deliveryMethod'] ?? 'donor_delivery',
      createdAt: DateTime.parse(json['createdAt']),
      isAvailable: json['isAvailable'] ?? true,
      requestedBy: List<String>.from(json['requestedBy'] ?? []),
    );
  }
}