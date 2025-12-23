class ActionConstraint {
  final String type;
  final int value;
  final int? valueLite;

  ActionConstraint({required this.type, required this.value, this.valueLite});

  factory ActionConstraint.fromJson(Map<String, dynamic> json) {
    return ActionConstraint(
      type: json['type'],
      value: json['value'],
      valueLite: json['value_lite'],
    );
  }
}

class DiceActionItem {
  final String id;
  final String text;
  final List<ActionConstraint> constraints;

  DiceActionItem({
    required this.id,
    required this.text,
    required this.constraints,
  });

  factory DiceActionItem.fromJson(Map<String, dynamic> json) {
    return DiceActionItem(
      id: json['id'],
      text: json['text'],
      constraints:
          (json['constraints'] as List<dynamic>)
              .map((constraint) => ActionConstraint.fromJson(constraint))
              .toList(),
    );
  }
}

class DiceAction {
  final String category;
  final List<DiceActionItem> actions;

  DiceAction({required this.category, required this.actions});

  factory DiceAction.fromJson(Map<String, dynamic> json) {
    return DiceAction(
      category: json['category'],
      actions:
          (json['actions'] as List<dynamic>)
              .map((action) => DiceActionItem.fromJson(action))
              .toList(),
    );
  }
}
