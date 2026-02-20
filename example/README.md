# Tiendita Example App

A complete Flutter application demonstrating how to use the **tiendita** package.

## Features Demonstrated

- **Product Listing**: Displays products in a responsive grid layout
- **Category Filtering**: Filter products by category using chips
- **Pull-to-Refresh**: Refresh product data with a swipe gesture
- **Product Details**: View full product information
- **Error Handling**: Graceful error display with retry functionality
- **MVVM Architecture**: Clean separation using `ChangeNotifier` for state management

## Running the Example

### Prerequisites

- Flutter SDK >= 3.18.0
- Dart SDK >= 3.11.0

### Steps

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Running on Specific Platforms

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Chrome (Web)
flutter run -d chrome

# macOS
flutter run -d macos
```

## Project Structure

```
example/
├── lib/
│   ├── main.dart                           # App entry point
│   └── features/
│       └── products/
│           └── presentation/
│               ├── view_models/
│               │   ├── product_list_view_model.dart
│               │   └── product_detail_view_model.dart
│               ├── views/
│               │   ├── product_list_view.dart
│               │   └── product_detail_view.dart
│               └── widgets/
│                   ├── product_card.dart
│                   └── category_filter.dart
└── pubspec.yaml
```

## Architecture Overview

### MVVM Pattern

The example uses the Model-View-ViewModel (MVVM) pattern:

- **Models**: From the tiendita package (`Product`, `Cart`, etc.)
- **Views**: Flutter widgets that display UI (`ProductListView`, `ProductDetailView`)
- **ViewModels**: `ChangeNotifier` classes that manage state and business logic

### State Management

ViewModels use a simple state enum pattern:

```dart
enum ProductListState {
  initial,
  loading,
  loaded,
  error,
}

class ProductListViewModel extends ChangeNotifier {
  ProductListState _state = ProductListState.initial;

  // State changes trigger UI updates via notifyListeners()
}
```

### Usage in Views

```dart
ListenableBuilder(
  listenable: viewModel,
  builder: (context, _) {
    return switch (viewModel.state) {
      ProductListState.loading => const CircularProgressIndicator(),
      ProductListState.loaded => ProductGrid(products: viewModel.products),
      ProductListState.error => ErrorWidget(onRetry: viewModel.loadProducts),
      _ => const SizedBox.shrink(),
    };
  },
)
```

## Key Code Examples

### Initializing the Repository

```dart
// In ViewModel
final _productRepository = ProductRepository();

Future<void> loadProducts() async {
  _state = ProductListState.loading;
  notifyListeners();

  final result = await _productRepository.getProducts();

  switch (result) {
    case Ok(:final value):
      _products = value;
      _state = ProductListState.loaded;
    case Error(:final error):
      _errorMessage = error.toString();
      _state = ProductListState.error;
  }
  notifyListeners();
}
```

### Filtering by Category

```dart
Future<void> filterByCategory(String? category) async {
  _selectedCategory = category;
  _state = ProductListState.loading;
  notifyListeners();

  final Result<List<Product>> result;
  if (category == null) {
    result = await _productRepository.getProducts();
  } else {
    result = await _productRepository.getProductsByCategory(category);
  }

  // Handle result...
}
```

### Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () => viewModel.refresh(),
  child: GridView.builder(...),
)
```

## Dependencies

- **tiendita**: The main package (local path dependency)
- **cached_network_image**: Efficient image loading with caching
- **cupertino_icons**: iOS-style icons
