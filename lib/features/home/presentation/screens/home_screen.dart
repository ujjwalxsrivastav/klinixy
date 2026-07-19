import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/home/presentation/widgets/banner_carousel.dart';
import 'package:klinixy/features/home/presentation/widgets/category_grid.dart';
import 'package:klinixy/features/home/presentation/widgets/product_card.dart';
import 'package:klinixy/features/home/presentation/widgets/offer_section.dart';
import 'package:klinixy/features/orders/presentation/screens/order_history_screen.dart';
import 'package:klinixy/features/product/domain/entities/product_entity.dart';
import 'package:klinixy/features/profile/presentation/screens/profile_screen.dart';
import 'package:klinixy/features/search/presentation/screens/search_screen.dart';
import 'package:klinixy/features/home/presentation/widgets/location_picker_sheet.dart';
import 'package:klinixy/core/utils/location_service.dart';
import 'package:klinixy/features/home/presentation/widgets/prescription_upload_sheet.dart';
import 'package:klinixy/features/home/presentation/widgets/routine_quiz_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showElevation = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showElevation = _scrollController.offset > 20;
      });
    });
    // Auto location detection on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoDetectLocation();
    });
  }

  Future<void> _autoDetectLocation() async {
    final authBloc = context.read<AuthBloc>();
    final state = authBloc.state;
    if (state is AuthAuthenticated) {
      final user = state.user;
      if (user.activeAddress == null ||
          user.activeAddress!.isEmpty ||
          user.activeAddress == 'Unknown Location' ||
          user.activeAddress!.startsWith('Lat:')) {
        try {
          final pos = await LocationService.getCurrentLocation();
          final fullAddr = await LocationService.getAddressFromCoordinates(pos.latitude, pos.longitude);
          if (mounted) {
            authBloc.add(
              AuthUpdateLocationRequested(
                address: fullAddr,
                latitude: pos.latitude,
                longitude: pos.longitude,
              ),
            );
          }
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _HomeTab(scrollController: _scrollController);
      case 1:
        return const SearchScreen();
      case 2:
        return const OrderHistoryScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _HomeTab(scrollController: _scrollController);
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.bottomBar,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: _currentNavIndex == 0,
                onTap: () => setState(() => _currentNavIndex = 0),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Search',
                isSelected: _currentNavIndex == 1,
                onTap: () => setState(() => _currentNavIndex = 1),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'Orders',
                isSelected: _currentNavIndex == 2,
                onTap: () => setState(() => _currentNavIndex = 2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: _currentNavIndex == 3,
                onTap: () => setState(() => _currentNavIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final ScrollController scrollController;
  const _HomeTab({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // AppBar
        SliverToBoxAdapter(child: _HomeAppBar()),

        // Search bar
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(child: _SearchBar()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Prescription Quick upload card
        SliverToBoxAdapter(child: _PrescriptionQuickCard()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Personalized Quiz Finder Card
        SliverToBoxAdapter(child: const _CareQuizCard()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Express delivery info with live ticker
        SliverToBoxAdapter(child: _DeliveryBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Banner Carousel
        const SliverToBoxAdapter(child: BannerCarousel()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Trust Badges Grid
        SliverToBoxAdapter(child: _TrustFactorsGrid()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Categories
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Shop by Category',
            onSeeAll: () => context.push('/search'),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        const SliverToBoxAdapter(child: CategoryGrid()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Offer section
        const SliverToBoxAdapter(child: OfferSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Featured Products
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Popular Medicines',
            subtitle: 'Best selling in your area',
            onSeeAll: () => context.push('/search', extra: 'Medicines'),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverToBoxAdapter(child: _PopularProductsRow()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Health Essentials
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Health Essentials',
            onSeeAll: () => context.push('/search', extra: 'Vitamins'),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverToBoxAdapter(child: _PopularProductsRow()),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = (authState is AuthAuthenticated) ? authState.user : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: 12,
      ),
      child: Row(
        children: [
          // Klinixy Logo + Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand logo
                SizedBox(
                  height: 34,
                  child: Image.asset(
                    'assets/images/klinixy_logo_transparent.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    color: AppColors.primary,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 4),
                // Location row
                TapScale(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const LocationPickerSheet(),
                    );
                  },
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                        child: const Icon(Icons.location_on_rounded,
                            color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          user?.activeAddress ?? 'Select your location',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 14, color: AppColors.textHint),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Cart + Avatar
          Row(
            children: [
              // Cart button
              BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) => TapScale(
                  onTap: () => context.push('/cart'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.divider, width: 1),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.shopping_bag_outlined,
                              color: AppColors.textSecondary, size: 22),
                        ),
                        if (cartState.itemCount > 0)
                          Positioned(
                            right: 7,
                            top: 7,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${cartState.itemCount}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Avatar with brand ring
              GestureDetector(
                onTap: () {
                  final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                  homeState?.setState(() => homeState._currentNavIndex = 3);
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TapScale(
        onTap: () => context.push('/search'),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider, width: 1),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search_rounded,
                  color: AppColors.textHint, size: 22),
              const SizedBox(width: 12),
              Text(
                'Search medicines, health products...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryBanner extends StatefulWidget {
  const _DeliveryBanner();

  @override
  State<_DeliveryBanner> createState() => _DeliveryBannerState();
}

class _DeliveryBannerState extends State<_DeliveryBanner> {
  int _index = 0;
  Timer? _timer;
  final List<String> _updates = [
    "🟢 Rider matching in Indiranagar: average 44 seconds",
    "🟢 Delivered to Koramangala block 4 in 14 mins!",
    "🟢 Prescription approved by RPh panel in 2 mins!",
    "🟢 Delivered to HSR Layout Sector 3 in 18 mins!",
    "🟢 Average dispatch time in your area: 2.8 mins",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _updates.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withOpacity(0.12),
              AppColors.primary.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Express Delivery Active 🎉',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Medicines delivered in 30 minutes',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const ExpressBadge(),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surfaceVariant.withOpacity(0.5),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked, size: 12, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _updates[_index],
                        key: ValueKey<int>(_index),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
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
}

class _PopularProductsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md - 4),
        itemCount: MockProducts.all.length,
        itemBuilder: (context, index) {
          return ProductCard(product: MockProducts.all[index]);
        },
      ),
    );
  }
}


class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TapScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isSelected ? 44 : 36,
                height: isSelected ? 32 : 32,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : AppColors.textHint,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textHint,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrescriptionQuickCard extends StatelessWidget {
  const _PrescriptionQuickCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TapScale(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const PrescriptionUploadSheet(),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Quick Order with Prescription',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEW',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scan doc & get meds matched in 3 mins',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustFactorsGrid extends StatelessWidget {
  const _TrustFactorsGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Choose Klinixy?',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: [
              _buildTrustCard(
                icon: Icons.flash_on_rounded,
                color: AppColors.secondary,
                title: '30-Min Delivery',
                subtitle: 'Superfast and free above ₹499',
              ),
              _buildTrustCard(
                icon: Icons.verified_user_rounded,
                color: AppColors.success,
                title: '100% Genuine',
                subtitle: 'Directly from licensed stores',
              ),
              _buildTrustCard(
                icon: Icons.health_and_safety_rounded,
                color: AppColors.primary,
                title: 'RPh Verified',
                subtitle: 'Pharmacist-approved doses',
              ),
              _buildTrustCard(
                icon: Icons.support_agent_rounded,
                color: const Color(0xFF7C3AED),
                title: '24/7 Support',
                subtitle: 'Registered medical help',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                    fontSize: 8.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CareQuizCard extends StatelessWidget {
  const _CareQuizCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TapScale(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const RoutineQuizSheet(),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFC084FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Care Routine Finder',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'QUIZ',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Match custom skincare, haircare & bodycare routines',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

