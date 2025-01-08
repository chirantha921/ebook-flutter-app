// lib/models/book.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Book {
  String bookId;
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
  String image = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGh5WFH8TOIfRKxUrIgJZoDCs1yvQ4hIcppw&s';
  double progress;
  String currentChapter;
  String lastRead;

  @override
  String toString() {
    return 'Book(title: $title, rating: $rating)';
  }

  Book({
    required this.title,
    required this.rating,
    this.bookId = '',
    this.price, // Remove required keyword
    this.author = 'Unknown',
    this.description = 'No description available',
    this.image = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGh5WFH8TOIfRKxUrIgJZoDCs1yvQ4hIcppw&s',
    this.reviews = 0,
    this.releaseDate = 'Unknown',
    this.pages = 0,
    this.language = 'English',
    this.publisher = 'Unknown',
    this.progress = 0,
    this.currentChapter = "None",
    this.lastRead = "Now",
  });

  factory Book.fromMap(Map<String, dynamic> data) {
    return Book(
      title: data['title'] as String,
      rating: data['rating']?.toDouble() ?? 0.0,
      price: data['price']?.toDouble(),
      author: data['author']  as String,
      image: data['image'] as String,
      pages: data['pages'] as int,
      description: data['description'] as String,
      language: data['language'] as String,
      publisher: data['publisher'] as String,
      progress: data['progress'] as double,
      currentChapter: data['currentChapter'] as String,
      lastRead: data['lastRead'] as String,
    );
  }

  factory Book.fromFireStore(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Book(
      bookId: doc.id,
      title: data['title'] ?? '',
      rating: data['rating']?.toDouble() ?? 0.0,
      price: data['price']?.toDouble()?? 0.0,
      author: data['author'] ?? '',
      image: data['image'] ?? '',
      pages: data['pages'] ?? '',
      description: data['description'] ?? '',
      language: data['language'] ?? '',
      publisher: data['publisher'] ?? '',
      progress: data['progress']?.toDouble() ?? 0.0,
      currentChapter: data['currentChapter'] ?? '',
      lastRead: data['lastRead'] ?? '',
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
      'progress':progress,
      'currentChapter':currentChapter,
      'lastRead':lastRead,
    };
  }
  String get formattedPrice => price?.toStringAsFixed(2) ?? '';

  // get publisher => null;
  // From JSON constructor
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      image: json['image'] ?? '',
      pages: json['pages'] ?? 0,
      releaseDate: json['releaseDate'] ?? '',
      price: (json['price'] != null) ? json['price'].toDouble() : 0.0,
      author: json['author'] ?? '',
      rating: (json['rating'] != null) ? json['rating'].toDouble() : 0.0,
      publisher: json['publisher'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? '',
      title: json['title'] ?? '',
      progress: json['progress'] ?? 0,
      currentChapter: json['currentChapter'] ?? '',
      lastRead: json['lastRead'] ?? '',
    );
  }

  
  Map<String, dynamic> toJson() {
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
      'progress':progress,
      'currentChapter':currentChapter,
      'lastRead':lastRead,
    };
  }
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
