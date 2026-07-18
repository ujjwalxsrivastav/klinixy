import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:klinixy/core/utils/location_models.dart';
export 'package:klinixy/core/utils/location_models.dart';

class LocationService {
  LocationService._();

  // Mapbox public token. Set MAPBOX_PUBLIC_TOKEN at build time if needed.
  static const String _mapboxToken = String.fromEnvironment(
    'MAPBOX_PUBLIC_TOKEN',
    defaultValue: 'YOUR_MAPBOX_PUBLIC_TOKEN',
  );
  static const String _mapboxGeocodingBase = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  // ─────────────────────────────────────────────────────────────────────────────
  // GPS
  // ─────────────────────────────────────────────────────────────────────────────

  /// Requests permissions and retrieves the user's current [Position].
  static Future<Position> getCurrentLocation() async {
    if (kIsWeb) {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Please allow location access.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Please allow it from Settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Mapbox Reverse Geocoding (CORS-friendly, works on Web + Mobile)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Returns a structured [AddressResult] for the given coordinates using Mapbox API.
  static Future<AddressResult> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    final url = '$_mapboxGeocodingBase/$longitude,$latitude.json?access_token=$_mapboxToken&country=in&limit=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;
        if (features.isNotEmpty) {
          return _parseMapboxFeature(features.first);
        }
      }
    } catch (_) {}

    return AddressResult(
      displayAddress: 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}',
      addressLine1: '',
      subLocality: '',
      city: '',
      state: '',
      pincode: '',
      country: 'India',
    );
  }

  /// Convenience: returns just a short display string (Sublocality, City).
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    final result = await reverseGeocode(latitude, longitude);
    return result.displayAddress;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Mapbox Autocomplete Suggestions (CORS-friendly, works on Web + Mobile)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Returns up to 5 place suggestions for the typed [query] using Mapbox API.
  /// Biased to [latitude]/[longitude] if provided.
  static Future<List<PlaceSuggestion>> getPlaceSuggestions(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    if (query.trim().isEmpty) return [];

    String url = '$_mapboxGeocodingBase/${Uri.encodeComponent(query)}.json?access_token=$_mapboxToken&country=in&limit=5';

    if (latitude != null && longitude != null) {
      url += '&proximity=$longitude,$latitude';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;
        return features.map((f) {
          final placeName = f['place_name'] as String;
          final text = f['text'] as String;
          final center = f['center'] as List; // [longitude, latitude]

          // Encode coordinates directly in placeId to bypass the details API call!
          final coordinatesId = '${center[1]},${center[0]}'; 

          final secondaryText = placeName.replaceFirst(text, '').replaceFirst(RegExp(r'^,\s*'), '');

          return PlaceSuggestion(
            placeId: coordinatesId,
            description: placeName,
            mainText: text,
            secondaryText: secondaryText.isNotEmpty ? secondaryText : placeName,
          );
        }).toList();
      }
    } catch (_) {}

    return [];
  }

  /// Retrieves the lat/lng coordinates for a given [placeId] encoded suggestion.
  static Future<Map<String, double>?> getPlaceLatLng(String placeId) async {
    try {
      // Coordinates were encoded directly as "latitude,longitude" in PlaceSuggestion.placeId
      final parts = placeId.split(',');
      if (parts.length == 2) {
        return {
          'latitude': double.parse(parts[0]),
          'longitude': double.parse(parts[1]),
        };
      }
    } catch (_) {}
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Private Mapbox Parser
  // ─────────────────────────────────────────────────────────────────────────────

  static AddressResult _parseMapboxFeature(Map<String, dynamic> feature) {
    final placeName = feature['place_name'] as String? ?? '';
    final text = feature['text'] as String? ?? '';
    final context = feature['context'] as List? ?? [];

    String subLocality = text;
    String city = '';
    String state = '';
    String pincode = '';
    String country = '';

    for (final c in context) {
      final id = c['id'] as String? ?? '';
      final name = c['text'] as String? ?? '';

      if (id.startsWith('postcode')) {
        pincode = name;
      } else if (id.startsWith('place')) {
        city = name;
      } else if (id.startsWith('region')) {
        state = name;
      } else if (id.startsWith('country')) {
        country = name;
      } else if (id.startsWith('neighborhood') || id.startsWith('locality')) {
        subLocality = name;
      }
    }

    if (city.isEmpty) {
      city = subLocality;
    }

    final addressParts = placeName.split(RegExp(r'[,\u060C\uFF0C]'));
    final addressLine1 = addressParts.isNotEmpty ? addressParts.first.trim() : text;

    // Standard display label
    final displayParts = <String>[];
    if (subLocality.isNotEmpty) displayParts.add(subLocality);
    if (city.isNotEmpty && city != subLocality) displayParts.add(city);
    final displayAddress = displayParts.isNotEmpty ? displayParts.join(', ') : placeName;

    return AddressResult(
      displayAddress: displayAddress,
      addressLine1: addressLine1,
      subLocality: subLocality,
      city: city,
      state: state,
      pincode: pincode,
      country: country,
    );
  }
}
