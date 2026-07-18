import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:klinixy/core/di/injection.dart';
import 'package:klinixy/core/router/app_router.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables before using app config
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup dependency injection
  await setupDI();

  runApp(const KlinixApp());
}

class KlinixApp extends StatefulWidget {
  const KlinixApp({super.key});

  @override
  State<KlinixApp> createState() => _KlinixAppState();
}

class _KlinixAppState extends State<KlinixApp> {
  late final AuthBloc _authBloc;
  late final CartBloc _cartBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _cartBloc = sl<CartBloc>();
  }

  @override
  void dispose() {
    _authBloc.close();
    _cartBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _cartBloc),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(_authBloc);
          return MaterialApp.router(
            title: 'Klinixy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
