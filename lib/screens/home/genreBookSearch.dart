import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/book.dart';
import '../book/book_details_screen.dart';

class BookByGenreScreen extends StatelessWidget{
  final String genre;

  const BookByGenreScreen({
    Key? key, required this.genre
}): super(key: key);

  Widget build(BuildContext context){
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: AppBar(
        title: Text(genre),
      ),
      body: FutureBuilder<List<Book>>(
        future: fetchBookByGenre(genre),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else if(snapshot.hasError){
            return Center(child: Text('Error has been found ${snapshot.error}'));
          }else if(!snapshot.hasData || snapshot.data!.isEmpty){
            return Center(child: Text("No book with this available"));
          }else{
            final books = snapshot.data!;
            return ListView.separated(
              itemCount: books.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: (){
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
                  },
                child: Row(
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
                  ],
                ),
                );
              },
            );
          }
        }
      ),
    );
  }


  Future<List<Book>> fetchBookByGenre(String genre)async{
    final bookCollection = FirebaseFirestore.instance.collection('Book');
    final querySnapshot = await bookCollection.where('genre', isEqualTo: genre).get();
    return querySnapshot.docs.map((doc) => Book.fromFireStore(doc)).toList();
  }
}