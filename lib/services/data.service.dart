import 'dart:convert';
import 'package:rollit/models/dice_action.model.dart';
import 'package:rollit/models/dice_category.model.dart';
import 'package:flutter/services.dart';
import 'package:rollit/services/purchase.service.dart';

class DataService {
  static Future<List<DiceCategory>> loadCategories() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/categories.json',
    );

    final wtfPlusOwned = PurchaseService.instance.wtfPlusOwned;

    final List data = json.decode(jsonString);
    return data.map((e) => DiceCategory.fromJson(e)).toList().where((category) {
      if (category.isIap && category.id == 'wtf_plus') {
        return wtfPlusOwned;
      }

      return true;
    }).toList();
  }

  static Future<List<DiceAction>> loadActions() async {
    final jsonString = await rootBundle.loadString('assets/data/actions.json');
    final List data = json.decode(jsonString);
    return data.map((e) => DiceAction.fromJson(e)).toList();
  }
}
