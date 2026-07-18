import 'dart:typed_data';
import 'package:klinixy/features/auth/domain/entities/user_entity.dart';
import 'package:klinixy/features/orders/domain/entities/address_entity.dart';

abstract class AuthRepository {
  /// Returns current user if logged in, else null
  Future<UserEntity?> getCurrentUser();

  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;

  /// Google Sign In - creates user in Firestore if new
  Future<UserEntity> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Update user profile text fields
  Future<void> updateUserProfile({String? name, String? phone, String? photoUrl});

  /// Upload profile picture bytes to Firebase Storage and return the download URL.
  /// Accepts [bytes] (Uint8List) instead of a file path so it works on web too.
  Future<String> uploadProfilePicture(Uint8List bytes);

  /// Update current active location
  Future<void> updateActiveLocation({
    required String address,
    required double latitude,
    required double longitude,
  });

  /// Get stream of user's saved addresses
  Stream<List<AddressEntity>> getSavedAddresses();

  /// Add new address to user's saved addresses
  Future<void> addAddress(AddressEntity address);

  /// Update existing saved address
  Future<void> updateAddress(AddressEntity address);

  /// Delete saved address
  Future<void> deleteAddress(String addressId);
}
