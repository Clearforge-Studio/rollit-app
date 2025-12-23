import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollit/providers/category.provider.dart';
import 'package:rollit/screens/result.screen.dart';
import 'package:rollit/services/i18n.service.dart';
import 'package:rollit/widgets/app_background.widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rollit/widgets/dice.widget.dart';
import 'package:rollit/widgets/paywall_sheet.dart';
import 'package:rollit/widgets/transition/slide_transition.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider.notifier).getCategories();
    final currentCategory = ref.watch(categoryProvider).currentCategory;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle!
              .copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemStatusBarContrastEnforced: true,
              ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, size: 28),
              color: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Roll',
                    style: GoogleFonts.poppins(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'it!',
                    style: GoogleFonts.poppins(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Dice(
                onRollComplete: (category) {
                  ref
                      .read(categoryProvider.notifier)
                      .setCurrentCategory(category);
                  Navigator.push(context, slideTransition(ResultScreen()));
                },
                initialFacePath: currentCategory != null
                    ? currentCategory.imagePath
                    : categories.first.imagePath,
                categories: categories,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add_players');
                },
                child: Text(I18nKeys.instance.home.partyMode.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
