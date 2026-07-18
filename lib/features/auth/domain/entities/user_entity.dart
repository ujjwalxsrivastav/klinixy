import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phone;
  final DateTime createdAt;

  final String? activeAddress;
  final double? activeLatitude;
  final double? activeLongitude;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
    required this.createdAt,
    this.activeAddress,
    this.activeLatitude,
    this.activeLongitude,
  });

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        photoUrl,
        phone,
        createdAt,
        activeAddress,
        activeLatitude,
        activeLongitude
      ];

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
    DateTime? createdAt,
    String? activeAddress,
    double? activeLatitude,
    double? activeLongitude,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      activeAddress: activeAddress ?? this.activeAddress,
      activeLatitude: activeLatitude ?? this.activeLatitude,
      activeLongitude: activeLongitude ?? this.activeLongitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'activeAddress': activeAddress,
      'activeLatitude': activeLatitude,
      'activeLongitude': activeLongitude,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      phone: map['phone'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      activeAddress: map['activeAddress'] as String?,
      activeLatitude: (map['activeLatitude'] as num?)?.toDouble(),
      activeLongitude: (map['activeLongitude'] as num?)?.toDouble(),
    );
  }
}
