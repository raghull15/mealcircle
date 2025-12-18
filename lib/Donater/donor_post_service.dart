import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'donor_post_model.dart';

class DonorPostService {
  static final DonorPostService _instance = DonorPostService._internal();
  factory DonorPostService() => _instance;
  DonorPostService._internal();

  static const String _postsKey = 'donor_posts';

  Future<List<DonorPost>> getAllPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getString(_postsKey);
      
      if (postsJson != null) {
        final List<dynamic> postsList = jsonDecode(postsJson);
        return postsList.map((json) => DonorPost.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading posts: $e');
      return [];
    }
  }

  Future<List<DonorPost>> getAvailablePosts() async {
    final posts = await getAllPosts();
    return posts.where((post) => post.isAvailable).toList();
  }

  Future<List<DonorPost>> getUserPosts(String userEmail) async {
    final posts = await getAllPosts();
    return posts.where((post) => post.donorEmail == userEmail).toList();
  }

  Future<bool> addPost(DonorPost post) async {
    try {
      final posts = await getAllPosts();
      posts.insert(0, post);
      return await _savePosts(posts);
    } catch (e) {
      print('Error adding post: $e');
      return false;
    }
  }

  Future<bool> updatePost(DonorPost updatedPost) async {
    try {
      final posts = await getAllPosts();
      final index = posts.indexWhere((post) => post.id == updatedPost.id);
      
      if (index != -1) {
        posts[index] = updatedPost;
        return await _savePosts(posts);
      }
      return false;
    } catch (e) {
      print('Error updating post: $e');
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final posts = await getAllPosts();
      posts.removeWhere((post) => post.id == postId);
      return await _savePosts(posts);
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  Future<bool> markAsUnavailable(String postId) async {
    try {
      final posts = await getAllPosts();
      final index = posts.indexWhere((post) => post.id == postId);
      
      if (index != -1) {
        posts[index].isAvailable = false;
        return await _savePosts(posts);
      }
      return false;
    } catch (e) {
      print('Error marking post as unavailable: $e');
      return false;
    }
  }

  Future<bool> addRequest(String postId, String userEmail) async {
    try {
      final posts = await getAllPosts();
      final index = posts.indexWhere((post) => post.id == postId);
      
      if (index != -1 && !posts[index].requestedBy.contains(userEmail)) {
        posts[index].requestedBy.add(userEmail);
        return await _savePosts(posts);
      }
      return false;
    } catch (e) {
      print('Error adding request: $e');
      return false;
    }
  }

  Future<bool> _savePosts(List<DonorPost> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = jsonEncode(posts.map((post) => post.toJson()).toList());
      return await prefs.setString(_postsKey, postsJson);
    } catch (e) {
      print('Error saving posts: $e');
      return false;
    }
  }

  String generatePostId() {
    return 'post_${DateTime.now().millisecondsSinceEpoch}';
  }
}