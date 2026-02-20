import 'package:flutter_test/flutter_test.dart';
import 'package:tiendita/tiendita.dart';

void main() {
  group('CartProduct', () {
    test('fromJson creates CartProduct correctly', () {
      final json = {'productId': 1, 'quantity': 3};

      final cartProduct = CartProduct.fromJson(json);

      expect(cartProduct.productId, 1);
      expect(cartProduct.quantity, 3);
    });

    test('toJson returns correct map', () {
      const cartProduct = CartProduct(productId: 5, quantity: 2);

      final json = cartProduct.toJson();

      expect(json['productId'], 5);
      expect(json['quantity'], 2);
    });
  });

  group('Cart', () {
    final testJson = {
      'id': 1,
      'userId': 10,
      'date': '2024-01-15T00:00:00.000Z',
      'products': [
        {'productId': 1, 'quantity': 2},
        {'productId': 3, 'quantity': 1},
      ],
    };

    test('fromJson creates Cart correctly', () {
      final cart = Cart.fromJson(testJson);

      expect(cart.id, 1);
      expect(cart.userId, 10);
      expect(cart.date.year, 2024);
      expect(cart.date.month, 1);
      expect(cart.date.day, 15);
      expect(cart.products.length, 2);
      expect(cart.products[0].productId, 1);
      expect(cart.products[0].quantity, 2);
    });

    test('toJson returns correct map', () {
      final cart = Cart(
        id: 1,
        userId: 5,
        date: DateTime(2024, 3, 20),
        products: const [
          CartProduct(productId: 1, quantity: 1),
        ],
      );

      final json = cart.toJson();

      expect(json['id'], 1);
      expect(json['userId'], 5);
      expect(json['products'], isA<List>());
      expect((json['products'] as List).length, 1);
    });

    test('handles empty products list', () {
      final json = {
        'id': 2,
        'userId': 1,
        'date': '2024-02-01T00:00:00.000Z',
        'products': <dynamic>[],
      };

      final cart = Cart.fromJson(json);

      expect(cart.products, isEmpty);
    });

    test('toString returns readable format', () {
      final cart = Cart(
        id: 1,
        userId: 5,
        date: DateTime(2024, 3, 20),
        products: const [
          CartProduct(productId: 1, quantity: 1),
          CartProduct(productId: 2, quantity: 3),
        ],
      );

      expect(cart.toString(), contains('id: 1'));
      expect(cart.toString(), contains('userId: 5'));
      expect(cart.toString(), contains('products: 2'));
    });
  });
}
