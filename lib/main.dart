import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rollit/providers/action.provider.dart';
import 'package:rollit/providers/category.provider.dart';
import 'package:rollit/screens/home.screen.dart';
import 'package:rollit/screens/settings.screen.dart';
import 'package:rollit/services/ads.service.dart';
import 'package:rollit/services/preferences.service.dart';
import 'package:rollit/services/purchase.service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferencesService.init();
  await Future.wait([
    PurchaseService.instance.init(),
    AdsService.instance.init(),
  ]);

  runApp(ProviderScope(child: const RollitApp()));
}

class RollitApp extends ConsumerStatefulWidget {
  const RollitApp({super.key});

  @override
  ConsumerState<RollitApp> createState() => _RollitAppState();
}

class _RollitAppState extends ConsumerState<RollitApp> {
  @override
  void initState() {
    ref.read(categoryProvider.notifier).loadCategories();
    ref.read(actionProvider.notifier).loadActions();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rollit!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFFF7F8FF),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      routes: {'/settings': (_) => const SettingsScreen()},
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
