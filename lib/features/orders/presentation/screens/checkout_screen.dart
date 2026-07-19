import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/orders/domain/entities/address_entity.dart';
import 'package:klinixy/features/orders/presentation/bloc/checkout_bloc.dart';
import 'package:klinixy/core/di/injection.dart';
import 'package:klinixy/features/auth/domain/repositories/auth_repository.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutBloc(),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state.placedOrderId != null) {
          // Clear cart
          context.read<CartBloc>().add(const CartClear());
          // Navigate to success
          context.go('/order/${state.placedOrderId}/success');
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          title: Text('Checkout', style: AppTextStyles.headlineMedium),
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      // Delivery address section
                      _SectionTitle(title: 'Delivery Address'),
                      const SizedBox(height: 10),
                      _AddressSection(),
                      const SizedBox(height: 20),

                      // Order summary
                      _SectionTitle(title: 'Order Summary'),
                      const SizedBox(height: 10),
                      _OrderSummaryCard(cartState: cartState),
                      const SizedBox(height: 20),

                      // Payment method
                      _SectionTitle(title: 'Payment Method'),
                      const SizedBox(height: 10),
                      _PaymentMethodSection(),
                      const SizedBox(height: 20),

                      // Delivery info
                      _DeliveryInfoCard(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // Place order bar
                _PlaceOrderBar(cartState: cartState),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.headlineSmall);
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection();

  @override
  Widget build(BuildContext context) {
    final repo = sl<AuthRepository>();

    return StreamBuilder<List<AddressEntity>>(
      stream: repo.getSavedAddresses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final addresses = snapshot.data ?? [];

        return BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            // Auto-select default address if none is selected yet
            if (state.selectedAddress == null && addresses.isNotEmpty) {
              final defaultAddr = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<CheckoutBloc>().add(CheckoutSelectAddress(defaultAddr));
                }
              });
            }

            return Column(
              children: [
                if (addresses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        'No saved addresses. Please add a new address.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...addresses.map((addr) => _AddressCard(
                        address: addr,
                        isSelected: state.selectedAddress?.id == addr.id,
                        onSelect: () => context
                            .read<CheckoutBloc>()
                            .add(CheckoutSelectAddress(addr)),
                      )),
                const SizedBox(height: 10),
                TapScale(
                  onTap: () => _showAddAddressSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.primary,
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_location_alt_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Add New Address',
                          style: AppTextStyles.titleMedium.copyWith(
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
        );
      },
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddAddressSheet(),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressEntity address;
  final bool isSelected;
  final VoidCallback onSelect;

  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.elevated : AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 12),

            // Address info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _labelColor(address.label)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_labelIcon(address.label),
                                size: 12,
                                color: _labelColor(address.label)),
                            const SizedBox(width: 4),
                            Text(
                              address.label,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _labelColor(address.label),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Default',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(address.fullName,
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    address.displayAddress,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📱 ${address.phone}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _labelColor(String label) {
    switch (label) {
      case 'Home':
        return AppColors.primary;
      case 'Work':
        return AppColors.accent;
      default:
        return AppColors.secondary;
    }
  }

  IconData _labelIcon(String label) {
    switch (label) {
      case 'Home':
        return Icons.home_rounded;
      case 'Work':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final CartState cartState;
  const _OrderSummaryCard({required this.cartState});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // Items
          ...cartState.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.product.imageUrls.isEmpty ? AppColors.primaryLight : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: item.product.imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrls.first,
                                fit: BoxFit.cover,
                                width: 36,
                                height: 36,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.medication_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                            )
                          : const Icon(Icons.medication_rounded,
                              color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              style: AppTextStyles.titleMedium
                                  .copyWith(fontSize: 13)),
                          Text(item.product.brand,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Text('x${item.quantity}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(width: 8),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
              )),

          const AppDivider(),

          // Price breakdown
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _Row('Subtotal', '₹${cartState.subtotal.toStringAsFixed(0)}'),
                const SizedBox(height: 6),
                _Row(
                  'Delivery',
                  cartState.deliveryCharge == 0
                      ? 'FREE'
                      : '₹${cartState.deliveryCharge.toStringAsFixed(0)}',
                  valueColor: cartState.deliveryCharge == 0
                      ? AppColors.success
                      : null,
                ),
                const SizedBox(height: 8),
                const AppDivider(),
                const SizedBox(height: 8),
                _Row(
                  'Total',
                  '₹${cartState.total.toStringAsFixed(0)}',
                  isBold: true,
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _Row(this.label, this.value, {this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isBold
                ? AppTextStyles.titleLarge
                : AppTextStyles.bodyMedium),
        Text(
          value,
          style: (isBold
                  ? AppTextStyles.headlineMedium
                  : AppTextStyles.bodyMedium)
              .copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return Column(
          children: [
            _PaymentOption(
              icon: Icons.delivery_dining_rounded,
              label: 'Cash on Delivery',
              subtitle: 'Pay when your order arrives',
              value: 'cod',
              selected: state.paymentMethod == 'cod',
              onTap: () => context
                  .read<CheckoutBloc>()
                  .add(const CheckoutSelectPayment('cod')),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Online Payment',
              subtitle: 'UPI, Cards, Net Banking',
              value: 'online',
              selected: state.paymentMethod == 'online',
              onTap: () => context
                  .read<CheckoutBloc>()
                  .add(const CheckoutSelectPayment('online')),
              badge: '5% OFF',
            ),
          ],
        );
      },
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? AppShadows.elevated : AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryLight
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: AppTextStyles.titleMedium),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryInfoCard extends StatelessWidget {
  const _DeliveryInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
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
                Text('Express Delivery', style: AppTextStyles.titleMedium),
                Text(
                  'Estimated delivery within 30 minutes',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceOrderBar extends StatelessWidget {
  final CartState cartState;
  const _PlaceOrderBar({required this.cartState});

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
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${cartState.total.toStringAsFixed(0)}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    state.paymentMethod == 'cod' ? 'Cash on Delivery' : 'Online',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KlinButton(
                  label: state.isLoading
                      ? 'Placing Order...'
                      : state.selectedAddress == null
                          ? 'Select Address First'
                          : 'Place Order →',
                  height: 52,
                  backgroundColor: state.canPlaceOrder ? null : AppColors.textHint,
                  onTap: state.canPlaceOrder
                      ? () => context
                          .read<CheckoutBloc>()
                          .add(CheckoutPlaceOrder(cartState))
                      : null,
                  leading: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Add Address Bottom Sheet ────────────────────────────────────────
class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet();

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  String _label = 'Home';
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addr1Ctrl = TextEditingController();
  final _addr2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addr1Ctrl.dispose();
    _addr2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Add Delivery Address',
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: 16),

              // Label selector
              Row(
                children: ['Home', 'Work', 'Other'].map((lbl) {
                  final selected = _label == lbl;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(lbl),
                      selected: selected,
                      onSelected: (_) => setState(() => _label = lbl),
                      selectedColor: AppColors.primary,
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              _Input(controller: _nameCtrl, hint: 'Full Name', icon: Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _Input(controller: _phoneCtrl, hint: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _Input(controller: _addr1Ctrl, hint: 'House/Flat, Street Address', icon: Icons.home_outlined),
              const SizedBox(height: 12),
              _Input(controller: _addr2Ctrl, hint: 'Landmark (optional)', icon: Icons.flag_outlined, required: false),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _Input(controller: _cityCtrl, hint: 'City', icon: Icons.location_city_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _Input(controller: _pincodeCtrl, hint: 'Pincode', icon: Icons.pin_outlined, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              _Input(controller: _stateCtrl, hint: 'State', icon: Icons.map_outlined),
              const SizedBox(height: 20),

              KlinButton(
                label: 'Save Address',
                onTap: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final newAddress = AddressEntity(
                      id: '',
                      label: _label,
                      fullName: _nameCtrl.text.trim(),
                      phone: _phoneCtrl.text.trim(),
                      addressLine1: _addr1Ctrl.text.trim(),
                      addressLine2: _addr2Ctrl.text.trim(),
                      city: _cityCtrl.text.trim(),
                      state: _stateCtrl.text.trim(),
                      pincode: _pincodeCtrl.text.trim(),
                      latitude: 28.6139,  // Default Delhi coordinates as fallback for manual address addition
                      longitude: 77.2090,
                    );
                    
                    try {
                      await sl<AuthRepository>().addAddress(newAddress);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to save address: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool required;

  const _Input({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: required
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
