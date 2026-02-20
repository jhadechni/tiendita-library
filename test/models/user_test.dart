import 'package:flutter_test/flutter_test.dart';
import 'package:tiendita/tiendita.dart';

void main() {
  group('Geolocation', () {
    test('fromJson creates Geolocation correctly', () {
      final json = {'lat': '-37.3159', 'long': '81.1496'};

      final geo = Geolocation.fromJson(json);

      expect(geo.lat, '-37.3159');
      expect(geo.long, '81.1496');
    });

    test('toJson returns correct map', () {
      const geo = Geolocation(lat: '40.7128', long: '-74.0060');

      final json = geo.toJson();

      expect(json['lat'], '40.7128');
      expect(json['long'], '-74.0060');
    });

    test('toString returns readable format', () {
      const geo = Geolocation(lat: '40.7128', long: '-74.0060');

      expect(geo.toString(), contains('lat: 40.7128'));
      expect(geo.toString(), contains('long: -74.0060'));
    });
  });

  group('Address', () {
    final testAddressJson = {
      'city': 'kilcoole',
      'street': 'new road',
      'number': 7682,
      'zipcode': '12926-3874',
      'geolocation': {'lat': '-37.3159', 'long': '81.1496'},
    };

    test('fromJson creates Address correctly', () {
      final address = Address.fromJson(testAddressJson);

      expect(address.city, 'kilcoole');
      expect(address.street, 'new road');
      expect(address.number, 7682);
      expect(address.zipcode, '12926-3874');
      expect(address.geolocation.lat, '-37.3159');
      expect(address.geolocation.long, '81.1496');
    });

    test('toJson returns correct map', () {
      const address = Address(
        city: 'New York',
        street: '5th Avenue',
        number: 123,
        zipcode: '10001',
        geolocation: Geolocation(lat: '40.7128', long: '-74.0060'),
      );

      final json = address.toJson();

      expect(json['city'], 'New York');
      expect(json['street'], '5th Avenue');
      expect(json['number'], 123);
      expect(json['zipcode'], '10001');
      expect(json['geolocation']['lat'], '40.7128');
    });

    test('toString returns readable format', () {
      const address = Address(
        city: 'New York',
        street: '5th Avenue',
        number: 123,
        zipcode: '10001',
        geolocation: Geolocation(lat: '40.7128', long: '-74.0060'),
      );

      expect(address.toString(), contains('city: New York'));
      expect(address.toString(), contains('street: 5th Avenue'));
      expect(address.toString(), contains('number: 123'));
    });
  });

  group('Name', () {
    test('fromJson creates Name correctly', () {
      final json = {'firstname': 'john', 'lastname': 'doe'};

      final name = Name.fromJson(json);

      expect(name.firstname, 'john');
      expect(name.lastname, 'doe');
    });

    test('toJson returns correct map', () {
      const name = Name(firstname: 'Jane', lastname: 'Smith');

      final json = name.toJson();

      expect(json['firstname'], 'Jane');
      expect(json['lastname'], 'Smith');
    });

    test('toString returns readable format', () {
      const name = Name(firstname: 'John', lastname: 'Doe');

      expect(name.toString(), contains('firstname: John'));
      expect(name.toString(), contains('lastname: Doe'));
    });
  });

  group('User', () {
    final testUserJson = {
      'id': 1,
      'email': 'john@gmail.com',
      'username': 'johnd',
      'password': 'm38rmF\$',
      'name': {'firstname': 'john', 'lastname': 'doe'},
      'address': {
        'geolocation': {'lat': '-37.3159', 'long': '81.1496'},
        'city': 'kilcoole',
        'street': 'new road',
        'number': 7682,
        'zipcode': '12926-3874',
      },
      'phone': '1-570-236-7033',
    };

    test('fromJson creates User correctly', () {
      final user = User.fromJson(testUserJson);

      expect(user.id, 1);
      expect(user.email, 'john@gmail.com');
      expect(user.username, 'johnd');
      expect(user.password, 'm38rmF\$');
      expect(user.name.firstname, 'john');
      expect(user.name.lastname, 'doe');
      expect(user.address.city, 'kilcoole');
      expect(user.address.street, 'new road');
      expect(user.address.number, 7682);
      expect(user.address.zipcode, '12926-3874');
      expect(user.address.geolocation.lat, '-37.3159');
      expect(user.phone, '1-570-236-7033');
    });

    test('toJson returns correct map', () {
      const user = User(
        id: 1,
        email: 'test@example.com',
        username: 'testuser',
        password: 'secret',
        name: Name(firstname: 'Test', lastname: 'User'),
        address: Address(
          city: 'Test City',
          street: 'Test Street',
          number: 1,
          zipcode: '12345',
          geolocation: Geolocation(lat: '0', long: '0'),
        ),
        phone: '123-456-7890',
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['email'], 'test@example.com');
      expect(json['username'], 'testuser');
      expect(json['password'], 'secret');
      expect(json['name']['firstname'], 'Test');
      expect(json['name']['lastname'], 'User');
      expect(json['address']['city'], 'Test City');
      expect(json['phone'], '123-456-7890');
    });

    test('toString returns readable format', () {
      const user = User(
        id: 1,
        email: 'test@example.com',
        username: 'testuser',
        password: 'secret',
        name: Name(firstname: 'Test', lastname: 'User'),
        address: Address(
          city: 'Test City',
          street: 'Test Street',
          number: 1,
          zipcode: '12345',
          geolocation: Geolocation(lat: '0', long: '0'),
        ),
        phone: '123-456-7890',
      );

      expect(user.toString(), contains('id: 1'));
      expect(user.toString(), contains('username: testuser'));
      expect(user.toString(), contains('email: test@example.com'));
    });
  });
}
