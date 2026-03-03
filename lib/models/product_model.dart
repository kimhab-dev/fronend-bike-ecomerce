class ProductModel {
  final int? id;
  final String name;
  final String description;
  final double? price;
  final String? engine;
  final String? power;
  final String? imageUrl;
  final String? category;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    this.price,
    this.engine,
    this.power,
    this.imageUrl,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // some APIs might return image fields under different keys
    String? img = json['image']?.toString() ??
        json['image_url']?.toString() ??
        json['imageUrl']?.toString();

    return ProductModel(
      id: json['id'] as int?,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      engine: json['engine']?.toString(),
      power: json['power']?.toString(),
      imageUrl: img,
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      if (price != null) 'price': price,
      if (engine != null) 'engine': engine,
      if (power != null) 'power': power,
      if (imageUrl != null) 'image_url': imageUrl,
      if (category != null) 'category': category,
    };
  }
}
