import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/di/injection.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/auth/domain/repositories/auth_repository.dart';
import 'package:klinixy/features/home/presentation/screens/map_address_picker_screen.dart';
import 'package:klinixy/features/orders/domain/entities/address_entity.dart';

class AddressManagementScreen extends StatelessWidget {
  const AddressManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<AuthRepository>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
        ),
        title: Text('Saved Addresses', style: AppTextStyles.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: StreamBuilder<List<AddressEntity>>(
        stream: repo.getSavedAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return _AddressItemCard(
                  address: addr,
                  onEdit: () => _showAddressFormSheet(context, addr),
                  onDelete: () => _showDeleteDialog(context, addr.id));
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: KlinButton(
            label: 'Add New Address',
            onTap: () => _showAddressFormSheet(context),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'No Saved Addresses',
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Please add an address to easily order medicines.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String addressId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text('Delete Address', style: AppTextStyles.headlineMedium),
        content: Text('Are you sure you want to delete this address?',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              sl<AuthRepository>().deleteAddress(addressId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: const Size(0, 40)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddressFormSheet(BuildContext context, [AddressEntity? address]) {
    final isEdit = address != null;
    final labelController =
        TextEditingController(text: address?.label ?? 'Home');
    final nameController =
        TextEditingController(text: address?.fullName ?? '');
    final phoneController =
        TextEditingController(text: address?.phone ?? '');
    final line1Controller =
        TextEditingController(text: address?.addressLine1 ?? '');
    final line2Controller =
        TextEditingController(text: address?.addressLine2 ?? '');
    final cityController =
        TextEditingController(text: address?.city ?? '');
    final stateController =
        TextEditingController(text: address?.state ?? '');
    final pinController =
        TextEditingController(text: address?.pincode ?? '');
    double? lat = address?.latitude;
    double? lng = address?.longitude;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isPickingMap = false;

            /// Opens the full-screen map and auto-fills fields from result.
            Future<void> openMapPicker() async {
              setState(() => isPickingMap = true);
              try {
                final result = await Navigator.of(context).push<MapPickerResult>(
                  MaterialPageRoute(
                    builder: (_) => MapAddressPickerScreen(
                      initialLat: lat,
                      initialLng: lng,
                    ),
                  ),
                );
                if (result != null) {
                  lat = result.latitude;
                  lng = result.longitude;
                  // Auto-fill address fields from geocode result
                  line1Controller.text = result.address.addressLine1;
                  line2Controller.text = result.address.subLocality;
                  cityController.text = result.address.city;
                  stateController.text = result.address.state;
                  pinController.text = result.address.pincode;
                }
              } finally {
                setState(() => isPickingMap = false);
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: ListView(
                shrinkWrap: true,
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
                  Text(
                    isEdit ? 'Edit Address' : 'Add New Address',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Move the pin on the map to set your exact location.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // ── Pick on Map button (Zomato-style) ─────────────────
                  ElevatedButton.icon(
                    onPressed: isPickingMap ? null : openMapPicker,
                    icon: isPickingMap
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.map_rounded, size: 20),
                    label: Text(
                      isPickingMap
                          ? 'Opening Map...'
                          : (lat != null
                              ? 'Change Location on Map'
                              : 'Pick Location on Map'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  ),

                  // Show current resolved address chip
                  if (lat != null && lng != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${cityController.text} ${pinController.text}',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Address label ──────────────────────────────────────
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'Address Label (Home / Work / Other)',
                      prefixIcon: Icon(Icons.bookmark_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Receiver Full Name *',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Receiver Phone *',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: line1Controller,
                    decoration: const InputDecoration(
                      labelText: 'House No. / Flat / Building *',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: line2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Street / Locality / Landmark',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          decoration: const InputDecoration(labelText: 'City *'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: stateController,
                          decoration:
                              const InputDecoration(labelText: 'State'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pincode *',
                      prefixIcon: Icon(Icons.pin_drop_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  KlinButton(
                    label: isEdit ? 'Save Changes' : 'Add Address',
                    onTap: () {
                      if (nameController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty ||
                          line1Controller.text.trim().isEmpty ||
                          cityController.text.trim().isEmpty ||
                          pinController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all required fields (*)'),
                              backgroundColor: AppColors.error),
                        );
                        return;
                      }

                      final newAddress = AddressEntity(
                        id: address?.id ?? '',
                        label: labelController.text.trim(),
                        fullName: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        addressLine1: line1Controller.text.trim(),
                        addressLine2: line2Controller.text.trim(),
                        city: cityController.text.trim(),
                        state: stateController.text.trim(),
                        pincode: pinController.text.trim(),
                        latitude: lat,
                        longitude: lng,
                        isDefault: address?.isDefault ?? false,
                      );

                      if (isEdit) {
                        sl<AuthRepository>().updateAddress(newAddress);
                      } else {
                        sl<AuthRepository>().addAddress(newAddress);
                      }

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AddressItemCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressItemCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      address.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 14),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address.fullName,
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            '+91 ${address.phone}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(
            address.displayAddress,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
