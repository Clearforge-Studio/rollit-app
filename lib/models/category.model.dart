class DiceCategory {
  final String id;
  final String label;
  final String imagePath;

  DiceCategory({
    required this.id,
    required this.label,
    required this.imagePath,
  });

  factory DiceCategory.fromJson(Map<String, dynamic> json) {
    return DiceCategory(
      id: json['id'],
      label: json['label'],
      imagePath: json['image_path'],
    );
  }
}
