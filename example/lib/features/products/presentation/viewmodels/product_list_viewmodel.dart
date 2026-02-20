import 'package:flutter/foundation.dart';
import 'package:tiendita/tiendita.dart';

/// State for the product list screen
enum ProductListState {
  initial,
  loading,
  loaded,
  error,
}

/// ViewModel for the product list screen
///
/// Manages the state and business logic for displaying products.
class ProductListViewModel extends ChangeNotifier {
  ProductListViewModel({
    ProductRepository? productRepository,
  }) : _productRepository = productRepository ?? ProductRepository();

  final ProductRepository _productRepository;

  ProductListState _state = ProductListState.initial;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String? _selectedCategory;
  String? _errorMessage;

  // Getters
  ProductListState get state => _state;
  List<Product> get products => _filteredProducts;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;

  /// Loads all products and categories
  Future<void> loadProducts() async {
    _state = ProductListState.loading;
    _errorMessage = null;
    notifyListeners();

    // Fetch products and categories in parallel
    final results = await Future.wait([
      _productRepository.getProducts(),
      _productRepository.getCategories(),
    ]);

    final productsResult = results[0] as Result<List<Product>>;
    final categoriesResult = results[1] as Result<List<String>>;

    switch (productsResult) {
      case Ok(:final value):
        _products = value;
        _filteredProducts = value;
      case Error(:final error):
        _state = ProductListState.error;
        _errorMessage = error.toString();
        notifyListeners();
        return;
    }

    switch (categoriesResult) {
      case Ok(:final value):
        _categories = value;
      case Error(:final error):
        // Categories are optional, don't fail if they don't load
        debugPrint('Failed to load categories: $error');
    }

    _state = ProductListState.loaded;
    notifyListeners();
  }

  /// Filters products by category
  Future<void> filterByCategory(String? category) async {
    _selectedCategory = category;

    if (category == null) {
      _filteredProducts = _products;
      notifyListeners();
      return;
    }

    _state = ProductListState.loading;
    notifyListeners();

    final result = await _productRepository.getProductsByCategory(category);

    switch (result) {
      case Ok(:final value):
        _filteredProducts = value;
        _state = ProductListState.loaded;
      case Error(:final error):
        _errorMessage = error.toString();
        _state = ProductListState.error;
    }

    notifyListeners();
  }

  /// Refreshes the product list
  Future<void> refresh() async {
    _selectedCategory = null;
    _productRepository.clearCache();
    await loadProducts();
  }
}
