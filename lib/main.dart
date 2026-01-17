import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rollit/providers/action.provider.dart';
import 'package:rollit/providers/category.provider.dart';
import 'package:rollit/screens/add_players.screen.dart';
import 'package:rollit/screens/home.screen.dart';
import 'package:rollit/screens/party_mode.screen.dart';
import 'package:rollit/screens/party_mode_result.screen.dart';
import 'package:rollit/screens/settings.screen.dart';
import 'package:rollit/services/consent_manager.dart';
import 'package:rollit/services/preferences.service.dart';
import 'package:rollit/services/purchase.service.dart';
import 'package:flutter/material.dart';
import 'package:rollit/services/review.service.dart';
import 'package:rollit/services/update.service.dart';
import 'package:rollit/utils/cache.dart';
import 'package:flutter/services.dart';

const uiStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  systemStatusBarContrastEnforced: true,

  systemNavigationBarContrastEnforced: false,
  systemNavigationBarIconBrightness: Brightness.light,
);

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await PreferencesService.init();
  await EasyLocalization.ensureInitialized();

  await Future.wait([
    clearTempCache(),
    PurchaseService.instance.init(),
    ConsentManager.instance.gatherConsentAndInitAdsIfAllowed(),
    ReviewService.registerSession(),
  ]);

  SystemChrome.setSystemUIOverlayStyle(uiStyle);

  if (kDebugMode) {
    log('🛠️ Debug mode is ON');
  }

  FlutterNativeSplash.remove();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(child: const RollitApp()),
    ),
  );
}

class RollitApp extends ConsumerStatefulWidget {
  const RollitApp({super.key});

  @override
  ConsumerState<RollitApp> createState() => _RollitAppState();
}

class _RollitAppState extends ConsumerState<RollitApp> {
  @override
  void initState() {
    super.initState();
    ref.read(categoryProvider.notifier).loadCategories();
    ref.read(actionProvider.notifier).loadActions();
    UpdateService.checkForUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rollit!',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFFF7F8FF),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: uiStyle,
        ),
      ),
      routes: {
        '/settings': (_) => const SettingsScreen(),
        '/home': (_) => const HomeScreen(),
        '/add_players': (_) => const AddPlayersScreen(),
        '/party_mode': (_) => const PartyModeScreen(),
        '/party_mode_result': (_) => const PartyModeResultScreen(),
      },
      home: FutureBuilder(
        future: ref.read(categoryProvider.notifier).loadCategories(),
        builder: (_, __) {
          if (__.connectionState == ConnectionState.done) {
            return const HomeScreen();
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
