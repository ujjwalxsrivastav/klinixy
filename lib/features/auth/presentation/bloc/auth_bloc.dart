import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:klinixy/core/utils/app_constants.dart';
import 'package:klinixy/features/auth/domain/entities/user_entity.dart';
import 'package:klinixy/features/auth/domain/repositories/auth_repository.dart';

// ── Events ────────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthGuestSignInRequested extends AuthEvent {
  const AuthGuestSignInRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? phone;
  final String? photoUrl;

  const AuthUpdateProfileRequested({this.name, this.phone, this.photoUrl});

  @override
  List<Object?> get props => [name, phone, photoUrl];
}

class AuthUpdatePhotoRequested extends AuthEvent {
  final Uint8List bytes;

  const AuthUpdatePhotoRequested(this.bytes);

  @override
  List<Object?> get props => [bytes];
}

class AuthUpdateLocationRequested extends AuthEvent {
  final String address;
  final double latitude;
  final double longitude;

  const AuthUpdateLocationRequested({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [address, latitude, longitude];
}

// ── States ────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckAuth);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthGuestSignInRequested>(_onGuestSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthUpdateProfileRequested>(_onUpdateProfile);
    on<AuthUpdatePhotoRequested>(_onUpdatePhoto);
    on<AuthUpdateLocationRequested>(_onUpdateLocation);
  }

  Future<void> _onCheckAuth(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository
          .getCurrentUser()
          .timeout(const Duration(milliseconds: 1500));
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository
          .signInWithGoogle()
          .timeout(const Duration(seconds: 8));
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGuestSignIn(
    AuthGuestSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Set a short timeout for network operations
      final userCredential = await FirebaseAuth.instance
          .signInAnonymously()
          .timeout(const Duration(seconds: 3));
      final user = userCredential.user!;
      
      final docRef = FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(user.uid);
      final doc = await docRef.get().timeout(const Duration(seconds: 2));
      
      late final UserEntity userEntity;
      if (!doc.exists) {
        userEntity = UserEntity(
          uid: user.uid,
          name: 'Demo Guest Patient',
          email: 'demo.patient@klinixy.com',
          photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
          createdAt: DateTime.now(),
        );
        await docRef.set(userEntity.toMap());
      } else {
        userEntity = UserEntity.fromMap(doc.data()!);
      }
      
      emit(AuthAuthenticated(userEntity));
    } catch (e) {
      // Fallback: If Firebase fails or times out, immediately log the user in with a local guest session
      final fallbackUser = UserEntity(
        uid: 'local_guest_uid',
        name: 'Demo Guest Patient (Offline Mode)',
        email: 'guest@klinixy.com',
        photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
        createdAt: DateTime.now(),
      );
      emit(AuthAuthenticated(fallbackUser));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      await _authRepository.updateUserProfile(
        name: event.name,
        phone: event.phone,
        photoUrl: event.photoUrl,
      );
      final updatedUser = currentState.user.copyWith(
        name: event.name,
        phone: event.phone,
        photoUrl: event.photoUrl,
      );
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthAuthenticated(currentState.user));
    }
  }

  Future<void> _onUpdatePhoto(
    AuthUpdatePhotoRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      final downloadUrl = await _authRepository.uploadProfilePicture(event.bytes);
      await _authRepository.updateUserProfile(photoUrl: downloadUrl);
      final updatedUser = currentState.user.copyWith(photoUrl: downloadUrl);
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError('Failed to upload image: $e'));
      emit(AuthAuthenticated(currentState.user));
    }
  }

  Future<void> _onUpdateLocation(
    AuthUpdateLocationRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      await _authRepository.updateActiveLocation(
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      final updatedUser = currentState.user.copyWith(
        activeAddress: event.address,
        activeLatitude: event.latitude,
        activeLongitude: event.longitude,
      );
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError('Failed to update location: $e'));
      emit(AuthAuthenticated(currentState.user));
    }
  }
}
