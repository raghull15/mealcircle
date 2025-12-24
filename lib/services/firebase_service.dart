/// Firebase Service - Mocked for Local-only mode
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  
  /// Get firestore instance - returns null in mock mode
  dynamic get firestore => null;

  /// Get auth instance - returns null in mock mode
  dynamic get auth => null;

  /// Get storage instance - returns null in mock mode
  dynamic get storage => null;

  /// Initialize Mock - call this in main.dart before runApp
  Future<void> initialize() async {
    _isInitialized = true;
    print('✅ Mock Firebase initialized');
  }

  /// Check if Firebase is available - always false in local mode
  bool get isAvailable => false;

  /// Get a collection reference - returns null
  dynamic collection(String name) => null;

  /// Generate a unique document ID
  String generateId(String prefix) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }
}

