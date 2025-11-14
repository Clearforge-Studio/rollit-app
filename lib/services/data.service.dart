import 'dart:convert';
import 'package:rollit/models/action.model.dart';
import 'package:rollit/models/category.model.dart';
import 'package:flutter/services.dart';

class DataService {
  static Future<List<DiceCategory>> loadCategories() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/categories.json',
    );
    final List data = json.decode(jsonString);
    return data.map((e) => DiceCategory.fromJson(e)).toList();
  }

  static Future<List<DiceAction>> loadActions() async {
    final jsonString = await rootBundle.loadString('assets/data/actions.json');
    final List data = json.decode(jsonString);
    return data.map((e) => DiceAction.fromJson(e)).toList();
  }
}
