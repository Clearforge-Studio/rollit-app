class DiceCategory {
  final String id;
  final String label;
  final String imagePath;
  final bool isIap;

  static const imitationCategory = 'imitation';
  static const challengeCategory = 'challenge';
  static const challengeExtremeCategory = 'challenge_extreme';
  static const funCategory = 'fun';
  static const wtfCategory = 'wtf';
  static const wtfPlusCategory = 'wtf_plus';
  static const miniGameCategory = 'mini_game';

  DiceCategory({
    required this.id,
    required this.label,
    required this.imagePath,
    this.isIap = false,
  });

  factory DiceCategory.fromJson(Map<String, dynamic> json) {
    return DiceCategory(
      id: json['id'],
      label: json['label'],
      imagePath: json['image_path'],
      isIap: json['is_iap'] ?? false,
    );
  }
}
