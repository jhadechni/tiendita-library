import 'package:flutter_test/flutter_test.dart';
import 'package:tiendita/tiendita.dart';

void main() {
  group('Rating', () {
    test('fromJson creates Rating correctly', () {
      final json = {'rate': 4.5, 'count': 120};

      final rating = Rating.fromJson(json);

      expect(rating.rate, 4.5);
      expect(rating.count, 120);
    });

    test('fromJson handles integer rate', () {
      final json = {'rate': 4, 'count': 100};

      final rating = Rating.fromJson(json);

      expect(rating.rate, 4.0);
      expect(rating.count, 100);
    });

    test('toJson returns correct map', () {
      const rating = Rating(rate: 3.9, count: 50);

      final json = rating.toJson();

      expect(json['rate'], 3.9);
      expect(json['count'], 50);
    });
  });

  group('Product', () {
    const testJson = {
      'id': 1,
      'title': 'Test Product',
      'price': 19.99,
      'description': 'A test product description',
      'category': 'electronics',
      'image': 'https://example.com/image.jpg',
      'rating': {'rate': 4.2, 'count': 200},
    };

    test('fromJson creates Product correctly', () {
      final product = Product.fromJson(testJson);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.price, 19.99);
      expect(product.description, 'A test product description');
      expect(product.category, 'electronics');
      expect(product.image, 'https://example.com/image.jpg');
      expect(product.rating.rate, 4.2);
      expect(product.rating.count, 200);
    });

    test('fromJson handles integer price', () {
      final json = Map<String, dynamic>.from(testJson);
      json['price'] = 20;

      final product = Product.fromJson(json);

      expect(product.price, 20.0);
    });

    test('toJson returns correct map', () {
      const product = Product(
        id: 1,
        title: 'Test',
        price: 9.99,
        description: 'Desc',
        category: 'test',
        image: 'url',
        rating: Rating(rate: 5.0, count: 10),
      );

      final json = product.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test');
      expect(json['price'], 9.99);
      expect(json['rating']['rate'], 5.0);
    });

    test('toString returns readable format', () {
      const product = Product(
        id: 1,
        title: 'Test',
        price: 9.99,
        description: 'Desc',
        category: 'test',
        image: 'url',
        rating: Rating(rate: 5.0, count: 10),
      );

      expect(product.toString(), contains('id: 1'));
      expect(product.toString(), contains('title: Test'));
    });
  });
}
