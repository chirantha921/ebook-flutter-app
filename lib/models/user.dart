import 'book.dart'; // Import Book model

class User {
  final String email;
  final String name;
  final String role;
  final List<Book>? purchasedBooks;
  final List<Book>? wishListBooks;

  User({
    required this.email,
    required this.name,
    required this.role,
    this.purchasedBooks,
    this.wishListBooks,
  });

  // Map serialization for Firebase
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      email: data['email'],
      name: data['name'],
      role: data['role'],
      purchasedBooks: (data['purchasedBooks'] as List<dynamic>?)
          ?.map((bookData) => Book.fromMap(bookData))
          .toList(),
      wishListBooks: (data['wishListBooks'] as List<dynamic>?)
          ?.map((bookData) => Book.fromMap(bookData))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'purchasedBooks':
      purchasedBooks?.map((book) => book.toMap()).toList() ?? [],
      'wishListBooks':
      wishListBooks?.map((book) => book.toMap()).toList() ?? [],
    };
  }
}
