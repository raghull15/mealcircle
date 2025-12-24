import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealcircle/shared/design_system.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/finder/finder_models.dart';

class FinderNotificationScreen extends StatefulWidget {
  const FinderNotificationScreen({super.key});

  @override
  State<FinderNotificationScreen> createState() =>
      _FinderNotificationScreenState();
}

class _FinderNotificationScreenState extends State<FinderNotificationScreen> {
  late List<FinderNotification> _notifications;
  late List<FinderNotification> _filteredNotifications;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _initializeDummyNotifications();
  }

  void _initializeDummyNotifications() {
    _notifications = [
      FinderNotification(
        id: 'notif_001',
        title: 'Order Confirmed!',
        message: 'Sweet Dreams Bakery has confirmed your food request. Delivery at 6 PM.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        type: 'order_update',
        icon: '✅',
      ),
      FinderNotification(
        id: 'notif_002',
        title: 'On The Way!',
        message: 'Your order from Sharma Hostel is on the way. Estimated arrival in 30 minutes.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: false,
        type: 'delivery_confirmation',
        icon: '🚗',
      ),
      FinderNotification(
        id: 'notif_003',
        title: 'Message from Donor',
        message: 'Mrs. Patel: "Food is ready! You can pick it up anytime after 2 PM"',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        type: 'donor_message',
        icon: '💬',
      ),
      FinderNotification(
        id: 'notif_004',
        title: 'Delivery Completed',
        message: 'Your order has been successfully delivered. Please rate the experience.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'order_update',
        icon: '📦',
      ),
      FinderNotification(
        id: 'notif_005',
        title: 'Order Status Update',
        message: 'Delhi Fast Food Shop is preparing your order. Will be ready in 20 minutes.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
        type: 'order_update',
        icon: '⏳',
      ),
      FinderNotification(
        id: 'notif_006',
        title: 'Food Ready for Pickup',
        message: 'Grand Hotel Restaurant: Your food is ready. Please collect within 1 hour.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        type: 'delivery_confirmation',
        icon: '🎁',
      ),
    ];
    _filterNotifications();
  }

  void _filterNotifications() {
    if (_selectedFilter == 'All') {
      _filteredNotifications = List.from(_notifications);
    } else if (_selectedFilter == 'Unread') {
      _filteredNotifications = _notifications.where((n) => !n.isRead).toList();
    } else {
      _filteredNotifications = _notifications
          .where((n) => n.type == _selectedFilter.toLowerCase())
          .toList();
    }
    setState(() {});
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
      _filterNotifications();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Undo delete - re-add notification
            _initializeDummyNotifications();
          },
        ),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Clear All Notifications?',
          style: AppTypography.headingSmall(),
        ),
        content: Text(
          'This action cannot be undone. All notifications will be permanently deleted.',
          style: AppTypography.bodyMedium(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.labelMedium(color: AppColors.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
                _filterNotifications();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All notifications cleared'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _refreshNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: AppSpacing.lg),
            Text('Notifications refreshed'),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBarStyles.standard(
        context: context,
        title: 'Notifications',
        subtitle: 'Stay updated on your orders',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Header with actions
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_filteredNotifications.length} notification${_filteredNotifications.length != 1 ? 's' : ''}',
                        style: AppTypography.bodyMedium(),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '$unreadCount unread',
                            style: AppTypography.labelSmall(color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Action buttons
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'refresh') {
                      _refreshNotifications();
                    } else if (value == 'clear') {
                      _clearAllNotifications();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          const Icon(Icons.refresh_rounded),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Refresh',
                            style: AppTypography.labelMedium(),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded,
                              color: Colors.red),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Clear All',
                            style: AppTypography.labelMedium(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: AppDecorations.card(),
                    child: const Icon(Icons.more_vert_rounded),
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                _buildFilterChip('All', _selectedFilter == 'All'),
                const SizedBox(width: AppSpacing.md),
                _buildFilterChip('Unread', _selectedFilter == 'Unread'),
                const SizedBox(width: AppSpacing.md),
                _buildFilterChip('Updates', _selectedFilter == 'Updates'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Notifications list
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        _filteredNotifications[index],
                        index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _filterNotifications();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: AppDecorations.card(
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.1)
              : AppColors.cardWhite,
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall(
            color: isSelected ? AppColors.primaryGreen : AppColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(FinderNotification notification, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.cardWhite : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: notification.isRead
                ? AppColors.borderLight
                : Colors.blue.withOpacity(0.3),
          ),
          boxShadow: notification.isRead
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      notification.icon ?? '📢',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppTypography.labelLarge(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead) ...[
                              const SizedBox(width: AppSpacing.md),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          notification.message,
                          style: AppTypography.bodySmall(
                            color: AppColors.textLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _getTimeAgo(notification.timestamp),
                          style: AppTypography.captionSmall(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteNotification(notification.id);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded,
                                color: Colors.red),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'Delete',
                              style:
                                  AppTypography.labelSmall(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert_rounded, size: 20),
                  ),
                ],
              ),
            ],
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.primaryGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No notifications',
            style: AppTypography.headingSmall(color: AppColors.textDark),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You\'re all caught up!',
            style: AppTypography.bodySmall(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'order_update':
        return Colors.blue;
      case 'delivery_confirmation':
        return AppColors.primaryGreen;
      case 'donor_message':
        return AppColors.accentOrange;
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}