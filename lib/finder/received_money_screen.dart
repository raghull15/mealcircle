import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mealcircle/shared/design_system.dart';
import 'package:mealcircle/finder/finder_models.dart';

class ReceivedMoneyScreen extends StatefulWidget {
  const ReceivedMoneyScreen({super.key});

  @override
  State<ReceivedMoneyScreen> createState() => _ReceivedMoneyScreenState();
}

class _ReceivedMoneyScreenState extends State<ReceivedMoneyScreen> {
  late List<MoneyDonation> _donations;
  double _totalReceived = 0;

  @override
  void initState() {
    super.initState();
    _initializeDummyDonations();
  }

  void _initializeDummyDonations() {
    _donations = [
      MoneyDonation(
        id: 'don_001',
        donorName: 'Generous Donor',
        donorEmail: 'donor1@example.com',
        amount: 500,
        message: 'Supporting your great work!',
        donatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        paymentMethod: 'Credit Card',
        isAnonymous: false,
      ),
      MoneyDonation(
        id: 'don_002',
        donorName: 'Anonymous',
        donorEmail: 'anon@example.com',
        amount: 1000,
        message: 'Keep up the good work helping those in need',
        donatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        paymentMethod: 'UPI',
        isAnonymous: true,
      ),
      MoneyDonation(
        id: 'don_003',
        donorName: 'Tech Corp Foundation',
        donorEmail: 'foundation@techcorp.com',
        amount: 2500,
        message: 'Corporate social responsibility donation for food distribution',
        donatedAt: DateTime.now().subtract(const Duration(days: 1)),
        paymentMethod: 'Bank Transfer',
        isAnonymous: false,
      ),
      MoneyDonation(
        id: 'don_004',
        donorName: 'Anonymous',
        donorEmail: 'anon2@example.com',
        amount: 250,
        message: '',
        donatedAt: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: 'Wallet',
        isAnonymous: true,
      ),
      MoneyDonation(
        id: 'don_005',
        donorName: 'Sarah Johnson',
        donorEmail: 'sarah@example.com',
        amount: 750,
        message: 'Thank you for making a difference in the community!',
        donatedAt: DateTime.now().subtract(const Duration(days: 3)),
        paymentMethod: 'Net Banking',
        isAnonymous: false,
      ),
      MoneyDonation(
        id: 'don_006',
        donorName: 'John Enterprises',
        donorEmail: 'john@enterprises.com',
        amount: 3000,
        message: 'Monthly contribution to the cause',
        donatedAt: DateTime.now().subtract(const Duration(days: 5)),
        paymentMethod: 'Bank Transfer',
        isAnonymous: false,
      ),
    ];

    _totalReceived = _donations.fold(0, (sum, d) => sum + d.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBarStyles.standard(
        context: context,
        title: 'Received Money',
        subtitle: 'Donations you\'ve received',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total Received Card
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Received',
                                style: AppTypography.bodySmall(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '₹${_totalReceived.toStringAsFixed(0)}',
                                style: AppTypography.displayMedium(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outlined,
                              color: Colors.white.withOpacity(0.9), size: 16),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'From ${_donations.length} donors. Every rupee makes a difference!',
                              style: AppTypography.bodySmall(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Total Donors',
                    _donations.length.toString(),
                    Icons.people_rounded,
                  ),
                  _buildStatCard(
                    'Avg. Donation',
                    '₹${(_totalReceived / _donations.length).toStringAsFixed(0)}',
                    Icons.trending_up_rounded,
                  ),
                  _buildStatCard(
                    'Top Donation',
                    '₹${_donations.reduce((a, b) => a.amount > b.amount ? a : b).amount.toStringAsFixed(0)}',
                    Icons.star_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Donations List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Donation History',
                style: AppTypography.headingSmall(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _donations.length,
              itemBuilder: (context, index) {
                return _buildDonationCard(_donations[index], index);
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: AppDecorations.card(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTypography.headingSmall(
                color: AppColors.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodySmall(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(MoneyDonation donation, int index) {
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: AppDecorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.1),
                        AppColors.primaryGreen.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
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
                                  donation.isAnonymous ? 'Anonymous Donor' : donation.donorName,
                                  style: AppTypography.labelMedium(),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                if (!donation.isAnonymous)
                                  Text(
                                    donation.donorEmail,
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
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(
                              '₹${donation.amount.toStringAsFixed(0)}',
                              style: AppTypography.labelLarge(
                                color: AppColors.primaryGreen,
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
            if (donation.message.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCream,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message',
                      style: AppTypography.labelSmall(
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '"${donation.message}"',
                      style: AppTypography.bodySmall(
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.payment_rounded,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      donation.paymentMethod,
                      style: AppTypography.bodySmall(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(donation.donatedAt),
                  style: AppTypography.bodySmall(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}