/// Product item within a cart.
///
/// Represents a single product entry in a shopping cart with quantity.
///
/// ## Example
/// ```dart
/// final item = CartProduct(productId: 1, quantity: 2);
/// print('Product ${item.productId}: ${item.quantity} units');
/// ```
///
/// ## JSON Structure
/// ```json
/// {
///   "productId": 1,
///   "quantity": 2
/// }
/// ```
class CartProduct {
  /// Creates a new [CartProduct] instance.
  ///
  /// - [productId]: ID of the product being added
  /// - [quantity]: Number of units of this product
  const CartProduct({
    required this.productId,
    required this.quantity,
  });

  /// Creates a [CartProduct] from JSON data.
  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
    );
  }

  /// The ID of the product.
  ///
  /// References a [Product.id] from the products endpoint.
  final int productId;

  /// Number of units of this product in the cart.
  final int quantity;

  /// Converts this cart product to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }

  @override
  String toString() =>
      'CartProduct(productId: $productId, quantity: $quantity)';
}

/// Cart model from Fake Store API.
///
/// Represents a shopping cart containing products for a user.
///
/// ## Example
/// ```dart
/// final cart = Cart(
///   id: 1,
///   userId: 1,
///   date: DateTime.now(),
///   products: [
///     CartProduct(productId: 1, quantity: 2),
///     CartProduct(productId: 5, quantity: 1),
///   ],
/// );
/// print('Cart ${cart.id} has ${cart.products.length} items');
/// ```
///
/// ## JSON Structure
/// ```json
/// {
///   "id": 1,
///   "userId": 1,
///   "date": "2020-03-02T00:00:00.000Z",
///   "products": [
///     { "productId": 1, "quantity": 2 },
///     { "productId": 5, "quantity": 1 }
///   ]
/// }
/// ```
///
/// ## Usage Notes
/// - Each cart belongs to a specific user (via [userId])
/// - Products in the cart reference [Product] objects by their ID
/// - The [date] represents when the cart was created/modified
class Cart {
  /// Creates a new [Cart] instance.
  ///
  /// All fields are required.
  const Cart({
    required this.id,
    required this.userId,
    required this.date,
    required this.products,
  });

  /// Creates a [Cart] from JSON data.
  ///
  /// Parses the date from ISO 8601 format and converts products array.
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as int,
      userId: json['userId'] as int,
      date: DateTime.parse(json['date'] as String),
      products: (json['products'] as List<dynamic>)
          .map((e) => CartProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Unique identifier for the cart.
  final int id;

  /// ID of the user who owns this cart.
  ///
  /// References a [User.id] from the users endpoint.
  final int userId;

  /// Date when the cart was created or last modified.
  final DateTime date;

  /// List of products in the cart.
  final List<CartProduct> products;

  /// Converts this cart to a JSON map.
  ///
  /// The date is serialized to ISO 8601 format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'products': products.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'Cart(id: $id, userId: $userId, products: ${products.length})';
}
