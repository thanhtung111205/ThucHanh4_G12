// Basic product model mapped from FakeStore API
class Product {
	Product({
		required this.id,
		required this.title,
		required this.description,
		required this.category,
		required this.image,
		required this.price,
		required this.rating,
		required this.ratingCount,
	});

	final int id;
	final String title;
	final String description;
	final String category;
	final String image;
	final double price;
	final double rating;
	final int ratingCount;

	factory Product.fromJson(Map<String, dynamic> json) {
		final ratingJson = json['rating'] as Map<String, dynamic>?;
		return Product(
			id: (json['id'] as num).toInt(),
			title: (json['title'] as String?)?.trim() ?? '',
			description: (json['description'] as String?)?.trim() ?? '',
			category: (json['category'] as String?)?.trim() ?? 'unknown',
			image: (json['image'] as String?)?.trim() ?? '',
			price: (json['price'] as num?)?.toDouble() ?? 0,
			rating: (ratingJson?['rate'] as num?)?.toDouble() ?? 0,
			ratingCount: (ratingJson?['count'] as num?)?.toInt() ?? 0,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'title': title,
			'description': description,
			'category': category,
			'image': image,
			'price': price,
			'rating': rating,
			'ratingCount': ratingCount,
		};
	}
}
