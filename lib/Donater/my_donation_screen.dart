import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'donor_post_model.dart';
import 'donor_post_service.dart';
import 'package:mealcircle/widgets/user_service.dart';
import 'create_donation_post_screen.dart';

const Color _kPrimaryColor = Color(0xFF2AC962);

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  final _postService = DonorPostService();
  final _userService = UserService();
  List<DonorPost> _myPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    setState(() => _isLoading = true);
    
    final user = _userService.currentUser;
    if (user != null && user.email != null) {
      final posts = await _postService.getUserPosts(user.email!);
      if (mounted) {
        setState(() {
          _myPosts = posts;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Post',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this donation post?',
          style: GoogleFonts.playfairDisplay(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.playfairDisplay()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.playfairDisplay(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _postService.deletePost(postId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMyPosts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete post'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleAvailability(DonorPost post) async {
    post.isAvailable = !post.isAvailable;
    final success = await _postService.updatePost(post);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              post.isAvailable
                  ? 'Donation marked as available'
                  : 'Donation marked as unavailable',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadMyPosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E5),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimaryColor))
          : _myPosts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myPosts.length,
                  itemBuilder: (context, index) {
                    return _buildPostCard(_myPosts[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateDonationPostScreen(),
            ),
          );
          if (result == true) {
            _loadMyPosts();
          }
        },
        backgroundColor: _kPrimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Post',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    const double customHeight = 74.0;

    return PreferredSize(
      preferredSize: const Size.fromHeight(customHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: _kPrimaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: customHeight,
            child: Row(
              children: [
                const SizedBox(width: 4.8),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'My Donation',
                    style: GoogleFonts.imFellGreatPrimerSc(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No donations posted yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first donation post!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(DonorPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imagePath != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.file(
                File(post.imagePath!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.foodType,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: post.isAvailable
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: post.isAvailable
                              ? Colors.green.shade300
                              : Colors.red.shade300,
                        ),
                      ),
                      child: Text(
                        post.isAvailable ? 'Available' : 'Unavailable',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: post.isAvailable
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 18, color: _kPrimaryColor),
                    const SizedBox(width: 6),
                    Text(
                      '${post.servings} servings',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                if (post.description != null && post.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.description!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        post.location ?? 'Location not specified',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted ${_formatDate(post.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (post.requestedBy.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${post.requestedBy.length} request(s)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleAvailability(post),
                        icon: Icon(
                          post.isAvailable ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        label: Text(
                          post.isAvailable ? 'Mark Unavailable' : 'Mark Available',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kPrimaryColor,
                          side: const BorderSide(color: _kPrimaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deletePost(post.id),
                        icon: const Icon(Icons.delete, size: 18),
                        label: Text(
                          'Delete',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}