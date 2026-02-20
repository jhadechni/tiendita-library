/// Rating information for a product.
///
/// Represents the user rating data from the Fake Store API.
///
/// ## Example
/// ```dart
/// final rating = Rating(rate: 4.5, count: 120);
/// print('${rating.rate}/5 (${rating.count} reviews)');
/// ```
///
/// ## JSON Structure
/// ```json
/// {
///   "rate": 4.5,
///   "count": 120
/// }
/// ```
class Rating {
  /// Creates a new [Rating] instance.
  ///
  /// - [rate]: The average rating (0.0 - 5.0)
  /// - [count]: Number of ratings/reviews
  const Rating({
    required this.rate,
    required this.count,
  });

  /// Creates a [Rating] from JSON data.
  ///
  /// Handles numeric conversion for the rate field (int or double).
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num).toDouble(),
      count: json['count'] as int,
    );
  }

  /// The average rating value (0.0 - 5.0).
  final double rate;

  /// The total number of ratings/reviews.
  final int count;

  /// Converts this rating to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'count': count,
    };
  }

  @override
  String toString() => 'Rating(rate: $rate, count: $count)';
}

/// Product model from Fake Store API.
///
/// Represents a product item available in the store.
///
/// ## Example
/// ```dart
/// final product = Product(
///   id: 1,
///   title: 'Backpack',
///   price: 109.95,
///   description: 'A great backpack',
///   category: 'accessories',
///   image: 'https://example.com/image.jpg',
///   rating: Rating(rate: 4.5, count: 120),
/// );
/// ```
///
/// ## JSON Structure
/// ```json
/// {
///   "id": 1,
///   "title": "Fjallraven - Foldsack No. 1 Backpack",
///   "price": 109.95,
///   "description": "Your perfect pack for everyday use...",
///   "category": "men's clothing",
///   "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
///   "rating": {
///     "rate": 3.9,
///     "count": 120
///   }
/// }
/// ```
///
/// ## Categories
/// The Fake Store API includes these categories:
/// - `electronics`
/// - `jewelery`
/// - `men's clothing`
/// - `women's clothing`
class Product {
  /// Creates a new [Product] instance.
  ///
  /// All fields are required.
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  /// Creates a [Product] from JSON data.
  ///
  /// Handles numeric conversion for the price field (int or double).
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: Rating.fromJson(json['rating'] as Map<String, dynamic>),
    );
  }

  /// Unique identifier for the product.
  final int id;

  /// Product title/name.
  final String title;

  /// Product price in USD.
  final double price;

  /// Detailed product description.
  final String description;

  /// Product category (e.g., "electronics", "jewelery").
  final String category;

  /// URL to the product image.
  final String image;

  /// User rating information.
  final Rating rating;

  /// Converts this product to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating.toJson(),
    };
  }

  @override
  String toString() => 'Product(id: $id, title: $title, price: $price)';
}
