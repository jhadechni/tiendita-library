import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../viewmodels/product_detail_viewmodel.dart';

/// Screen that displays detailed information about a product
class ProductDetailView extends StatefulWidget {
  const ProductDetailView({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late final ProductDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductDetailViewModel();
    _viewModel.loadProduct(widget.productId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_viewModel.state) {
      case ProductDetailState.initial:
      case ProductDetailState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case ProductDetailState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading product',
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
                onPressed: () => _viewModel.loadProduct(widget.productId),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case ProductDetailState.loaded:
        final product = _viewModel.product!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 20,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating.rate}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          ' (${product.rating.count} reviews)',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}
