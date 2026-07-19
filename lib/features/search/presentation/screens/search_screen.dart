import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/product/domain/entities/product_entity.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  String _selectedFilter = 'All';

  static const List<String> _filters = [
    'All', 'Medicines', 'Vitamins', 'Diabetes', 'Skin Care', 'Baby Care'
  ];

  static const List<String> _recentSearches = [
    'Dolo 650', 'Vitamin D', 'Pan D', 'Crocin', 'Allegra',
  ];

  List<ProductEntity> get _results {
    if (_query.isEmpty) return [];
    return MockProducts.all
        .where((p) =>
            p.name.toLowerCase().contains(_query.toLowerCase()) ||
            p.brand.toLowerCase().contains(_query.toLowerCase()) ||
            p.tags.any((t) => t.toLowerCase().contains(_query.toLowerCase())))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _query = widget.initialQuery!;
      _controller.text = widget.initialQuery!;
    }
    Future.delayed(Duration.zero, () {
      if (widget.initialQuery == null && mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: _query.isNotEmpty
                              ? AppColors.primary
                              : AppColors.divider,
                          width: _query.isNotEmpty ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search_rounded,
                              color: AppColors.textHint, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: (v) => setState(() => _query = v),
                              decoration: const InputDecoration(
                                hintText: 'Search medicines...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.close_rounded,
                                    size: 18, color: AppColors.textHint),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips
            if (_query.isNotEmpty)
              Container(
                color: AppColors.surface,
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 6),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppColors.primaryGradient
                              : null,
                          color: isSelected ? null : AppColors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          filter,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Content
            Expanded(
              child: _query.isEmpty
                  ? _RecentSearches(
                      searches: _recentSearches,
                      onTap: (s) {
                        _controller.text = s;
                        setState(() => _query = s);
                      },
                    )
                  : _results.isEmpty
                      ? _NoResults(query: _query)
                      : _SearchResults(results: _results),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final Function(String) onTap;

  const _RecentSearches({required this.searches, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Recent Searches', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        ...searches.map((s) => TapScale(
              onTap: () => onTap(s),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded,
                        color: AppColors.textHint, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s, style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      )),
                    ),
                    const Icon(Icons.north_west_rounded,
                        color: AppColors.textHint, size: 16),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 20),
        Text('Popular Categories', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            'Fever', 'Cold & Cough', 'Diabetes', 'Heart Care',
            'Vitamins', 'Skin Care', 'Baby Care', 'Pain Relief'
          ].map((cat) => TapScale(
                onTap: () => onTap(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    cat,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              )).toList(),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<ProductEntity> results;
  const _SearchResults({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _SearchResultCard(product: results[index]);
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final ProductEntity product;
  const _SearchResultCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: product.imageUrls.isEmpty ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                ) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.imageUrls.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.medication_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                    )
                  : const Icon(Icons.medication_rounded,
                      color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(product.brand, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '₹${product.mrp.toStringAsFixed(0)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (product.discount > 0)
                        Text(
                          '${product.discount}% off',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Add button
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                final qty = state.quantityOf(product.id);
                if (qty == 0) {
                  return TapScale(
                    onTap: () => context
                        .read<CartBloc>()
                        .add(CartAddItem(product)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Add',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => context.read<CartBloc>().add(
                              CartUpdateQuantity(product.id, qty - 1),
                            ),
                        child: Container(
                          width: 32,
                          height: 36,
                          alignment: Alignment.center,
                          child: const Icon(Icons.remove_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      Text(
                        '$qty',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => context.read<CartBloc>().add(
                              CartAddItem(product),
                            ),
                        child: Container(
                          width: 32,
                          height: 36,
                          alignment: Alignment.center,
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('No results for "$query"',
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or browse categories',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
