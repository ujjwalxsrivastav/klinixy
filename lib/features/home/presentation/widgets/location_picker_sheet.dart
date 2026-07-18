import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/di/injection.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/core/utils/location_service.dart';
import 'package:klinixy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:klinixy/features/auth/domain/repositories/auth_repository.dart';
import 'package:klinixy/features/orders/domain/entities/address_entity.dart';

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  bool _isFetchingGPS = false;

  Future<void> _fetchGPSLocation(BuildContext context) async {
    setState(() => _isFetchingGPS = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      final fullAddr = await LocationService.getAddressFromCoordinates(pos.latitude, pos.longitude);

      if (context.mounted) {
        context.read<AuthBloc>().add(
              AuthUpdateLocationRequested(
                address: fullAddr,
                latitude: pos.latitude,
                longitude: pos.longitude,
              ),
            );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery location updated to current GPS!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingGPS = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = sl<AuthRepository>();

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
          Text(
            'Select Delivery Location',
            style: AppTextStyles.headlineLarge,
          ),
          const SizedBox(height: 20),

          // Use Current Location Option (Zomato-style GPS auto locator)
          TapScale(
            onTap: _isFetchingGPS ? null : () => _fetchGPSLocation(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _isFetchingGPS
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use Current Location',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isFetchingGPS ? 'Fetching details...' : 'Automatically locate me using GPS',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Saved Addresses Section
          Text(
            'Saved Addresses',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 12),

          Flexible(
            child: StreamBuilder<List<AddressEntity>>(
              stream: repo.getSavedAddresses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final addresses = snapshot.data ?? [];

                if (addresses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No saved addresses yet.\nAdd one in address manager below.',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return _SavedAddressPickerItem(
                      address: addr,
                      onTap: () {
                        context.read<AuthBloc>().add(
                              AuthUpdateLocationRequested(
                                address: addr.displayAddress,
                                latitude: addr.latitude ?? 0.0,
                                longitude: addr.longitude ?? 0.0,
                              ),
                            );
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Manage Addresses Button
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/profile/addresses');
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              side: const BorderSide(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings_suggest_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Manage Saved Addresses', style: AppTextStyles.labelMedium),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SavedAddressPickerItem extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback onTap;

  const _SavedAddressPickerItem({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.home_outlined;
    if (address.label.toLowerCase() == 'work') {
      icon = Icons.work_outline_rounded;
    } else if (address.label.toLowerCase() == 'other') {
      icon = Icons.bookmark_outline_rounded;
    }

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Row(
            children: [
              Text(address.label, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Text(address.fullName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          subtitle: Text(
            address.displayAddress,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textHint),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
