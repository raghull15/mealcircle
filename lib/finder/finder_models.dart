/// Finder Side Data Models
/// All models used across Finder screens in one place
/// No duplicates, clean imports

// ============================================================================
// DONATION MODEL (From Donater Side)
// ============================================================================

class LocalDonation {
  String id;
  String donorName;
  String donorEmail;
  String foodType;
  int servings;
  String? imagePath;
  String description;
  String location;
  String donorType; // 'Bakery', 'Home', 'Hostel', 'Shop', 'Restaurant', 'Hotel'
  String deliveryMethod; // 'donor_delivery' or 'finder_pickup'
  DateTime createdAt;
  bool isAvailable;
  String donorPhone;
  String donorAddress;

  LocalDonation({
    required this.id,
    required this.donorName,
    required this.donorEmail,
    required this.foodType,
    required this.servings,
    this.imagePath,
    required this.description,
    required this.location,
    required this.donorType,
    required this.deliveryMethod,
    required this.createdAt,
    this.isAvailable = true,
    required this.donorPhone,
    required this.donorAddress,
  });

  // Copy with modifications
  LocalDonation copyWith({
    String? id,
    String? donorName,
    String? donorEmail,
    String? foodType,
    int? servings,
    String? imagePath,
    String? description,
    String? location,
    String? donorType,
    String? deliveryMethod,
    DateTime? createdAt,
    bool? isAvailable,
    String? donorPhone,
    String? donorAddress,
  }) {
    return LocalDonation(
      id: id ?? this.id,
      donorName: donorName ?? this.donorName,
      donorEmail: donorEmail ?? this.donorEmail,
      foodType: foodType ?? this.foodType,
      servings: servings ?? this.servings,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      location: location ?? this.location,
      donorType: donorType ?? this.donorType,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      createdAt: createdAt ?? this.createdAt,
      isAvailable: isAvailable ?? this.isAvailable,
      donorPhone: donorPhone ?? this.donorPhone,
      donorAddress: donorAddress ?? this.donorAddress,
    );
  }
}

// ============================================================================
// CART ITEM MODEL (Finder's Cart)
// ============================================================================

class FinderCartItem {
  final LocalDonation donation;
  int requestedServings;
  String? notes;

  // Finder details (auto-filled from donation detail screen)
  String finderName;
  String finderEmail;
  String finderPhone;
  String finderAddress;
  String selectedDeliveryMethod; // 'donor_delivery' or 'finder_pickup'

  FinderCartItem({
    required this.donation,
    int? requestedServings,
    this.notes,
    required this.finderName,
    required this.finderEmail,
    required this.finderPhone,
    required this.finderAddress,
    required this.selectedDeliveryMethod,
  }) : requestedServings = requestedServings ?? donation.servings;

  // Convert to JSON for storage/sending
  Map<String, dynamic> toJson() {
    return {
      'donation': {
        'id': donation.id,
        'donorName': donation.donorName,
        'donorEmail': donation.donorEmail,
        'foodType': donation.foodType,
        'servings': donation.servings,
        'imagePath': donation.imagePath,
        'description': donation.description,
        'location': donation.location,
        'donorType': donation.donorType,
        'deliveryMethod': donation.deliveryMethod,
        'donorPhone': donation.donorPhone,
        'donorAddress': donation.donorAddress,
      },
      'requestedServings': requestedServings,
      'notes': notes,
      'finderName': finderName,
      'finderEmail': finderEmail,
      'finderPhone': finderPhone,
      'finderAddress': finderAddress,
      'selectedDeliveryMethod': selectedDeliveryMethod,
    };
  }

  // Copy with modifications
  FinderCartItem copyWith({
    LocalDonation? donation,
    int? requestedServings,
    String? notes,
    String? finderName,
    String? finderEmail,
    String? finderPhone,
    String? finderAddress,
    String? selectedDeliveryMethod,
  }) {
    return FinderCartItem(
      donation: donation ?? this.donation,
      requestedServings: requestedServings ?? this.requestedServings,
      notes: notes ?? this.notes,
      finderName: finderName ?? this.finderName,
      finderEmail: finderEmail ?? this.finderEmail,
      finderPhone: finderPhone ?? this.finderPhone,
      finderAddress: finderAddress ?? this.finderAddress,
      selectedDeliveryMethod: selectedDeliveryMethod ?? this.selectedDeliveryMethod,
    );
  }
}

// ============================================================================
// ORDER MODEL (For tracking)
// ============================================================================

class Order {
  String orderId;
  String foodType;
  String donorName;
  String donorLocation;
  int servings;
  DateTime orderDate;
  String status; // 'pending', 'confirmed', 'in_transit', 'delivered'
  String imageUrl;
  String deliveryMethod;
  String finderName;
  String finderPhone;

  Order({
    required this.orderId,
    required this.foodType,
    required this.donorName,
    required this.donorLocation,
    required this.servings,
    required this.orderDate,
    required this.status,
    required this.imageUrl,
    required this.deliveryMethod,
    required this.finderName,
    required this.finderPhone,
  });

  // Copy with modifications
  Order copyWith({
    String? orderId,
    String? foodType,
    String? donorName,
    String? donorLocation,
    int? servings,
    DateTime? orderDate,
    String? status,
    String? imageUrl,
    String? deliveryMethod,
    String? finderName,
    String? finderPhone,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      foodType: foodType ?? this.foodType,
      donorName: donorName ?? this.donorName,
      donorLocation: donorLocation ?? this.donorLocation,
      servings: servings ?? this.servings,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      finderName: finderName ?? this.finderName,
      finderPhone: finderPhone ?? this.finderPhone,
    );
  }
}

// ============================================================================
// NOTIFICATION MODEL
// ============================================================================

class FinderNotification {
  String id;
  String title;
  String message;
  DateTime timestamp;
  bool isRead;
  String type; // 'order_update', 'donor_message', 'delivery_confirmation'
  String? icon;

  FinderNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.icon,
  });

  // Copy with modifications
  FinderNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? icon,
  }) {
    return FinderNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      icon: icon ?? this.icon,
    );
  }
}

// ============================================================================
// MONEY DONATION MODEL (Donations received by Finder)
// ============================================================================

class MoneyDonation {
  String id;
  String donorName;
  String donorEmail;
  double amount;
  String message;
  DateTime donatedAt;
  String paymentMethod;
  bool isAnonymous;

  MoneyDonation({
    required this.id,
    required this.donorName,
    required this.donorEmail,
    required this.amount,
    required this.message,
    required this.donatedAt,
    required this.paymentMethod,
    this.isAnonymous = false,
  });

  // Copy with modifications
  MoneyDonation copyWith({
    String? id,
    String? donorName,
    String? donorEmail,
    double? amount,
    String? message,
    DateTime? donatedAt,
    String? paymentMethod,
    bool? isAnonymous,
  }) {
    return MoneyDonation(
      id: id ?? this.id,
      donorName: donorName ?? this.donorName,
      donorEmail: donorEmail ?? this.donorEmail,
      amount: amount ?? this.amount,
      message: message ?? this.message,
      donatedAt: donatedAt ?? this.donatedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
} 