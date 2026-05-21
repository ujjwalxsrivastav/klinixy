import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:klinixy/core/utils/app_constants.dart';
import 'package:klinixy/features/auth/domain/entities/user_entity.dart';
import 'package:klinixy/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserFromFirestore(user.uid);
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await _getUserFromFirestore(user.uid);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');

      // Get auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user exists in Firestore
      final docRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // New user — create profile in Firestore
        final newUser = UserEntity(
          uid: user.uid,
          name: user.displayName ?? 'Klinixy User',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        await docRef.set(newUser.toMap());
        return newUser;
      }

      return UserEntity.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Google Sign In failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> updateUserProfile({String? name, String? phone}) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(updates);
  }

  Future<UserEntity?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserEntity.fromMap(doc.data()!);
  }
}
