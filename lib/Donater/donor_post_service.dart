import 'package:mealcircle/services/donation_firebase_service.dart';
import 'donor_post_model.dart';

class DonorPostService {
  static final DonorPostService _instance = DonorPostService._internal();
  factory DonorPostService() => _instance;
  DonorPostService._internal();

  final DonationFirebaseService _firebaseService = DonationFirebaseService();

  /// Convert legacy DonorPost to DonorPostFirebase
  DonorPostFirebase _toFirebase(DonorPost post) {
    return DonorPostFirebase(
      id: post.id,
      donorEmail: post.donorEmail,
      donorName: post.donorName,
      donorPhone: post.donorPhone,
      foodType: post.foodType,
      servings: post.servings,
      imagePath: post.imagePath,
      description: post.description,
      address: post.address,
      location: post.location,
      deliveryMethod: post.deliveryMethod,
      createdAt: post.createdAt,
      isAvailable: post.isAvailable,
      requestedBy: post.requestedBy,
    );
  }

  /// Convert DonorPostFirebase back to legacy DonorPost
  DonorPost _fromFirebase(DonorPostFirebase post) {
    return DonorPost(
      id: post.id,
      donorEmail: post.donorEmail,
      donorName: post.donorName,
      donorPhone: post.donorPhone,
      foodType: post.foodType,
      servings: post.servings,
      imagePath: post.imagePath,
      description: post.description,
      address: post.address,
      location: post.location,
      deliveryMethod: post.deliveryMethod,
      createdAt: post.createdAt,
      isAvailable: post.isAvailable,
      requestedBy: post.requestedBy,
    );
  }

  Future<List<DonorPost>> getAllPosts() async {
    // For Donater side, "all posts" usually means "all posts by this user" 
    // or all available posts depending on context. 
    // Legacy implementation loaded all from SharedPreferences.
    // For now, we'll fetch all available to match general expectation.
    final firebasePosts = await _firebaseService.getAvailableDonations();
    return firebasePosts.map((p) => _fromFirebase(p)).toList();
  }

  Future<List<DonorPost>> getAvailablePosts() async {
    final firebasePosts = await _firebaseService.getAvailableDonations();
    return firebasePosts.map((p) => _fromFirebase(p)).toList();
  }

  Future<List<DonorPost>> getUserPosts(String userEmail) async {
    final firebasePosts = await _firebaseService.getDonationsByDonor(userEmail);
    return firebasePosts.map((p) => _fromFirebase(p)).toList();
  }

  Future<bool> addPost(DonorPost post) async {
    return await _firebaseService.createDonation(_toFirebase(post));
  }

  Future<bool> updatePost(DonorPost updatedPost) async {
    return await _firebaseService.updateDonation(_toFirebase(updatedPost));
  }

  Future<bool> deletePost(String postId) async {
    return await _firebaseService.deleteDonation(postId);
  }

  Future<bool> markAsUnavailable(String postId) async {
    // This is similar to markAsOrdered in DonationFirebaseService
    final post = await _firebaseService.getDonationById(postId);
    if (post != null) {
      post.isAvailable = false;
      return await _firebaseService.updateDonation(post);
    }
    return false;
  }

  Future<bool> addRequest(String postId, String userEmail) async {
    final post = await _firebaseService.getDonationById(postId);
    if (post != null) {
      if (!post.requestedBy.contains(userEmail)) {
        post.requestedBy.add(userEmail);
        return await _firebaseService.updateDonation(post);
      }
      return true; // Already requested
    }
    return false;
  }

  String generatePostId() {
    return _firebaseService.generateDonationId();
  }
}