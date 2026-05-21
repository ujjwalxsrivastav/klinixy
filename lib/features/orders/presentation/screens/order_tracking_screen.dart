import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';

// Order status enum
enum OrderStatus { placed, confirmed, packed, picked, outForDelivery, delivered }

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed: return 'Order Placed';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.packed: return 'Packed';
      case OrderStatus.picked: return 'Picked Up';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.placed: return 'Your order has been placed';
      case OrderStatus.confirmed: return 'Pharmacy has confirmed your order';
      case OrderStatus.packed: return 'Medicines packed & ready';
      case OrderStatus.picked: return 'Delivery partner picked up order';
      case OrderStatus.outForDelivery: return 'On the way to your location';
      case OrderStatus.delivered: return 'Order delivered successfully!';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.placed: return Icons.check_circle_outline_rounded;
      case OrderStatus.confirmed: return Icons.store_rounded;
      case OrderStatus.packed: return Icons.inventory_2_rounded;
      case OrderStatus.picked: return Icons.delivery_dining_rounded;
      case OrderStatus.outForDelivery: return Icons.two_wheeler_rounded;
      case OrderStatus.delivered: return Icons.home_rounded;
    }
  }
}

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Mock current order status
  final OrderStatus _currentStatus = OrderStatus.outForDelivery;

  // Mock delivery partner location (Delhi)
  static const LatLng _deliveryPartnerLoc = LatLng(28.6139, 77.2090);
  static const LatLng _userLoc = LatLng(28.6200, 77.2150);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _setupMapData();
  }

  void _setupMapData() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('delivery'),
        position: _deliveryPartnerLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Delivery Partner'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: _userLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    ]);

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: const [_deliveryPartnerLoc, _userLoc],
        color: AppColors.primary,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Full-screen map
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(28.6165, 77.2120),
                zoom: 14,
              ),
              onMapCreated: (c) => _mapController = c,
              markers: _markers,
              polylines: _polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: TapScale(
              onTap: () => context.pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.card,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
          ),

          // Bottom tracking panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _TrackingPanel(
              orderId: widget.orderId,
              status: _currentStatus,
              pulseAnim: _pulseAnim,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingPanel extends StatelessWidget {
  final String orderId;
  final OrderStatus status;
  final Animation<double> pulseAnim;

  const _TrackingPanel({
    required this.orderId,
    required this.status,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ETA banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ScaleTransition(
                        scale: pulseAnim,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.two_wheeler_rounded,
                              color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Arriving in ~12 minutes',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Order #${orderId.toUpperCase()}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Delivery partner info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          'RK',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rahul Kumar',
                                style: AppTextStyles.titleMedium),
                            Text('Delivery Partner · ⭐ 4.8',
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      TapScale(
                        onTap: () {},
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TapScale(
                        onTap: () {},
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text('Order Progress', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 16),

                // Status timeline
                _StatusTimeline(currentStatus: status),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  const _StatusTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final statuses = OrderStatus.values;

    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isDone = status.index <= currentStatus.index;
        final isCurrent = status == currentStatus;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: isDone ? AppColors.primaryGradient : null,
                    color: isDone ? null : AppColors.divider,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    status.icon,
                    color: isDone ? Colors.white : AppColors.textHint,
                    size: 18,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: isDone && status.index < currentStatus.index
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 6, bottom: isLast ? 0 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.label,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDone
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontWeight: isCurrent ? FontWeight.w700 : null,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 2),
                      Text(
                        status.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
