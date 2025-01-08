import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/screens/book/book_details_screen.dart';
import 'package:ebook_app/services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookSearchScreen extends StatefulWidget{
  const BookSearchScreen({Key? key}):super(key: key);

  @override
  BookSearchScreenState createState() => BookSearchScreenState();
}

 class BookSearchScreenState extends State<BookSearchScreen>{
  final FirebaseService firebaseService = FirebaseService();
  List<Book> searchResults = [];
  bool isLoading = false;

  void searchBooks(String title)async{
    setState(() {
      isLoading = true;
    });

    try{
      final results = await firebaseService.searchBooksByTitle(title);
      print(results);
      setState(() {
        searchResults = results;
      });
    }catch(e){
      print("Errors in search books");
    }finally{
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Search Books"),
    ),
    body: Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            onChanged: searchBooks,
            decoration: InputDecoration(
              labelText: "Search...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        if(isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        if(!isLoading && searchResults.isEmpty)
          const Center(
            child: Text("No books found."),
          ),
        if(!isLoading && searchResults.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
                itemBuilder: (context,index){
                final book = searchResults[index];
                return ListTile(
                  leading: book.image.isNotEmpty
                  ? Image.network(
                      book.image,
                      width: 50,
                      height: 50,
                    errorBuilder: (context,error,stackTrace){
                        return Icon(Icons.book);
                    },
                  ) : Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGh5WFH8TOIfRKxUrIgJZoDCs1yvQ4hIcppw&s',width: 50, height: 50),
                  title: Text(book.title),
                  subtitle: Text("Author: ${book.author} \n Rating: ${book.rating}"),
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
                );
                },
            ),
          ),
      ],
    ),
  );
  }
 }