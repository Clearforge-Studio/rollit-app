import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollit/models/category.model.dart';
import 'package:rollit/services/data.service.dart';

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
}

final categoryProvider = NotifierProvider<CategoryNotifier, CategoryState>(
  () => CategoryNotifier(),
);
