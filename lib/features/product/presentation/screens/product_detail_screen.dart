import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/product/domain/entities/product_entity.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  // Fetch product (mock for now)
  ProductEntity get _product =>
      MockProducts.all.firstWhere((p) => p.id == widget.productId,
          orElse: () => MockProducts.all.first);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(() {
      setState(() {
        _showTitle = _scrollController.offset > 200;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero image area
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: TapScale(
                  onTap: () => context.pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.card,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppColors.textPrimary),
                  ),
                ),
                actions: [
                  TapScale(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.card,
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                          size: 20, color: AppColors.error),
                    ),
                  ),
                  TapScale(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.card,
                      ),
                      child: const Icon(Icons.share_outlined,
                          size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                ],
                title: AnimatedOpacity(
                  opacity: _showTitle ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(product.name, style: AppTextStyles.headlineSmall),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.surface,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.08),
                                AppColors.secondary.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.medication_rounded,
                                  size: 80, color: AppColors.primary),
                              if (product.requiresPrescription)
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Rx Required',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Discount badge
                        if (product.discount > 0)
                          DiscountBadge(discount: product.discount),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + brand
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTextStyles.displayMedium
                                            .copyWith(fontSize: 22),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'by ${product.brand}',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!product.inStock)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Out of Stock',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Rating
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: product.rating,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFACC15),
                                  ),
                                  itemCount: 5,
                                  itemSize: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${product.rating}',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${product.reviewCount} reviews)',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Price
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                boxShadow: AppShadows.card,
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₹${product.price.toStringAsFixed(0)}',
                                        style: AppTextStyles.displayMedium
                                            .copyWith(
                                          color: AppColors.primary,
                                          fontSize: 28,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'MRP ₹${product.mrp.toStringAsFixed(0)}',
                                            style:
                                                AppTextStyles.bodySmall.copyWith(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: AppColors.textHint,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${product.discount}% OFF',
                                            style:
                                                AppTextStyles.labelSmall.copyWith(
                                              color: AppColors.success,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const ExpressBadge(),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Uses chips
                            Text('Used for', style: AppTextStyles.titleLarge),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: product.uses
                                  .map((use) => Chip(
                                        label: Text(use),
                                        backgroundColor: AppColors.primaryLight,
                                        labelStyle:
                                            AppTextStyles.labelMedium.copyWith(
                                          color: AppColors.primary,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        side: BorderSide.none,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),

                      // Tabs
                      Container(
                        color: AppColors.surface,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 2,
                          labelStyle: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          tabs: const [
                            Tab(text: 'Description'),
                            Tab(text: 'Composition'),
                            Tab(text: 'Side Effects'),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 200,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _TabContent(content: product.description),
                            _TabContent(content: product.composition),
                            _SideEffectsTab(
                                sideEffects: product.sideEffects),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom add-to-cart bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _AddToCartBar(product: product),
          ),
        ],
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final String content;
  const _TabContent({required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(content, style: AppTextStyles.bodyLarge),
    );
  }
}

class _SideEffectsTab extends StatelessWidget {
  final List<String> sideEffects;
  const _SideEffectsTab({required this.sideEffects});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: sideEffects
          .map((effect) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(effect, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  final ProductEntity product;
  const _AddToCartBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.bottomBar,
      ),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          final qty = cartState.quantityOf(product.id);

          if (qty == 0) {
            return KlinButton(
              label: product.inStock ? 'Add to Cart' : 'Out of Stock',
              backgroundColor: product.inStock ? null : AppColors.textHint,
              onTap: product.inStock
                  ? () => context.read<CartBloc>().add(CartAddItem(product))
                  : null,
              leading: product.inStock
                  ? const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white, size: 20)
                  : null,
            );
          }

          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.read<CartBloc>().add(
                                CartUpdateQuantity(product.id, qty - 1),
                              ),
                          child: const Icon(Icons.remove_rounded,
                              color: Colors.white, size: 24),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$qty',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'in cart',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.read<CartBloc>().add(
                                CartUpdateQuantity(product.id, qty + 1),
                              ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TapScale(
                onTap: () => context.push('/cart'),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Go to Cart',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
