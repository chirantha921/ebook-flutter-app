import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class PurchasedScreen extends StatefulWidget {
  const PurchasedScreen({Key? key}) : super(key: key);

  @override
  State<PurchasedScreen> createState() => _PurchasedScreenState();
}

class _PurchasedScreenState extends State<PurchasedScreen> {
  bool isGridView = true;

  // Sample purchased books data with reading progress
  final List<Map<String, dynamic>> purchasedBooks = [
    {
      "book": Book(
        title: "Batman: Arkham Unhinged Vol. 1",
        rating: 4.3,
        price: 0,
      ),
      "progress": 0.75,
      "lastRead": "2 hours ago",
      "currentChapter": "Chapter 15 of 20",
    },
    {
      "book": Book(
        title: "His Dark Materials: The Golden Compass",
        rating: 4.4,
        price: 0,
      ),
      "progress": 0.45,
      "lastRead": "Yesterday",
      "currentChapter": "Chapter 8 of 24",
    },
    {
      "book": Book(
        title: "Project Hail Mary",
        rating: 4.8,
        price: 0,
      ),
      "progress": 0.2,
      "lastRead": "3 days ago",
      "currentChapter": "Chapter 4 of 32",
    },
  ];

  /* Future<void> getUserPurchaseBookList() async {
    try {
      final userDocId = firebase_auth.FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID

      if (userDocId == null) {
        print("No user is signed in");
        setState(() {
          isLoadingPurchasedBooks = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('User').doc(userDocId).get();
      print("User document fetched");

      if (userDoc.exists) {
        final List<dynamic> purchasedBooksFromDB = userDoc['purchasedBooks'] ?? [];
        print("Purchased books from DB: ${purchasedBooksFromDB.length}");

        // If there are no books it will stop
        if (purchasedBooksFromDB.isEmpty) {
          setState(() {
            isLoadingPurchasedBooks = false;
          });
          return;
        }

        final List<Book> books = [];
        for (var bookRef in purchasedBooksFromDB) {
          if (bookRef is DocumentReference) {
            final bookSnapshot = await bookRef.get();
            if (bookSnapshot.exists) {
              final bookData = bookSnapshot.data() as Map<String, dynamic>;

              //Creating a book object with values fetched from the firebase database
              final book = Book(
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
              print('Book Title: ${book.title}');
              print('Author: ${book.author}');
              print('Rating: ${book.rating}');
              print('Price: ${book.price}');
              print('Description: ${book.description}');
              print('Release Date: ${book.releaseDate}');
              print('Language: ${book.language}');
              print('Publisher: ${book.publisher}');
              print('Pages: ${book.pages}');

              // Adding the book object created into the book list
              books.add(book);
            }
          }
        }

        setState(() {
          purchasedBooks.clear();
          purchasedBooks.addAll(books as Iterable<Map<String, dynamic>>);
          isLoadingPurchasedBooks = false; // Set loading to false after fetching data
        });
      } else {
        print("User document not found!");
        setState(() {
          isLoadingPurchasedBooks = false;
        });
      }
    } catch (e) {
      print('Error fetching purchasedBooks: $e');
      setState(() {
        isLoadingPurchasedBooks = false;
      });
    }
  }

  bool isLoadingPurchasedBooks = true;
  @override
  void initState() {
    super.initState();
    // Fetch purchased books
    getUserPurchaseBookList().then((value) {
      setState(() {
        isLoadingPurchasedBooks = false;
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'My Books',
          style: GoogleFonts.urbanist(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
          if (isDesktop)
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
              onPressed: () {
                // Navigate to notifications
              },
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24.0 : 16.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Text(
                  'Show in',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                _buildViewToggleButton(
                  icon: Icons.grid_view,
                  selected: isGridView,
                  onTap: () => setState(() => isGridView = true),
                ),
                const SizedBox(width: 8),
                _buildViewToggleButton(
                  icon: Icons.view_list_rounded,
                  selected: !isGridView,
                  onTap: () => setState(() => isGridView = false),
                ),
                const Spacer(),
                Text(
                  '${purchasedBooks.length} Books',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: purchasedBooks.isEmpty
                ? _buildEmptyState()
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24.0 : 16.0,
                    ),
                    child: isGridView
                        ? _buildGridView(isDesktop)
                        : _buildListView(isDesktop),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: selected ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Books Yet',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your reading journey by purchasing books',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to discover/explore screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Browse Books',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(bool isDesktop) {
    final crossAxisCount = isDesktop ? 4 : 2;
    final spacing = isDesktop ? 24.0 : 16.0;

    return GridView.builder(
      padding: EdgeInsets.only(top: spacing, bottom: spacing * 2),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.75,
      ),
      itemCount: purchasedBooks.length,
      itemBuilder: (context, index) {
        final bookData = purchasedBooks[index];
        return _buildGridItem(bookData);
      },
    );
  }

  Widget _buildGridItem(Map<String, dynamic> bookData) {
    final book = bookData['book'] as Book;
    final progress = bookData['progress'] as double;
    final currentChapter = bookData['currentChapter'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book cover with progress indicator
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.book,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
              // Reading progress indicator
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Title
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        // Progress text
        Text(
          currentChapter,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        // Continue Reading Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Implement continue reading functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continue Reading',
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView(bool isDesktop) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 24.0 : 16.0),
      itemCount: purchasedBooks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final bookData = purchasedBooks[index];
        return _buildListItem(bookData, isDesktop);
      },
    );
  }

  Widget _buildListItem(Map<String, dynamic> bookData, bool isDesktop) {
    final book = bookData['book'] as Book;
    final progress = bookData['progress'] as double;
    final lastRead = bookData['lastRead'] as String;
    final currentChapter = bookData['currentChapter'] as String;

    return Container(
      height: isDesktop ? 160 : 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover with progress bar
          SizedBox(
            width: isDesktop ? 120 : 100,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  height: double.infinity,
                  child: const Icon(Icons.book, color: Colors.grey, size: 40),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        book.rating.toString(),
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    currentChapter,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Last read $lastRead',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Implement continue reading
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'Continue Reading',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}