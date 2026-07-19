import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/product/presentation/bloc/wishlist_bloc.dart';
import 'package:klinixy/features/product/domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final dynamic product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Support both ProductEntity and legacy mock
    final String name;
    final String brand;
    final double price;
    final double mrp;
    final int discount;
    final String? productId;
    final List<String> imageUrls;

    if (product is ProductEntity) {
      final p = product as ProductEntity;
      name = p.name;
      brand = p.brand;
      price = p.price;
      mrp = p.mrp;
      discount = p.discount;
      productId = p.id;
      imageUrls = p.imageUrls;
    } else {
      name = product.name as String;
      brand = product.brand as String;
      price = product.price as double;
      mrp = product.mrp as double;
      discount = product.discount as int;
      productId = null;
      imageUrls = [];
    }

    return TapScale(
      onTap: productId != null ? () => context.push('/product/$productId') : null,
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: imageUrls.isEmpty ? LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.secondary.withValues(alpha: 0.1),
                          ],
                        ) : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrls.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.medication_rounded,
                                  color: AppColors.primary,
                                  size: 36,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.medication_rounded,
                              color: AppColors.primary,
                              size: 36,
                            ),
                    ),
                  ),
                  if (discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: DiscountBadge(discount: discount),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<WishlistBloc, WishlistState>(
                      builder: (context, wishlistState) {
                        final isWish = productId != null && wishlistState.isWishlisted(productId);
                        return TapScale(
                          onTap: () {
                            if (product is ProductEntity) {
                              context.read<WishlistBloc>().add(WishlistToggleItem(product as ProductEntity));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isWish
                                      ? 'Removed from Wishlist'
                                      : 'Added to Wishlist! ❤️'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.card,
                            ),
                            child: Icon(
                              isWish ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 15,
                              color: isWish ? AppColors.error : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(brand, style: AppTextStyles.bodySmall, maxLines: 1),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹${mrp.toStringAsFixed(0)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Add to cart
                  product is ProductEntity
                      ? _CartButton(product: product as ProductEntity)
                      : _SimpleAddButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  final ProductEntity product;
  const _CartButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final qty = state.quantityOf(product.id);

        if (qty == 0) {
          return TapScale(
            onTap: () =>
                context.read<CartBloc>().add(CartAddItem(product)),
            child: Container(
              width: double.infinity,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Add',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          height: 32,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<CartBloc>().add(
                        CartUpdateQuantity(product.id, qty - 1),
                      ),
                  child: const Icon(Icons.remove_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              Text(
                '$qty',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.read<CartBloc>().add(CartAddItem(product)),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SimpleAddButton extends StatefulWidget {
  @override
  State<_SimpleAddButton> createState() => _SimpleAddButtonState();
}

class _SimpleAddButtonState extends State<_SimpleAddButton> {
  int _qty = 0;

  @override
  Widget build(BuildContext context) {
    if (_qty == 0) {
      return TapScale(
        onTap: () => setState(() => _qty = 1),
        child: Container(
          width: double.infinity,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Add',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                if (_qty > 0) _qty--;
              }),
              child: const Icon(Icons.remove_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          Text(
            '$_qty',
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _qty++),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
