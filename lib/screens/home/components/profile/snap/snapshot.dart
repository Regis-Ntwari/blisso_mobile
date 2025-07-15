class Snapshot {
  final int id;
  final String category;
  final String subCategory;
  final String name;

  Snapshot({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.name,
  });

  @override
  String toString() {
    return '$id $name $category $subCategory';
  }
}