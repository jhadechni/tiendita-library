import 'package:flutter/foundation.dart';
import 'package:tiendita/tiendita.dart';

/// State for the product detail screen
enum ProductDetailState {
  initial,
  loading,
  loaded,
  error,
}

/// ViewModel for the product detail screen
class ProductDetailViewModel extends ChangeNotifier {
  ProductDetailViewModel({
    ProductRepository? productRepository,
  }) : _productRepository = productRepository ?? ProductRepository();

  final ProductRepository _productRepository;

  ProductDetailState _state = ProductDetailState.initial;
  Product? _product;
  String? _errorMessage;

  // Getters
  ProductDetailState get state => _state;
  Product? get product => _product;
  String? get errorMessage => _errorMessage;

  /// Loads a product by ID
  Future<void> loadProduct(int productId) async {
    _state = ProductDetailState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _productRepository.getProduct(productId);

    switch (result) {
      case Ok(:final value):
        _product = value;
        _state = ProductDetailState.loaded;
      case Error(:final error):
        _errorMessage = error.toString();
        _state = ProductDetailState.error;
    }

    notifyListeners();
  }
}
