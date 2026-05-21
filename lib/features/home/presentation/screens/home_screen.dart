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
        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Express delivery info
        SliverToBoxAdapter(child: _DeliveryBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Banner Carousel
        const SliverToBoxAdapter(child: BannerCarousel()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Categories
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Shop by Category',
            onSeeAll: () {},
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
            onSeeAll: () {},
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverToBoxAdapter(child: _PopularProductsRow()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Health Essentials
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Health Essentials',
            onSeeAll: () {},
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
    final user = (context.read<AuthBloc>().state is AuthAuthenticated)
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: 12,
      ),
      child: Row(
        children: [
          // Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Deliver to',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 16, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Select your location',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.shopping_bag_outlined,
                              color: AppColors.textPrimary, size: 22),
                        ),
                        if (cartState.itemCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
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
              // Avatar
              CircleAvatar(
                radius: 20,
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

class _DeliveryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color:
                    isSelected ? AppColors.primary : AppColors.textHint,
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

