import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollit/models/dice_category.model.dart';
import 'package:rollit/services/data.service.dart';
import 'package:rollit/services/preferences.service.dart';

class CategoryState {
  final List<DiceCategory> categories;
  final DiceCategory? currentCategory;

  CategoryState({required this.categories, this.currentCategory});
}

class CategoryNotifier extends Notifier<CategoryState> {
  @override
  CategoryState build() {
    return CategoryState(categories: []);
  }

  Future<void> loadCategories() async {
    if (state.categories.isNotEmpty) {
      return;
    }

    final List<DiceCategory> categories = await DataService.loadCategories();

    state = CategoryState(categories: categories);
  }

  void setCurrentCategory(DiceCategory category) {
    state = CategoryState(
      categories: state.categories,
      currentCategory: category,
    );
  }

  List<DiceCategory> getCategories() {
    final enabledCategories = PreferencesService.getEnabledCategories();

    return state.categories.where((category) {
      return enabledCategories.contains(category.id);
    }).toList();
  }
}

final categoryProvider = NotifierProvider<CategoryNotifier, CategoryState>(
  () => CategoryNotifier(),
);
