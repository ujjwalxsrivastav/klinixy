import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/utils/app_constants.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/product/domain/entities/product_entity.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: context.canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: AppColors.textPrimary),
              )
            : null,
        title: SizedBox(
          height: 32,
          child: Image.asset(
            'assets/images/klinixy_logo_transparent.png',
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            color: AppColors.primary,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: uid == null
          ? const _LoginPrompt()
          : _OrdersList(uid: uid),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final String uid;
  const _OrdersList({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.ordersCollection)
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingOrders();
          }

          if (snapshot.hasError) {
            debugPrint('Orders error: ${snapshot.error}');
            // Likely missing composite index — show empty state
            return const _EmptyOrders();
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const _EmptyOrders();
          }

          // Sort locally since composite index may not exist
          final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
          sortedDocs.sort((a, b) {
            final aDate = DateTime.tryParse(
                    (a.data() as Map<String, dynamic>)['placedAt'] as String? ??
                        '') ??
                DateTime(2000);
            final bDate = DateTime.tryParse(
                    (b.data() as Map<String, dynamic>)['placedAt'] as String? ??
                        '') ??
                DateTime(2000);
            return bDate.compareTo(aDate); // descending
          });

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final data =
                  sortedDocs[index].data() as Map<String, dynamic>;
              return _OrderCard(data: data);
            },
          );
        },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OrderCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final orderId = data['id'] as String? ?? '';
    final status = data['status'] as String? ?? 'placed';
    final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0;
    final placedAt = DateTime.tryParse(data['placedAt'] as String? ?? '') ??
        DateTime.now();
    final items = data['items'] as List<dynamic>? ?? [];
    final paymentMethod = data['paymentMethod'] as String? ?? 'cod';

    return TapScale(
      onTap: () => context.push('/order/$orderId/track'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _statusColor(status).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_statusIcon(status),
                        color: _statusColor(status), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${orderId.substring(0, 8).toUpperCase()}',
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a')
                              .format(placedAt),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _statusColor(status),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const AppDivider(),

            // Items preview
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...items.take(2).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Builder(
                              builder: (context) {
                                final String? prodId = item['productId'] as String?;
                                final matchingProduct = MockProducts.all.firstWhere(
                                  (p) => p.id == prodId,
                                  orElse: () => MockProducts.all.first,
                                );
                                return Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: matchingProduct.imageUrls.isEmpty ? AppColors.primaryLight : null,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: matchingProduct.imageUrls.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            matchingProduct.imageUrls.first,
                                            fit: BoxFit.cover,
                                            width: 28,
                                            height: 28,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.medication_rounded,
                                              color: AppColors.primary,
                                              size: 14,
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.medication_rounded,
                                          color: AppColors.primary, size: 14),
                                );
                              }
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item['productName']} x${item['quantity']}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '₹${((item['price'] as num? ?? 0) * (item['quantity'] as num? ?? 1)).toStringAsFixed(0)}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (items.length > 2)
                    Text(
                      '+${items.length - 2} more items',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),

            const AppDivider(),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${totalAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          paymentMethod == 'cod'
                              ? 'Cash on Delivery'
                              : 'Paid Online',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Track button (for active orders)
                  if (status != 'delivered' && status != 'cancelled')
                    TapScale(
                      onTap: () => context.push('/order/$orderId/track'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Track',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (status == 'delivered')
                    TapScale(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Reorder',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'placed':
        return AppColors.primary;
      case 'confirmed':
        return AppColors.secondary;
      case 'packed':
        return AppColors.accent;
      case 'outForDelivery':
      case 'picked':
        return AppColors.accent;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'placed':
        return Icons.check_circle_outline_rounded;
      case 'confirmed':
        return Icons.store_rounded;
      case 'packed':
        return Icons.inventory_2_rounded;
      case 'outForDelivery':
      case 'picked':
        return Icons.two_wheeler_rounded;
      case 'delivered':
        return Icons.home_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'placed':
        return '✓ Placed';
      case 'confirmed':
        return '🏪 Confirmed';
      case 'packed':
        return '📦 Packed';
      case 'outForDelivery':
        return '🛵 On the Way';
      case 'picked':
        return '🛵 Picked Up';
      case 'delivered':
        return '✅ Delivered';
      case 'cancelled':
        return '❌ Cancelled';
      default:
        return status;
    }
  }
}

class _LoadingOrders extends StatelessWidget {
  const _LoadingOrders();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: ShimmerBox(width: double.infinity, height: 180),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text('No orders yet', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 28),
          KlinButton(
            label: 'Start Shopping',
            width: 200,
            height: 48,
            onTap: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('Please login to view orders',
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: 28),
          KlinButton(
            label: 'Login',
            width: 200,
            height: 48,
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
