import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollit/models/dice_action.model.dart';
import 'package:rollit/models/dice_category.model.dart';
import 'package:rollit/providers/action.provider.dart';
import 'package:rollit/providers/category.provider.dart';
import 'package:flutter/material.dart';
import 'package:rollit/widgets/app_background.widget.dart';
import 'package:rollit/widgets/dice.widget.dart';
import 'package:rollit/widgets/result_card.widget.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  List<DiceCategory> _categories = [];
  List<DiceAction> _actions = [];
  String _categoryLabel = '';
  String _categoryImagePath = '';
  String _actionText = '';
  late AnimationController _controller;
  late Animation<double> _animation;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // animation du lancer
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuint,
    );

    _loadData();
  }

  Future<void> _loadData() async {
    final categories = ref.read(categoryProvider.notifier).getCategories();
    final actions = ref.read(actionProvider).actions;

    final category =
        ref.read(categoryProvider).currentCategory ??
        categories[_random.nextInt(categories.length)];
    final categoryActions = actions
        .firstWhere((a) => a.category == category.id)
        .actions;

    final action = categoryActions[_random.nextInt(categoryActions.length)];

    _categories = categories;
    _actions = actions;
    _categoryLabel = category.label;
    _categoryImagePath = category.imagePath;
    _actionText = action;

    _controller.forward(from: 0);
  }

  void _roll() async {
    final category =
        ref.read(categoryProvider).currentCategory ??
        _categories[_random.nextInt(_categories.length)];
    final categoryActions = _actions
        .firstWhere((a) => a.category == category.id)
        .actions;

    final action = categoryActions[_random.nextInt(categoryActions.length)];

    setState(() {
      _categoryLabel = category.label;
      _categoryImagePath = category.imagePath;
      _actionText = action;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider.notifier).getCategories();
    final currentCategory = ref.watch(categoryProvider).currentCategory;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Carte résultat animée
                Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final scale = 0.8 + (_animation.value * 0.2);
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: ResultCard(
                      title: _categoryLabel,
                      icon: _categoryImagePath.isNotEmpty
                          ? Image.asset(
                              _categoryImagePath,
                              width: 80,
                              height: 80,
                            )
                          : null,
                      actionText: _actionText,
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                Dice(
                  onRollComplete: (category) {
                    ref
                        .read(categoryProvider.notifier)
                        .setCurrentCategory(category);

                    _roll();
                  },
                  onRollStart: () {
                    setState(() {
                      _categoryLabel = '';
                      _categoryImagePath = '';
                      _actionText = '';
                    });
                  },
                  hideDiceInitially: false,
                  hideDiceOnComplete: false,
                  initialFacePath:
                      currentCategory?.imagePath ?? categories.first.imagePath,
                  categories: categories,
                  diceText: "Re-roll!",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
