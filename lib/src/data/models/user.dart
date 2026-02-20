/// Geolocation data for an address.
///
/// Represents latitude and longitude coordinates.
///
/// ## Example
/// ```dart
/// final geo = Geolocation(lat: '40.7128', long: '-74.0060');
/// ```
///
/// ## JSON Structure
/// ```json
/// {
///   "lat": "-37.3159",
///   "long": "81.1496"
/// }
/// ```
///
/// ## Note
/// The API returns coordinates as strings, not numbers.
class Geolocation {
  /// Creates a new [Geolocation] instance.
  ///
  /// - [lat]: Latitude as a string
  /// - [long]: Longitude as a string
  const Geolocation({
    required this.lat,
    required this.long,
  });

  /// Creates a [Geolocation] from JSON data.
  factory Geolocation.fromJson(Map<String, dynamic> json) {
    return Geolocation(
      lat: json['lat'] as String,
      long: json['long'] as String,
    );
  }

  /// Latitude coordinate as a string.
  final String lat;

  /// Longitude coordinate as a string.
  final String long;

  /// Converts this geolocation to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'long': long,
    };
  }

  @override
  String toString() => 'Geolocation(lat: $lat, long: $long)';
}

/// Address information for a user.
///
/// Contains the user's physical address including geolocation.
///
/// ## Example
/// ```dart
/// final address = Address(
///   city: 'New York',
///   street: '5th Avenue',
///   number: 123,
///   zipcode: '10001',
///   geolocation: Geolocation(lat: '40.7128', long: '-74.0060'),
/// );
/// ```
///
/// ## JSON Structure
/// ```json
/// {
///   "geolocation": {
///     "lat": "-37.3159",
///     "long": "81.1496"
///   },
///   "city": "kilcoole",
///   "street": "new road",
///   "number": 7682,
///   "zipcode": "12926-3874"
/// }
/// ```
class Address {
  /// Creates a new [Address] instance.
  ///
  /// All fields are required.
  const Address({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
    required this.geolocation,
  });

  /// Creates an [Address] from JSON data.
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: json['city'] as String,
      street: json['street'] as String,
      number: json['number'] as int,
      zipcode: json['zipcode'] as String,
      geolocation:
          Geolocation.fromJson(json['geolocation'] as Map<String, dynamic>),
    );
  }

  /// City name.
  final String city;

  /// Street name.
  final String street;

  /// Street/building number.
  final int number;

  /// Postal/ZIP code.
  final String zipcode;

  /// Geographic coordinates.
  final Geolocation geolocation;

  /// Converts this address to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'street': street,
      'number': number,
      'zipcode': zipcode,
      'geolocation': geolocation.toJson(),
    };
  }

  @override
  String toString() =>
      'Address(city: $city, street: $street, number: $number)';
}

/// Name information for a user.
///
/// Contains the user's first and last name.
///
/// ## Example
/// ```dart
/// final name = Name(firstname: 'John', lastname: 'Doe');
/// print('${name.firstname} ${name.lastname}'); // "John Doe"
/// ```
///
/// ## JSON Structure
/// ```json
/// {
///   "firstname": "john",
///   "lastname": "doe"
/// }
/// ```
class Name {
  /// Creates a new [Name] instance.
  ///
  /// - [firstname]: User's first name
  /// - [lastname]: User's last name
  const Name({
    required this.firstname,
    required this.lastname,
  });

  /// Creates a [Name] from JSON data.
  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
    );
  }

  /// User's first name.
  final String firstname;

  /// User's last name.
  final String lastname;

  /// Converts this name to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
    };
  }

  @override
  String toString() => 'Name(firstname: $firstname, lastname: $lastname)';
}

/// User model from Fake Store API.
///
/// Represents a user account in the store system.
///
/// ## Example
/// ```dart
/// final user = User(
///   id: 1,
///   email: 'john@example.com',
///   username: 'johnd',
///   password: 'secret123',
///   name: Name(firstname: 'John', lastname: 'Doe'),
///   address: Address(...),
///   phone: '1-555-1234',
/// );
/// ```
///
/// ## JSON Structure
/// ```json
/// {
///   "id": 1,
///   "email": "john@gmail.com",
///   "username": "johnd",
///   "password": "m38rmF$",
///   "name": {
///     "firstname": "john",
///     "lastname": "doe"
///   },
///   "address": {
///     "geolocation": { "lat": "-37.3159", "long": "81.1496" },
///     "city": "kilcoole",
///     "street": "new road",
///     "number": 7682,
///     "zipcode": "12926-3874"
///   },
///   "phone": "1-570-236-7033"
/// }
/// ```
///
/// ## Authentication
/// Use the [username] and [password] fields with the login endpoint
/// to authenticate and receive a JWT token.
///
/// ## Test Credentials
/// Example users from the API:
/// - username: `johnd`, password: `m38rmF$`
/// - username: `mor_2314`, password: `83r5^_`
class User {
  /// Creates a new [User] instance.
  ///
  /// All fields are required.
  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    required this.name,
    required this.address,
    required this.phone,
  });

  /// Creates a [User] from JSON data.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      name: Name.fromJson(json['name'] as Map<String, dynamic>),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      phone: json['phone'] as String,
    );
  }

  /// Unique identifier for the user.
  final int id;

  /// User's email address.
  final String email;

  /// User's unique username for authentication.
  final String username;

  /// User's password.
  ///
  /// **Note**: In production, passwords should never be stored or
  /// transmitted in plain text. The Fake Store API is for demo purposes.
  final String password;

  /// User's full name.
  final Name name;

  /// User's physical address.
  final Address address;

  /// User's phone number.
  final String phone;

  /// Converts this user to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password': password,
      'name': name.toJson(),
      'address': address.toJson(),
      'phone': phone,
    };
  }

  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';
}
