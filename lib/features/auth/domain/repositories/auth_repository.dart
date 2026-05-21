import 'package:klinixy/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Returns current user if logged in, else null
  Future<UserEntity?> getCurrentUser();

  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;

  /// Google Sign In - creates user in Firestore if new
  Future<UserEntity> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Update user profile
  Future<void> updateUserProfile({String? name, String? phone});
}
