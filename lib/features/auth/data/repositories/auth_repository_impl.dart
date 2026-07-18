import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:klinixy/core/utils/app_constants.dart';
import 'package:klinixy/features/auth/domain/entities/user_entity.dart';
import 'package:klinixy/features/auth/domain/repositories/auth_repository.dart';
import 'package:klinixy/features/orders/domain/entities/address_entity.dart';

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
      late final UserCredential userCredential;

      if (kIsWeb) {
        // ── Web: use popup flow (no google_sign_in needed) ──
        final googleProvider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // ── Mobile: use google_sign_in package ──
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) throw Exception('Google sign in aborted');

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential =
            await _firebaseAuth.signInWithCredential(credential);
      }

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
  Future<void> updateUserProfile({String? name, String? phone, String? photoUrl}) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(updates);
  }

  @override
  Future<String> uploadProfilePicture(Uint8List bytes) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(uid)
        .child('profile.jpg');

    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await ref.getDownloadURL();
  }

  @override
  Future<void> updateActiveLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({
      'activeAddress': address,
      'activeLatitude': latitude,
      'activeLongitude': longitude,
    });
  }

  @override
  Stream<List<AddressEntity>> getSavedAddresses() {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddressEntity.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }

  @override
  Future<void> addAddress(AddressEntity address) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('addresses')
        .doc();

    final addressWithId = address.toMap()..['id'] = docRef.id;
    await docRef.set(addressWithId);
  }

  @override
  Future<void> updateAddress(AddressEntity address) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('addresses')
        .doc(address.id)
        .update(address.toMap());
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
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
