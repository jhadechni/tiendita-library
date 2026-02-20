import 'package:flutter/material.dart';

import '../viewmodels/product_list_viewmodel.dart';
import '../widgets/category_filter.dart';
import '../widgets/product_card.dart';
import 'product_detail_view.dart';

/// Main screen that displays a grid of products
class ProductListView extends StatefulWidget {
  const ProductListView({super.key, this.viewModel});

  /// Optional external view model, mainly for widget testing.
  final ProductListViewModel? viewModel;

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  late final ProductListViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? ProductListViewModel();
    _ownsViewModel = widget.viewModel == null;

    if (_viewModel.state == ProductListState.initial) {
      _viewModel.loadProducts();
    }
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiendita'), centerTitle: true),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: _viewModel.refresh,
            child: Column(
              children: [
                if (_viewModel.categories.isNotEmpty)
                  CategoryFilter(
                    categories: _viewModel.categories,
                    selectedCategory: _viewModel.selectedCategory,
                    onCategorySelected: _viewModel.filterByCategory,
                  ),
                Expanded(child: _buildContent()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_viewModel.state) {
      case ProductListState.initial:
      case ProductListState.loading:
        return const Center(child: CircularProgressIndicator());
      case ProductListState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _viewModel.errorMessage ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _viewModel.loadProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case ProductListState.loaded:
        if (_viewModel.products.isEmpty) {
          return const Center(child: Text('No products found'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _viewModel.products.length,
          itemBuilder: (context, index) {
            final product = _viewModel.products[index];
            return ProductCard(
              product: product,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailView(productId: product.id),
                  ),
                );
              },
            );
          },
        );
    }
  }
}
