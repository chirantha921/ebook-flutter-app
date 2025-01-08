import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../utils/constants.dart'; // Update import path as needed
import 'package:ebook_app/models/book.dart';

import '../book/book_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Sample wishlist data
  List<Book> wishlistBooks = [];

  Future<void> getUserWishList() async {
    try {
      final userDocId = firebase_auth.FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID

      if (userDocId == null) {
        print("No user is signed in");
        setState(() {
          isLoadingWishListBooks = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('User').doc(userDocId).get();
      print("User document fetched for wishlist");

      if (userDoc.exists) {
        final List<dynamic> wishListBooksFromDB = userDoc['wishListBooks'] ?? [];
        print("Wishlist books from DB: ${wishListBooksFromDB.length}");

        // Clearing the whole list to ensure no other user's data and duplicates from being in the list
        setState(() {
          wishlistBooks.clear();
        });

        // Iterate through the wishlist books list
        for (var bookRef in wishListBooksFromDB) {
          if (bookRef is DocumentReference) {
            final bookSnapshot = await bookRef.get();
            if (bookSnapshot.exists) {
              final bookData = bookSnapshot.data() as Map<String, dynamic>;

              // Creating the book object based on the data fetched from user's wishlist
              final book = Book(
                bookId: bookRef.id,
                title: bookData['title'] ?? 'Unknown Title',
                rating: bookData['rating'] ?? 0,
                price: bookData['price'],
                image: bookData['image'] ?? '',
                description: bookData['description'] ?? '',
                author: bookData['author'] ?? 'Unknown',
                reviews: bookData['reviews'] ?? 0,
                releaseDate: bookData['releaseDate'] ?? 'Unknown',
                language: bookData['language'] ?? 'English',
                publisher: bookData['publisher'] ?? 'Unknown',
                pages: bookData['pages'] ?? 0,
              );

              // Checking whether the books are there for now
              print('Wishlist Book Title: ${book.title}');
              print('Author: ${book.author}');
              print('Rating: ${book.rating}');
              print('Price: ${book.price}');
              print('Description: ${book.description}');
              print('Release Date: ${book.releaseDate}');
              print('Language: ${book.language}');
              print('Publisher: ${book.publisher}');
              print('Pages: ${book.pages}');
              print('---'); // Add separator between books

              // Adding the book object created into the book list
              wishlistBooks.add(book);
            }
          } else {
            print('Invalid book reference found in wishlist');
          }
        }

        setState(() {
          isLoadingWishListBooks = false; // Data is loaded, stop loading
        });
      } else {
        print('User document not found!');
        setState(() {
          isLoadingWishListBooks = false;
        });
      }
    } catch (e) {
      print('Error fetching wishlistBooks: $e');
      setState(() {
        isLoadingWishListBooks = false;
      });
    }
  }

  bool isLoadingWishListBooks = true;
  @override
  void initState() {
    super.initState();
    // Fetch the wishlist data from Firestore
    getUserWishList();
  }

  void _showBookMenu(int index) async {
    final selectedAction = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheetAction(
                  icon: Icons.delete_outline,
                  label: 'Remove from Wishlist',
                  onTap: () {
                    Navigator.pop(context, 'remove');
                  },
                ),
                const SizedBox(height: 16),
                _buildBottomSheetAction(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    Navigator.pop(context, 'share');
                  },
                ),
                const SizedBox(height: 16),
                _buildBottomSheetAction(
                  icon: Icons.info_outline_rounded,
                  label: 'About Ebook',
                  onTap: () {
                    Navigator.pop(context, 'about');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedAction == 'remove') {
      final bookRemove = wishlistBooks[index];

      try{
        final userDoc = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
        if(userDoc == null){
          print("The user need to be signed in to remove the book from the wishlist");
          return;
        }

        final bookRef = FirebaseFirestore.instance.collection('Book').doc(bookRemove.bookId);

        final userDocRef = FirebaseFirestore.instance.collection('User').doc(userDoc);
        await userDocRef.update({
          'wishListBooks' : FieldValue.arrayRemove([bookRef])
        });
      }catch(e){
        print("Error while removing book from wishListBooks in user $e");
      }
      setState(() {
        wishlistBooks.removeAt(index);
      });
    } else if (selectedAction == 'share') {
      // Implement share logic
    } else if (selectedAction == 'about') {
      final Book book = wishlistBooks[index];
      // Implement about logic
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookDetailsScreen(
              book:{
                'title': book.title,
                'author': book.author,
                'imageUrl': book.image,
                'rating': book.rating,
                'reviewCount': book.reviews,
                'description': book.description,
                'genre': book.genre,
                'publisher': book.publisher,
                'language': book.language,
                'pages': book.pages,
                'releaseDate': book.releaseDate,
              }
          )
          )
      );
    }
  }

  void _showAboutBook(String description) async {
    final selectedAction = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSectionTitle("About the Book"),
                TextFormField(
                  initialValue: description,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBottomSheetAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final appBarHeight = kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      // If you have a bottom nav bar in your main app, you can remove it here or integrate as needed.
      // bottomNavigationBar: BottomNavigationBar(...),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: isDesktop ? 24.0 : 16.0,
        leading: Padding(
          padding: EdgeInsets.only(left: isDesktop ? 24.0 : 16.0),
          child: Icon(Icons.menu_book, color: AppColors.primary, size: 28),
        ),
        title: Text(
          'Wishlist',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {
              // Implement filter functionality
            },
          ),
          SizedBox(width: isDesktop ? 24 : 16),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24.0 : 16.0,
          vertical: isDesktop ? 24.0 : 16.0,
        ),
        child: ListView.separated(
          itemCount: wishlistBooks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final book = wishlistBooks[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    book.image,
                    width: isDesktop ? 120 : 80,
                    height: isDesktop ? 180 : 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      width: isDesktop ? 120 : 80,
                      height: isDesktop ? 180 : 120,
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book title
                      Text(
                        book.title,
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            book.rating.toStringAsFixed(1),
                            style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Price
                      Text(
                        "\$${book.price?.toStringAsFixed(2)}",
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onPressed: () => _showBookMenu(index),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
