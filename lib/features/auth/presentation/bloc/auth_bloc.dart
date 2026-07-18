import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      final user = await _authRepository.getCurrentUser();
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
      final user = await _authRepository.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
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
