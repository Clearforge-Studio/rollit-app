class DiceAction {
  final String category;
  final List<String> actions;

  DiceAction({required this.category, required this.actions});

  factory DiceAction.fromJson(Map<String, dynamic> json) {
    return DiceAction(
      category: json['category'],
      actions: List<String>.from(json['actions']),
    );
  }
}
