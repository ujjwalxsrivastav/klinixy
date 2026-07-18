import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/utils/location_service.dart';

/// Result returned by the map picker — callers can use this to pre-fill address fields.
class MapPickerResult {
  final double latitude;
  final double longitude;
  final AddressResult address;

  const MapPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

/// Full-screen Zomato-style map where the user can:
///  • drag a pin to any location
///  • tap "My Location" to jump to GPS
///  • search for a locality via the search bar with autocomplete
/// Returns a [MapPickerResult] when the user confirms the pin position.
class MapAddressPickerScreen extends StatefulWidget {
  /// Optional starting coordinates.
  final double? initialLat;
  final double? initialLng;

  const MapAddressPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapAddressPickerScreen> createState() => _MapAddressPickerScreenState();
}

class _MapAddressPickerScreenState extends State<MapAddressPickerScreen> {
  GoogleMapController? _mapController;

  // Pin position
  late LatLng _pinPosition;
  AddressResult? _currentAddress;
  bool _isReverseGeocoding = false;

  // Search state
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _isSearching = false;
  List<PlaceSuggestion> _suggestions = [];
  Timer? _debounce;

  // GPS state
  bool _isFetchingGPS = false;

  @override
  void initState() {
    super.initState();
    _pinPosition = LatLng(
      widget.initialLat ?? 28.6139, // Default: New Delhi
      widget.initialLng ?? 77.2090,
    );
    _searchController.addListener(_onSearchChanged);
    // Kick off initial reverse geocode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocode(_pinPosition);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Logic
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _isReverseGeocoding = true);
    try {
      final result = await LocationService.reverseGeocode(pos.latitude, pos.longitude);
      if (mounted) setState(() => _currentAddress = result);
    } finally {
      if (mounted) setState(() => _isReverseGeocoding = false);
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isFetchingGPS = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      final latLng = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));
      setState(() => _pinPosition = latLng);
      await _reverseGeocode(latLng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingGPS = false);
    }
  }

  void _onCameraIdle() {
    // Called when user finishes dragging — pin is already at _pinPosition (updated by onCameraMove)
    _reverseGeocode(_pinPosition);
  }

  void _onCameraMove(CameraPosition pos) {
    setState(() => _pinPosition = pos.target);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        setState(() => _suggestions = []);
        return;
      }
      setState(() => _isSearching = true);
      final results = await LocationService.getPlaceSuggestions(
        query,
        latitude: _pinPosition.latitude,
        longitude: _pinPosition.longitude,
      );
      if (mounted) setState(() { _suggestions = results; _isSearching = false; });
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    _searchFocus.unfocus();
    _searchController.text = suggestion.mainText;
    setState(() => _suggestions = []);

    final coords = await LocationService.getPlaceLatLng(suggestion.placeId);
    if (coords != null && mounted) {
      final latLng = LatLng(coords['latitude']!, coords['longitude']!);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));
      setState(() => _pinPosition = latLng);
      await _reverseGeocode(latLng);
    }
  }

  void _confirm() {
    if (_currentAddress == null) return;
    Navigator.of(context).pop(
      MapPickerResult(
        latitude: _pinPosition.latitude,
        longitude: _pinPosition.longitude,
        address: _currentAddress!,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UI
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pinPosition,
              zoom: 15,
            ),
            onMapCreated: (c) => _mapController = c,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),

          // ── Centre pin overlay (the map moves UNDER this fixed pin) ──────
          const Center(
            child: _CentrePin(),
          ),

          // ── Search bar ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Material(
                    elevation: 6,
                    shadowColor: Colors.black26,
                    borderRadius: BorderRadius.circular(14),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search area, street, landmark...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _suggestions = []);
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                    ),
                  ),
                ),

                // Autocomplete suggestions
                if (_suggestions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      elevation: 6,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(14),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 48),
                          itemBuilder: (context, i) {
                            final s = _suggestions[i];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              title: Text(s.mainText, style: AppTextStyles.titleSmall),
                              subtitle: s.secondaryText.isNotEmpty
                                  ? Text(
                                      s.secondaryText,
                                      style: AppTextStyles.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              onTap: () => _selectSuggestion(s),
                              dense: true,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: LinearProgressIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.primaryLight,
                    ),
                  ),
              ],
            ),
          ),

          // ── Back button ──────────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 70),
                child: _MapIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          // ── My Location FAB ──────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 200,
            child: _isFetchingGPS
                ? const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : _MapIconButton(
                    icon: Icons.my_location_rounded,
                    onTap: _goToMyLocation,
                    primaryColor: true,
                  ),
          ),

          // ── Bottom address card + Confirm button ─────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _isReverseGeocoding
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: 180,
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 240,
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentAddress?.subLocality.isNotEmpty == true
                                ? _currentAddress!.subLocality
                                : (_currentAddress?.city ?? 'Select location'),
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_currentAddress?.addressLine1.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              _currentAddress!.addressLine1,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (_currentAddress?.city.isNotEmpty == true ||
                              _currentAddress?.pincode.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              [
                                _currentAddress?.city,
                                _currentAddress?.pincode,
                              ].where((s) => s != null && s.isNotEmpty).join(' — '),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (_currentAddress == null || _isReverseGeocoding)
                  ? null
                  : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Confirm Location',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// The stationary pin that sits in the centre of the screen while the map moves.
class _CentrePin extends StatelessWidget {
  const _CentrePin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.location_on_rounded,
              color: Colors.white, size: 26),
        ),
        // Small triangle / stem
        CustomPaint(
          size: const Size(16, 12),
          painter: _TrianglePainter(AppColors.primary),
        ),
        // Shadow dot
        Container(
          width: 10,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool primaryColor;

  const _MapIconButton({
    required this.icon,
    required this.onTap,
    this.primaryColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primaryColor ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 22,
            color: primaryColor ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
