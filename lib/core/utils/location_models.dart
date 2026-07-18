/// Holds the result of a reverse-geocode lookup.
class AddressResult {
  final String displayAddress; // "Karol Bagh, New Delhi"
  final String addressLine1;   // street / landmark
  final String subLocality;    // Karol Bagh
  final String city;           // New Delhi
  final String state;          // Delhi
  final String pincode;        // 110005
  final String country;        // India

  const AddressResult({
    required this.displayAddress,
    required this.addressLine1,
    required this.subLocality,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  AddressResult copyWith({
    String? displayAddress,
    String? addressLine1,
    String? subLocality,
    String? city,
    String? state,
    String? pincode,
    String? country,
  }) {
    return AddressResult(
      displayAddress: displayAddress ?? this.displayAddress,
      addressLine1: addressLine1 ?? this.addressLine1,
      subLocality: subLocality ?? this.subLocality,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
    );
  }
}

/// A Place suggestion from Google Places Autocomplete API.
class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}
