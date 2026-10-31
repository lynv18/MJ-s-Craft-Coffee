class CategoryItem {
  final String id;
  final String name;
  final String slug;

  CategoryItem({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
    );
  }
}