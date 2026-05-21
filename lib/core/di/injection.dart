import 'package:get_it/get_it.dart';
import 'package:klinixy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:klinixy/features/auth/domain/repositories/auth_repository.dart';
import 'package:klinixy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  // ── Repositories ──────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );

  // ── BLoCs ─────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );

  // Cart is singleton — persists across screens
  sl.registerLazySingleton<CartBloc>(
    () => CartBloc(),
  );
}
