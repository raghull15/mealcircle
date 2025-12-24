import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/shared/design_system.dart';
import 'package:mealcircle/finder/finder_models.dart';
import 'package:mealcircle/finder/finder_order_details_page.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<Order> _activeOrders;
  late List<Order> _pastOrders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeDummyOrders();
  }

  void _initializeDummyOrders() {
    _activeOrders = [
      Order(
        orderId: 'ORD001',
        foodType: 'Fresh Pastries & Bread',
        donorName: 'Sweet Dreams Bakery',
        donorLocation: 'Downtown',
        servings: 10,
        orderDate: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'confirmed',
        imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500&h=500&fit=crop',
        deliveryMethod: 'donor_delivery',
        finderName: 'Rahul Kumar',
        finderPhone: '+91 9876543200',
      ),
      Order(
        orderId: 'ORD002',
        foodType: 'Rice & Curry',
        donorName: 'Sharma Hostel',
        donorLocation: 'Central',
        servings: 25,
        orderDate: DateTime.now().subtract(const Duration(minutes: 30)),
        status: 'pending',
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&h=500&fit=crop',
        deliveryMethod: 'finder_pickup',
        finderName: 'Rahul Kumar',
        finderPhone: '+91 9876543200',
      ),
    ];

    _pastOrders = [
      Order(
        orderId: 'ORD003',
        foodType: 'Homemade Biryani',
        donorName: 'Home Chef - Mrs. Patel',
        donorLocation: 'North',
        servings: 8,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'delivered',
        imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a104?w=500&h=500&fit=crop',
        deliveryMethod: 'donor_delivery',
        finderName: 'Rahul Kumar',
        finderPhone: '+91 9876543200',
      ),
      Order(
        orderId: 'ORD004',
        foodType: 'Samosa & Chaat',
        donorName: 'Delhi Fast Food Shop',
        donorLocation: 'South',
        servings: 15,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'delivered',
        imageUrl: 'https://images.unsplash.com/photo-1631707802837-82e91b0e1e0e?w=500&h=500&fit=crop',
        deliveryMethod: 'finder_pickup',
        finderName: 'Rahul Kumar',
        finderPhone: '+91 9876543200',
      ),
      Order(
        orderId: 'ORD005',
        foodType: 'Mixed Vegetable Platter',
        donorName: 'Grand Hotel Restaurant',
        donorLocation: 'East',
        servings: 20,
        orderDate: DateTime.now().subtract(const Duration(days: 7)),
        status: 'delivered',
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&h=500&fit=crop',
        deliveryMethod: 'donor_delivery',
        finderName: 'Rahul Kumar',
        finderPhone: '+91 9876543200',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBarStyles.standard(
        context: context,
        title: 'My Orders',
        subtitle: 'Track your food requests',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryGreen,
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: AppColors.textLight,
              tabs: [
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping_rounded, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Active (${_activeOrders.length})',
                        style: AppTypography.labelSmall(),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_rounded, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Past (${_pastOrders.length})',
                        style: AppTypography.labelSmall(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Orders
                _buildOrdersList(_activeOrders, isActive: true),
                // Past Orders
                _buildOrdersList(_pastOrders, isActive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, {required bool isActive}) {
    if (orders.isEmpty) {
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
                isActive ? Icons.inbox_rounded : Icons.history_rounded,
                size: 64,
                color: AppColors.primaryGreen.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isActive ? 'No active orders' : 'No past orders',
              style: AppTypography.headingSmall(color: AppColors.textDark),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isActive
                  ? 'Browse donations to place an order'
                  : 'Your completed orders will appear here',
              style: AppTypography.bodySmall(color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], index, context);
      },
    );
  }

  Widget _buildOrderCard(Order order, int index, BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FinderOrderDetailsPage(order: order),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: AppDecorations.card(),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                ),
                child: Image.network(
                  order.imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 120,
                    color: AppColors.borderLight,
                    child: const Icon(Icons.image_not_supported_rounded),
                  ),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.foodType,
                                  style: AppTypography.labelLarge(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'by ${order.donorName}',
                                  style: AppTypography.bodySmall(
                                    color: AppColors.textLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              _getStatusLabel(order.status),
                              style: AppTypography.labelSmall(
                                color: _getStatusColor(order.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(Icons.restaurant_rounded,
                              size: 14, color: AppColors.textLight),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${order.servings} servings',
                            style: AppTypography.bodySmall(
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Icon(Icons.access_time_rounded,
                              size: 14, color: AppColors.textLight),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            DateFormat('MMM dd').format(order.orderDate),
                            style: AppTypography.bodySmall(
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return const Color(0xFF3B82F6);
      case 'in_transit':
        return const Color(0xFF8B5CF6);
      case 'delivered':
        return AppColors.primaryGreen;
      default:
        return AppColors.textLight;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }
}