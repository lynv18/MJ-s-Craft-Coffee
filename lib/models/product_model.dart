class Product {
  final String id;
  final String categoryId;
  final String name;
  final String category;
  final String description;
  final double price;
  final String? imageUrl;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      categoryId: map['category_id']?.toString() ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      // Nagse-set ng fallback price kung sakaling double/num o null
      price: (map['price'] as num?)?.toDouble() ?? 120.0, 
      imageUrl: map['image_url'],
    );
  }
}