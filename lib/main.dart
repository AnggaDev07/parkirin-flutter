// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parkirin/core/services/localization_service.dart';
import 'package:parkirin/core/services/session_service.dart';
import 'package:parkirin/core/services/theme_service.dart';
import 'package:parkirin/features/authentication/domain/repositories/i_auth_repository.dart';
import 'package:parkirin/features/authentication/domain/usecases/google_sign_in_usecase.dart';
import 'package:parkirin/features/authentication/domain/usecases/login_parking_attendant_usecase.dart';
import 'package:parkirin/features/authentication/domain/usecases/login_usecase.dart';
import 'package:parkirin/features/driver/presentation/bloc/latest_pending_bills_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_bills_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_tickets_count_bloc.dart';
import 'package:parkirin/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/enums/user_role.dart';
import 'core/themes/app_theme.dart';
import 'di/dependency_injection.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/driver/presentation/pages/driver_home_page.dart';
import 'features/driver/presentation/pages/driver_settings_page.dart';
import 'features/onboarding/presentation/pages/onboarding_main.dart';
import 'features/parking_attendant/presentation/pages/parking_attendant_home_page.dart';
import 'features/parking_attendant/presentation/pages/parking_attendant_settings_page.dart';
import 'features/ticket_management/presentation/bloc/ticket_bloc.dart';
import 'firebase_options.dart';
import 'localization/app_localizations.dart';

Future<void> resetOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('showOnboarding', true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase$
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    Firebase.app();
  }

  // Initialize services
  final localizationService = LocalizationService();
  final themeService = ThemeService();

  // Uncomment the next line when you want to reset onboarding
  //await resetOnboarding();

  // Setup dependency injection
  setupDependencyInjection();

  // Get onboarding status
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;

  final trace = FirebasePerformance.instance.newTrace('app_startup_time');
  await trace.start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalizationService>.value(
          value: localizationService,
        ),
        ChangeNotifierProvider<ThemeService>.value(
          value: themeService,
        ),
        BlocProvider(
          create: (context) {
            final authBloc = AuthBloc(
              getIt<LoginUseCase>(),
              getIt<IAuthRepository>(),
              getIt<GoogleSignInUseCase>(),
              getIt<LoginParkingAttendantUseCase>(),
              getIt<SessionService>(),
            );
            authBloc.checkSession();
            return authBloc;
          },
        ),
        // Add TicketBloc provider
        BlocProvider(
          create: (context) => getIt<TicketBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<PendingTicketsCountBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<LatestPendingBillsBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<PendingBillsBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<PaymentBloc>(),
        ),
      ],
      child: MyApp(
        showOnboarding: showOnboarding,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Parkirin',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      locale: localizationService.currentLocale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('id', ''),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (showOnboarding) {
            return const OnboardingMainScreen();
          }

          if (state is AuthSuccess) {
            if (state.user.role == UserRole.driver) {
              return const DriverHomePage();
            } else {
              return const ParkingAttendantHomePage();
            }
          }

          return const LoginPage();
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/driver_home': (context) => const DriverHomePage(),
        '/parking_attendant_home': (context) =>
            const ParkingAttendantHomePage(),
        '/driver_settings': (context) => const DriverSettingsPage(),
        '/parking_attendant_settings': (context) =>
            const ParkingAttendantSettingsPage(),
      },
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
