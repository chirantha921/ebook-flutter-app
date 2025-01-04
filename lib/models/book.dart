// lib/models/book.dart
import 'package:flutter/material.dart';

class Book {
  final String title;
  final double rating;
  final double? price; // Make price optional
  int reviews;
  int pages = 0;
  String releaseDate;
  String publisher = 'Unknown';
String language;
  String author = 'Unknown';
  String description = 'No description available';
  String image =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGh5WFH8TOIfRKxUrIgJZoDCs1yvQ4hIcppw&s';

  Book({
    required this.title,
    required this.rating,
    this.price, // Remove required keyword
    this.author = 'Unknown',
    this.description = 'No description available',
    this.image =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGh5WFH8TOIfRKxUrIgJZoDCs1yvQ4hIcppw&s',
    this.reviews = 0,
    this.releaseDate = 'Unknown',
    this.pages = 0,
    this.language = 'English',
    this.publisher = 'Unknown',

  });
  factory Book.fromMap(Map<String, dynamic> data) {
    return Book(
      title: data['title'],
      rating: data['rating']?.toDouble() ?? 0.0,
      price: data['price']?.toDouble(),
      author: data['author'],
      image: data['image'],
      pages: data['pages'],
      description: data['description'],
      language: data['language'],
      publisher: data['publisher'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'rating': rating,
      'price': price,
      'image': image,
      'description': description,
      'author':author,
      'language':language,
      'publisher':publisher,
      'pages':pages,
    };
  }
  String get formattedPrice => price?.toStringAsFixed(2) ?? '';

  // get publisher => null;
}

class Genre {
  final String name;
  final List<Color> gradientColors;

  Genre({required this.name, required this.gradientColors});
}

// Sample Data
final List<Book> recommendedBooks = [
  Book(
    title: "The House of Hades (Heroes of Olympus)",
    rating: 4.6,
    price: 7.50,
  ),
  Book(
    title: "My Quiet Blacksmith Life in Another World",
    rating: 4.7,
    price: 6.99,
  ),
  Book(
    title: "Trapped in a Dating Sim",
    rating: 4.9,
    price: 8.99,
  ),
];

final List<Genre> genres = [
  Genre(
    name: "Romance",
    gradientColors: [Colors.pink[300]!, Colors.pink[700]!],
  ),
  Genre(
    name: "Thriller",
    gradientColors: [Colors.red[700]!, Colors.red[900]!],
  ),
  Genre(
    name: "Inspiration",
    gradientColors: [Colors.blue[400]!, Colors.blue[800]!],
  ),
];

final List<Book> purchasedBooks = [
  Book(
    title: "Batman: Arkham Unhinged Vol. 1",
    rating: 4.3,
    price: 0,
  ),
  Book(
    title: "His Dark Materials: The Golden Compass",
    rating: 4.4,
    price: 0,
  ),
];

final List<Book> wishlistBooks = [
  Book(
    title: "Fairy Tale",
    rating: 4.9,
    price: 8.99,
  ),
  Book(
    title: "The Lost Metal",
    rating: 4.7,
    price: 9.99,
  ),
];
