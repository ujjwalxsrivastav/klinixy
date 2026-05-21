import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String label; // Home, Work, Other
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  String get displayAddress =>
      '$addressLine1${addressLine2.isNotEmpty ? ', $addressLine2' : ''}, $city - $pincode';

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'fullName': fullName,
        'phone': phone,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };

  factory AddressEntity.fromMap(Map<String, dynamic> map) => AddressEntity(
        id: map['id'] as String? ?? '',
        label: map['label'] as String? ?? 'Home',
        fullName: map['fullName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        addressLine1: map['addressLine1'] as String? ?? '',
        addressLine2: map['addressLine2'] as String? ?? '',
        city: map['city'] as String? ?? '',
        state: map['state'] as String? ?? '',
        pincode: map['pincode'] as String? ?? '',
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        isDefault: map['isDefault'] as bool? ?? false,
      );
}
