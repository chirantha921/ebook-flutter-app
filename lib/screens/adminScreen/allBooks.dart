import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../utils/constants.dart'; // Update import path as needed
import 'package:ebook_app/models/book.dart';

class AllBooksScreen extends StatefulWidget {
  const AllBooksScreen({Key? key}) : super(key: key);

  @override
  State<AllBooksScreen> createState() => _AllBookScreenState();
}

class _AllBookScreenState extends State<AllBooksScreen> {
  List<Book> allBooks = [];

  Future<void> getAllBooks() async{
    List<Book> allBook2 = [];
    try{
      CollectionReference bookCollection = FirebaseFirestore.instance.collection('Book');
      QuerySnapshot querySnapshot = await bookCollection.get();
      allBook2 = querySnapshot.docs.map((doc) => Book.fromFireStore(doc)).toList();

      for(var book in allBook2){
        print('book: ${book.title}, author: ${book.author}');
        allBooks.add(book);
      }

      setState(() {
        allBooks = allBook2;
        isLoadingBooks = false;
      });
    }
    catch(e){
      print('Error in fetching books $e');
      setState(() {
        isLoadingBooks = false;
      });
    }
  }

  bool isLoadingBooks = true;
  @override
  void initState() {
    super.initState();
    // Fetch the wishlist data from Firestore
    getAllBooks();
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
                  label: 'Remove from Book list',
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
      setState(() {
        allBooks.removeAt(index);
      });
    } else if (selectedAction == 'share') {
      // Implement share logic
    } else if (selectedAction == 'about') {
      // Implement about logic
    }
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
          'All Books',
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
      body: isLoadingBooks
      ? Center(child: CircularProgressIndicator()) : allBooks.isEmpty? Center(child: Text('No book has been added'))
      :Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24.0 : 16.0,
          vertical: isDesktop ? 24.0 : 16.0,
        ),
        child: ListView.separated(
          itemCount: allBooks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final book = allBooks[index];
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
