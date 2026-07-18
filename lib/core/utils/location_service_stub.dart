import 'package:geolocator/geolocator.dart';
import 'location_models.dart';

class LocationService {
  LocationService._();

  static Future<Position> getCurrentLocation() async {
    throw UnimplementedError('Platform not supported');
  }

  static Future<AddressResult> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    throw UnimplementedError('Platform not supported');
  }

  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    throw UnimplementedError('Platform not supported');
  }

  static Future<List<PlaceSuggestion>> getPlaceSuggestions(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    throw UnimplementedError('Platform not supported');
  }

  static Future<Map<String, double>?> getPlaceLatLng(String placeId) async {
    throw UnimplementedError('Platform not supported');
  }
}
