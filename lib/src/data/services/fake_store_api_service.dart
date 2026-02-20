import 'package:dio/dio.dart';

import '../../core/exceptions.dart';
import '../models/auth.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../models/user.dart';

/// Service for interacting with the Fake Store API.
///
/// This is a stateless service that handles all HTTP communication
/// with the [Fake Store API](https://fakestoreapi.com).
///
/// ## Overview
///
/// The Fake Store API provides a RESTful interface for e-commerce operations:
/// - **Products**: CRUD operations for store products
/// - **Carts**: Shopping cart management
/// - **Users**: User account management
/// - **Auth**: User authentication
///
/// ## Usage
///
/// ```dart
/// final service = FakeStoreApiService();
///
/// // Fetch products
/// final products = await service.getProducts(limit: 10);
///
/// // Authenticate user
/// final auth = await service.login(username: 'john', password: 'secret');
/// ```
///
/// ## Error Handling
///
/// All methods throw [TienditaException] subclasses on failure:
/// - [NetworkException]: Connection/timeout errors
/// - [ServerException]: Server-side errors (5xx)
/// - [NotFoundException]: Resource not found (404)
/// - [AuthException]: Authentication failed (401)
///
/// ## API Endpoints
///
/// ### Products
/// | Method | Endpoint | Description |
/// |--------|----------|-------------|
/// | GET | `/products` | Get all products |
/// | GET | `/products/:id` | Get single product |
/// | GET | `/products/categories` | Get all categories |
/// | GET | `/products/category/:name` | Get products by category |
/// | POST | `/products` | Add new product |
/// | PUT | `/products/:id` | Update product (full) |
/// | PATCH | `/products/:id` | Update product (partial) |
/// | DELETE | `/products/:id` | Delete product |
///
/// ### Carts
/// | Method | Endpoint | Description |
/// |--------|----------|-------------|
/// | GET | `/carts` | Get all carts |
/// | GET | `/carts/:id` | Get single cart |
/// | GET | `/carts/user/:userId` | Get user's carts |
/// | POST | `/carts` | Add new cart |
/// | PUT | `/carts/:id` | Update cart (full) |
/// | PATCH | `/carts/:id` | Update cart (partial) |
/// | DELETE | `/carts/:id` | Delete cart |
///
/// ### Users
/// | Method | Endpoint | Description |
/// |--------|----------|-------------|
/// | GET | `/users` | Get all users |
/// | GET | `/users/:id` | Get single user |
/// | POST | `/users` | Add new user |
/// | PUT | `/users/:id` | Update user (full) |
/// | PATCH | `/users/:id` | Update user (partial) |
/// | DELETE | `/users/:id` | Delete user |
///
/// ### Auth
/// | Method | Endpoint | Description |
/// |--------|----------|-------------|
/// | POST | `/auth/login` | User login |
class FakeStoreApiService {
  /// Creates a new [FakeStoreApiService] instance.
  ///
  /// Optionally accepts a custom [Dio] instance for testing or advanced
  /// configuration. If not provided, creates a default instance with:
  /// - Base URL: `https://fakestoreapi.com`
  /// - Connect timeout: 10 seconds
  /// - Receive timeout: 10 seconds
  /// - Content-Type: `application/json`
  FakeStoreApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://fakestoreapi.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'Content-Type': 'application/json',
              },
            ));

  final Dio _dio;

  // ==================== Products ====================

  /// Fetches all products from the API.
  ///
  /// Returns a list of [Product] objects.
  ///
  /// ## Parameters
  /// - [limit]: Maximum number of products to return (optional)
  /// - [sort]: Sort order - `'asc'` or `'desc'` by ID (optional)
  ///
  /// ## Example
  /// ```dart
  /// // Get first 5 products sorted descending
  /// final products = await service.getProducts(limit: 5, sort: 'desc');
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `GET /products`
  /// - Query params: `?limit=5&sort=desc`
  ///
  /// Throws [TienditaException] on failure.
  Future<List<Product>> getProducts({int? limit, String? sort}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _dio.get<List<dynamic>>(
        '/products',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.data!
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetches a single product by its ID.
  ///
  /// Returns a [Product] object.
  ///
  /// ## Parameters
  /// - [id]: The product ID to fetch
  ///
  /// ## Example
  /// ```dart
  /// final product = await service.getProduct(1);
  /// print(product.title); // "Fjallraven - Foldsack No. 1 Backpack"
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `GET /products/:id`
  ///
  /// Throws [NotFoundException] if product doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<Product> getProduct(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/products/$id');
      return Product.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetches all product categories.
  ///
  /// Returns a list of category names as strings.
  ///
  /// ## Example
  /// ```dart
  /// final categories = await service.getCategories();
  /// // ["electronics", "jewelery", "men's clothing", "women's clothing"]
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `GET /products/categories`
  ///
  /// Throws [TienditaException] on failure.
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get<List<dynamic>>('/products/categories');
      return response.data!.map((e) => e as String).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetches all products in a specific category.
  ///
  /// Returns a list of [Product] objects belonging to the category.
  ///
  /// ## Parameters
  /// - [category]: The category name (e.g., `"electronics"`)
  ///
  /// ## Example
  /// ```dart
  /// final electronics = await service.getProductsByCategory('electronics');
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `GET /products/category/:category`
  ///
  /// Throws [TienditaException] on failure.
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/products/category/$category',
      );

      return response.data!
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Creates a new product.
  ///
  /// Returns the created [Product] with a generated ID.
  ///
  /// **Note**: The Fake Store API simulates creation but doesn't persist data.
  /// The returned product will have a new ID but won't appear in subsequent
  /// `getProducts()` calls.
  ///
  /// ## Parameters
  /// - [title]: Product title/name
  /// - [price]: Product price
  /// - [description]: Product description
  /// - [category]: Product category
  /// - [image]: URL to product image
  ///
  /// ## Example
  /// ```dart
  /// final product = await service.addProduct(
  ///   title: 'New Product',
  ///   price: 29.99,
  ///   description: 'A great product',
  ///   category: 'electronics',
  ///   image: 'https://example.com/image.jpg',
  /// );
  /// print(product.id); // 21 (newly generated ID)
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `POST /products`
  /// - Body: `{ title, price, description, category, image }`
  ///
  /// Throws [TienditaException] on failure.
  Future<Product> addProduct({
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/products',
        data: {
          'title': title,
          'price': price,
          'description': description,
          'category': category,
          'image': image,
        },
      );
      return Product.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Updates an existing product (full replacement).
  ///
  /// Replaces all product fields with the provided values.
  /// Returns the updated [Product].
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [productId]: ID of the product to update
  /// - [title]: New product title
  /// - [price]: New product price
  /// - [description]: New product description
  /// - [category]: New product category
  /// - [image]: New product image URL
  ///
  /// ## Example
  /// ```dart
  /// final updated = await service.updateProduct(
  ///   productId: 1,
  ///   title: 'Updated Title',
  ///   price: 39.99,
  ///   description: 'Updated description',
  ///   category: 'electronics',
  ///   image: 'https://example.com/new-image.jpg',
  /// );
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `PUT /products/:id`
  /// - Body: `{ title, price, description, category, image }`
  ///
  /// Throws [NotFoundException] if product doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<Product> updateProduct({
    required int productId,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/products/$productId',
        data: {
          'title': title,
          'price': price,
          'description': description,
          'category': category,
          'image': image,
        },
      );
      return Product.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Partially updates an existing product.
  ///
  /// Only updates the fields that are provided (non-null).
  /// Returns the updated [Product].
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [productId]: ID of the product to update
  /// - [title]: New title (optional)
  /// - [price]: New price (optional)
  /// - [description]: New description (optional)
  /// - [category]: New category (optional)
  /// - [image]: New image URL (optional)
  ///
  /// ## Example
  /// ```dart
  /// // Only update the price
  /// final updated = await service.patchProduct(
  ///   productId: 1,
  ///   price: 49.99,
  /// );
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `PATCH /products/:id`
  /// - Body: `{ ...provided fields }`
  ///
  /// Throws [NotFoundException] if product doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<Product> patchProduct({
    required int productId,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (price != null) data['price'] = price;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;
      if (image != null) data['image'] = image;

      final response = await _dio.patch<Map<String, dynamic>>(
        '/products/$productId',
        data: data,
      );
      return Product.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Deletes a product.
  ///
  /// **Note**: The Fake Store API simulates deletion but doesn't persist data.
  /// The product will still appear in subsequent `getProducts()` calls.
  ///
  /// ## Parameters
  /// - [productId]: ID of the product to delete
  ///
  /// ## Example
  /// ```dart
  /// await service.deleteProduct(1);
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `DELETE /products/:id`
  ///
  /// Throws [NotFoundException] if product doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<void> deleteProduct(int productId) async {
    try {
      await _dio.delete<dynamic>('/products/$productId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== Carts ====================

  /// Fetches all carts from the API.
  ///
  /// Returns a list of [Cart] objects.
  ///
  /// ## Parameters
  /// - [limit]: Maximum number of carts to return (optional)
  /// - [sort]: Sort order - `'asc'` or `'desc'` by ID (optional)
  /// - [startDate]: Filter carts created on or after this date (optional)
  /// - [endDate]: Filter carts created on or before this date (optional)
  ///
  /// ## Example
  /// ```dart
  /// // Get carts from a date range
  /// final carts = await service.getCarts(
  ///   startDate: DateTime(2020, 1, 1),
  ///   endDate: DateTime(2020, 12, 31),
  /// );
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `GET /carts`
  /// - Query params: `?limit=5&sort=desc&startdate=2020-01-01&enddate=2020-12-31`
  ///
  /// Throws [TienditaException] on failure.
  Future<List<Cart>> getCarts({
    int? limit,
    String? sort,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (sort != null) queryParams['sort'] = sort;
      if (startDate != null) {
        queryParams['startdate'] =
            startDate.toIso8601String().split('T').first;
      }
      if (endDate != null) {
        queryParams['enddate'] = endDate.toIso8601String().split('T').first;
      }

      final response = await _dio.get<List<dynamic>>(
        '/carts',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.data!
          .map((json) => Cart.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetches a single cart by its ID.
  ///
  /// Returns a [Cart] object.
  ///
  /// ## Parameters
  /// - [id]: The cart ID to fetch
  ///
  /// ## Example
  /// ```dart
  /// final cart = await service.getCart(1);
  /// print(cart.products.length); // Number of items in cart
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `GET /carts/:id`
  ///
  /// Throws [NotFoundException] if cart doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<Cart> getCart(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/carts/$id');
      return Cart.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetches all carts for a specific user.
  ///
  /// Returns a list of [Cart] objects belonging to the user.
  ///
  /// ## Parameters
  /// - [userId]: The user ID whose carts to fetch
  ///
  /// ## Example
  /// ```dart
  /// final userCarts = await service.getUserCarts(1);
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `GET /carts/user/:userId`
  ///
  /// Throws [TienditaException] on failure.
  Future<List<Cart>> getUserCarts(int userId) async {
    try {
      final response = await _dio.get<List<dynamic>>('/carts/user/$userId');

      return response.data!
          .map((json) => Cart.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Creates a new cart.
  ///
  /// Returns the created [Cart] with a generated ID.
  ///
  /// **Note**: The Fake Store API simulates creation but doesn't persist data.
  ///
  /// ## Parameters
  /// - [userId]: ID of the user who owns the cart
  /// - [products]: List of [CartProduct] items to add
  ///
  /// ## Example
  /// ```dart
  /// final cart = await service.addCart(
  ///   userId: 1,
  ///   products: [
  ///     CartProduct(productId: 1, quantity: 2),
  ///     CartProduct(productId: 5, quantity: 1),
  ///   ],
  /// );
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `POST /carts`
  /// - Body: `{ userId, date, products: [{ productId, quantity }] }`
  ///
  /// Throws [TienditaException] on failure.
  Future<Cart> addCart({
    required int userId,
    required List<CartProduct> products,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/carts',
        data: {
          'userId': userId,
          'date': DateTime.now().toIso8601String(),
          'products': products.map((p) => p.toJson()).toList(),
        },
      );
      return Cart.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Updates an existing cart (full replacement).
  ///
  /// Replaces all cart fields with the provided values.
  /// Returns the updated [Cart].
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [cartId]: ID of the cart to update
  /// - [userId]: New user ID for the cart
  /// - [products]: New list of [CartProduct] items
  ///
  /// ## Example
  /// ```dart
  /// final updated = await service.updateCart(
  ///   cartId: 1,
  ///   userId: 1,
  ///   products: [CartProduct(productId: 3, quantity: 5)],
  /// );
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `PUT /carts/:id`
  /// - Body: `{ userId, date, products: [{ productId, quantity }] }`
  ///
  /// Throws [NotFoundException] if cart doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<Cart> updateCart({
    required int cartId,
    required int userId,
    required List<CartProduct> products,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/carts/$cartId',
        data: {
          'userId': userId,
          'date': DateTime.now().toIso8601String(),
          'products': products.map((p) => p.toJson()).toList(),
        },
      );
      return Cart.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Partially updates an existing cart.
  ///
  /// Only updates the fields that are provided (non-null).
  /// Returns the updated [Cart].
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [cartId]: ID of the cart to update
  /// - [userId]: New user ID (optional)
  /// - [products]: New products list (optional)
  ///
  /// ## Example
  /// ```dart
  /// // Only update the products
  /// final updated = await service.patchCart(
  ///   cartId: 1,
  ///   products: [CartProduct(productId: 2, quantity: 3)],
  /// );
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `PATCH /carts/:id`
  /// - Body: `{ ...provided fields }`
  ///
  /// Throws [NotFoundException] if cart doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<Cart> patchCart({
    required int cartId,
    int? userId,
    List<CartProduct>? products,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (userId != null) data['userId'] = userId;
      if (products != null) {
        data['products'] = products.map((p) => p.toJson()).toList();
      }

      final response = await _dio.patch<Map<String, dynamic>>(
        '/carts/$cartId',
        data: data,
      );
      return Cart.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Deletes a cart.
  ///
  /// **Note**: The Fake Store API simulates deletion but doesn't persist data.
  ///
  /// ## Parameters
  /// - [cartId]: ID of the cart to delete
  ///
  /// ## Example
  /// ```dart
  /// await service.deleteCart(1);
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `DELETE /carts/:id`
  ///
  /// Throws [NotFoundException] if cart doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<void> deleteCart(int cartId) async {
    try {
      await _dio.delete<dynamic>('/carts/$cartId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== Users ====================

  /// Fetches all users from the API.
  ///
  /// Returns a list of [User] objects.
  ///
  /// ## Parameters
  /// - [limit]: Maximum number of users to return (optional)
  /// - [sort]: Sort order - `'asc'` or `'desc'` by ID (optional)
  ///
  /// ## Example
  /// ```dart
  /// final users = await service.getUsers(limit: 5);
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `GET /users`
  /// - Query params: `?limit=5&sort=desc`
  ///
  /// Throws [TienditaException] on failure.
  Future<List<User>> getUsers({int? limit, String? sort}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _dio.get<List<dynamic>>(
        '/users',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.data!
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetches a single user by their ID.
  ///
  /// Returns a [User] object.
  ///
  /// ## Parameters
  /// - [id]: The user ID to fetch
  ///
  /// ## Example
  /// ```dart
  /// final user = await service.getUser(1);
  /// print(user.username); // "johnd"
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `GET /users/:id`
  ///
  /// Throws [NotFoundException] if user doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<User> getUser(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/users/$id');
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Creates a new user.
  ///
  /// Returns the created [User] with a generated ID.
  ///
  /// **Note**: The Fake Store API simulates creation but doesn't persist data.
  ///
  /// ## Parameters
  /// - [email]: User's email address
  /// - [username]: User's username
  /// - [password]: User's password
  /// - [name]: User's name (firstname, lastname)
  /// - [address]: User's address information
  /// - [phone]: User's phone number
  ///
  /// ## Example
  /// ```dart
  /// final user = await service.addUser(
  ///   email: 'john@example.com',
  ///   username: 'johnd',
  ///   password: 'secret123',
  ///   name: Name(firstname: 'John', lastname: 'Doe'),
  ///   address: Address(
  ///     city: 'New York',
  ///     street: '5th Avenue',
  ///     number: 123,
  ///     zipcode: '10001',
  ///     geolocation: Geolocation(lat: '40.7128', long: '-74.0060'),
  ///   ),
  ///   phone: '1-555-1234',
  /// );
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `POST /users`
  /// - Body: `{ email, username, password, name, address, phone }`
  ///
  /// Throws [TienditaException] on failure.
  Future<User> addUser({
    required String email,
    required String username,
    required String password,
    required Name name,
    required Address address,
    required String phone,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/users',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'name': name.toJson(),
          'address': address.toJson(),
          'phone': phone,
        },
      );
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Updates an existing user (full replacement).
  ///
  /// Replaces all user fields with the provided values.
  /// Returns the updated [User].
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [userId]: ID of the user to update
  /// - [email]: New email address
  /// - [username]: New username
  /// - [password]: New password
  /// - [name]: New name information
  /// - [address]: New address information
  /// - [phone]: New phone number
  ///
  /// ## Example
  /// ```dart
  /// final updated = await service.updateUser(
  ///   userId: 1,
  ///   email: 'newemail@example.com',
  ///   username: 'johnd',
  ///   password: 'newpassword',
  ///   name: Name(firstname: 'John', lastname: 'Smith'),
  ///   address: existingAddress,
  ///   phone: '1-555-5678',
  /// );
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `PUT /users/:id`
  /// - Body: `{ email, username, password, name, address, phone }`
  ///
  /// Throws [NotFoundException] if user doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<User> updateUser({
    required int userId,
    required String email,
    required String username,
    required String password,
    required Name name,
    required Address address,
    required String phone,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/users/$userId',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'name': name.toJson(),
          'address': address.toJson(),
          'phone': phone,
        },
      );
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Partially updates an existing user.
  ///
  /// Only updates the fields that are provided (non-null).
  /// Returns the updated [User].
  ///
  /// **Note**: The Fake Store API simulates updates but doesn't persist data.
  ///
  /// ## Parameters
  /// - [userId]: ID of the user to update
  /// - [email]: New email (optional)
  /// - [username]: New username (optional)
  /// - [password]: New password (optional)
  /// - [name]: New name (optional)
  /// - [address]: New address (optional)
  /// - [phone]: New phone (optional)
  ///
  /// ## Example
  /// ```dart
  /// // Only update the email
  /// final updated = await service.patchUser(
  ///   userId: 1,
  ///   email: 'updated@example.com',
  /// );
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `PATCH /users/:id`
  /// - Body: `{ ...provided fields }`
  ///
  /// Throws [NotFoundException] if user doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<User> patchUser({
    required int userId,
    String? email,
    String? username,
    String? password,
    Name? name,
    Address? address,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (email != null) data['email'] = email;
      if (username != null) data['username'] = username;
      if (password != null) data['password'] = password;
      if (name != null) data['name'] = name.toJson();
      if (address != null) data['address'] = address.toJson();
      if (phone != null) data['phone'] = phone;

      final response = await _dio.patch<Map<String, dynamic>>(
        '/users/$userId',
        data: data,
      );
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Deletes a user.
  ///
  /// **Note**: The Fake Store API simulates deletion but doesn't persist data.
  ///
  /// ## Parameters
  /// - [userId]: ID of the user to delete
  ///
  /// ## Example
  /// ```dart
  /// await service.deleteUser(1);
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `DELETE /users/:id`
  ///
  /// Throws [NotFoundException] if user doesn't exist.
  /// Throws [TienditaException] on other failures.
  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete<dynamic>('/users/$userId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== Auth ====================

  /// Authenticates a user and returns a JWT token.
  ///
  /// Returns a [LoginResponse] containing the authentication token.
  ///
  /// ## Parameters
  /// - [username]: The user's username
  /// - [password]: The user's password
  ///
  /// ## Example
  /// ```dart
  /// final response = await service.login(
  ///   username: 'johnd',
  ///   password: 'm38rmF$',
  /// );
  /// print(response.token); // JWT token string
  /// ```
  ///
  /// ## API Reference
  /// - Endpoint: `POST /auth/login`
  /// - Body: `{ username, password }`
  ///
  /// ## Available Test Users
  /// You can use any user from `getUsers()`. Example credentials:
  /// - username: `johnd`, password: `m38rmF$`
  /// - username: `mor_2314`, password: `83r5^_`
  ///
  /// Throws [AuthException] if credentials are invalid.
  /// Throws [TienditaException] on other failures.
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      return LoginResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== Error Handling ====================

  /// Converts [DioException] to appropriate [TienditaException] subclass.
  TienditaException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const AuthException('Invalid credentials');
        }
        if (statusCode == 404) {
          return const NotFoundException('Resource not found');
        }
        return ServerException(
          e.response?.statusMessage ?? 'Server error',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');
      default:
        return NetworkException(
          e.message ?? 'Unknown error',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
