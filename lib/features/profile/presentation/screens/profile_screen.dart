import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/auth/domain/entities/user_entity.dart';
import 'package:klinixy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/product/presentation/bloc/wishlist_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Header
                    SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
                          child: Row(
                            children: [
                              // Klinixy logo in header
                              SizedBox(
                                height: 32,
                                child: Image.asset(
                                  'assets/images/klinixy_logo_transparent.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerLeft,
                                  color: AppColors.primary,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                              const Spacer(),
                              TapScale(
                                onTap: () => _showSettingsSheet(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.divider, width: 1),
                                  ),
                                  child: const Icon(Icons.settings_outlined,
                                      color: AppColors.textSecondary, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Profile card
                        _ProfileCard(user: user),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions',
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _QuickAction(
                            icon: Icons.receipt_long_rounded,
                            label: 'My Orders',
                            color: AppColors.primary,
                            onTap: () => context.push('/orders'),
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.favorite_rounded,
                            label: 'Wishlist',
                            color: AppColors.error,
                            onTap: () => _showWishlistSheet(context),
                          ),
                          const SizedBox(width: 12),
                           _QuickAction(
                            icon: Icons.location_on_rounded,
                            label: 'Addresses',
                            color: AppColors.accent,
                            onTap: () => context.push('/profile/addresses'),
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.description_rounded,
                            label: 'Prescriptions',
                            color: AppColors.secondary,
                            onTap: () => _showPrescriptionsSheet(context, user),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Menu items
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      _MenuSection(
                        items: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Edit Profile',
                            onTap: () => _showEditProfileSheet(context, user),
                          ),
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: () => _showNotificationsSheet(context),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '3 New',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Icons.credit_card_rounded,
                            label: 'Payment Methods',
                            onTap: () => _showPaymentMethodsSheet(context),
                          ),
                          _MenuItem(
                            icon: Icons.support_agent_rounded,
                            label: 'Help & Support',
                            onTap: () => _showHelpSupportSheet(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Legal', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      _MenuSection(
                        items: [
                          _MenuItem(
                            icon: Icons.policy_outlined,
                            label: 'Privacy Policy',
                            onTap: () => _showLegalDialog(context, 'Privacy Policy', _privacyPolicyContent),
                          ),
                          _MenuItem(
                            icon: Icons.description_outlined,
                            label: 'Terms of Service',
                            onTap: () => _showLegalDialog(context, 'Terms of Service', _termsOfServiceContent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Sign out
                      TapScale(
                        onTap: () => _showSignOutDialog(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded,
                                  color: AppColors.error, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Sign Out',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Klinixy v1.0.0 • Made with ❤️',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text('Sign Out', style: AppTextStyles.headlineMedium),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showWishlistSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('My Wishlist', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<WishlistBloc, WishlistState>(
                builder: (context, state) {
                  if (state.items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite_border_rounded,
                              size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text('Your Wishlist is Empty',
                              style: AppTextStyles.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                            'Save your favorite items here to purchase later!',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const AppDivider(),
                    itemBuilder: (context, index) {
                      final product = state.items[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          ctx.push('/product/${product.id}');
                        },
                        child: Row(
                          children: [
                            // Product Image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: product.imageUrls.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        product.imageUrls.first,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.medication_rounded,
                                      color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: AppTextStyles.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    product.brand,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${product.price.toStringAsFixed(0)}',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Action Row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Add to cart
                                TapScale(
                                  onTap: () {
                                    context.read<CartBloc>().add(CartAddItem(product));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} added to cart! 🛒'),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Delete from wishlist
                                TapScale(
                                  onTap: () {
                                    context.read<WishlistBloc>().add(
                                        WishlistToggleItem(product));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.error,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrescriptionsSheet(BuildContext context, UserEntity? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('My Prescriptions', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: user == null
                  ? _buildEmptyPrescriptions()
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('prescriptions')
                          .where('userId', isEqualTo: user.uid)
                          .orderBy('uploadedAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return _buildEmptyPrescriptions();
                        }
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, i) {
                            final doc = docs[i].data() as Map<String, dynamic>;
                            final medicines = doc['matchedMedicines'] as List<dynamic>? ?? [];
                            final dateTimestamp = doc['uploadedAt'] as Timestamp?;
                            final date = dateTimestamp != null ? dateTimestamp.toDate() : DateTime.now();
                            final status = doc['status'] as String? ?? 'pending_verification';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Uploaded ${DateFormat('dd MMM, hh:mm a').format(date)}',
                                        style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: status == 'pending_verification'
                                              ? Colors.amber.withOpacity(0.1)
                                              : AppColors.success.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          status == 'pending_verification' ? 'Reviewing' : 'Approved',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: status == 'pending_verification' ? Colors.amber[800] : AppColors.success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Meds Extracted: ${medicines.map((m) => m['name']).join(', ')}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPrescriptions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.description_outlined, size: 48, color: AppColors.textHint),
        const SizedBox(height: 12),
        Text('No Uploaded Prescriptions', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('Upload a doctor prescription slip on the home page to quick order!', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }

  void _showHelpSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Help & Support', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
              title: const Text('Live Chat Support'),
              subtitle: const Text('Chat with our registered pharmacist'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting chat support...')),
                );
              },
            ),
            const AppDivider(),
            ListTile(
              leading: const Icon(Icons.phone_in_talk_outlined, color: AppColors.success),
              title: const Text('Call Helpline (Toll-Free)'),
              subtitle: const Text('1800-300-4560 (24/7 Care)'),
              onTap: () {},
            ),
            const AppDivider(),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: Colors.purple),
              title: const Text('Email Support'),
              subtitle: const Text('support@klinixy.com'),
              onTap: () {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text('Payment Methods', style: AppTextStyles.headlineSmall)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Klinixy Express Card', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 10),
                  const Text('•••• •••• •••• 4256', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('VALUED MEMBER', style: TextStyle(color: Colors.white70, fontSize: 9)),
                      Text('EXP: 12/29', style: TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
              title: const Text('Add Credit or Debit Card'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.wallet_giftcard_rounded, color: AppColors.secondary),
              title: const Text('Klinixy Wallet Balance (₹0.00)'),
              onTap: () {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Notifications', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
              ),
              title: const Text('Express Delivery Dispatched'),
              subtitle: const Text('Your order has been matched with a rider near Indiranagar'),
            ),
            const AppDivider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              ),
              title: const Text('Prescription Approved'),
              subtitle: const Text('Pharmacist verified Dolo 650 dosage match successfully'),
            ),
            const AppDivider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFEF3C7),
                child: Icon(Icons.discount_rounded, color: AppColors.secondary, size: 20),
              ),
              title: const Text('Welcome Coupon Added!'),
              subtitle: const Text('Get extra 20% discount on prescription uploads'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(title, style: AppTextStyles.headlineSmall),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static const String _privacyPolicyContent =
      "Your privacy is important to us. Klinixy is committed to protecting the confidentiality and security of your personal health data in compliance with HIPAA guidelines. We secure your uploaded prescriptions, payment cards, and search histories. No data is shared with third parties without your explicit consent.";

  static const String _termsOfServiceContent =
      "By using Klinixy, you agree to our Terms of Service. Prescriptions uploaded must be valid, current, and issued by registered medical practitioners. Delivery speeds of 30 minutes are target averages and may fluctuate depending on weather conditions or rider availability. We offer a full refund if delivery exceeds target times.";

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SettingsSheet(),
    );
  }

  void _showEditProfileSheet(BuildContext context, UserEntity? user) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to edit your profile')),
      );
      return;
    }

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone ?? '');
    // Capture the bloc before opening the sheet so we don't lose context
    final authBloc = context.read<AuthBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            bool isSaving = false;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Edit Profile', style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 24),

                    // Avatar
                    Center(
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: AppTextStyles.displayLarge.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 36,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Name field
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone field
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+91 98765 43210',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () {
                                final name = nameController.text.trim();
                                final phone = phoneController.text.trim();
                                if (name.isEmpty) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(content: Text('Name cannot be empty')),
                                  );
                                  return;
                                }
                                authBloc.add(AuthUpdateProfileRequested(
                                  name: name,
                                  phone: phone.isNotEmpty ? phone : null,
                                ));
                                Navigator.of(sheetContext).pop();
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile updated successfully! ✓'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


class _ProfileCard extends StatelessWidget {
  final UserEntity? user;
  const _ProfileCard({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.20),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Klinixy logo watermark
          Positioned(
            right: -8,
            bottom: -8,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/klinixy_app_logo.png',
                width: 90,
                height: 90,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
          // Main row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.30),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Klinixy User',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user?.email ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        '🥇 Gold Member',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TapScale(
                onTap: () => (context.findAncestorWidgetOfExactType<ProfileScreen>() ?? const ProfileScreen())._showEditProfileSheet(context, user),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TapScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSheet extends StatefulWidget {
  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  bool _pushNotifications = true;
  bool _orderUpdates = true;
  bool _promotionalEmails = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Settings', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 20),
          _buildToggle('Push Notifications', Icons.notifications_active_rounded,
              _pushNotifications, (v) => setState(() => _pushNotifications = v)),
          const AppDivider(),
          _buildToggle('Order Updates (SMS)', Icons.sms_rounded,
              _orderUpdates, (v) => setState(() => _orderUpdates = v)),
          const AppDivider(),
          _buildToggle('Promotional Emails', Icons.email_rounded,
              _promotionalEmails, (v) => setState(() => _promotionalEmails = v)),
          const AppDivider(),
          ListTile(
            leading: const Icon(Icons.language_rounded, color: AppColors.primary),
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: ['English', 'Hindi', 'Kannada', 'Tamil']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l, style: AppTextStyles.bodySmall)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLanguage = v!),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'App Version 1.0.0',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const AppDivider(indent: 56),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              )),
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
