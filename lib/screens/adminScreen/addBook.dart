import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '';

class AddBook extends StatefulWidget{
  const AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook>{
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleEditingController = TextEditingController();
  final TextEditingController authorEditingController = TextEditingController();
  final TextEditingController descriptionEditingController = TextEditingController();
  final TextEditingController imageEditingController = TextEditingController();
  final TextEditingController publisherEditingController = TextEditingController();
  final TextEditingController pageEditingController = TextEditingController();
  final TextEditingController releaseDateEditingController = TextEditingController();
  final TextEditingController priceEditingController = TextEditingController();
  final TextEditingController languageEditingController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Book',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87,)
        ),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: _isLoading? null: saveBook,
              child: Text(
                'Save',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isLoading ? Colors.grey: AppColors.primary,
                ),
              ),
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
      :SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
        key: _formKey,
        child: Column(
        children: [
        _buildSectionTitle('Title of the book'),
        TextFormField(
          controller: titleEditingController,
          keyboardType: TextInputType.phone,
          maxLines: null,
          decoration:_buildInputDecoration(
            'Enter the title of the book',
            Icons.title,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSectionTitle('Description of the Book'),
        TextFormField(
          controller: descriptionEditingController,
          keyboardType: TextInputType.phone,
          maxLines: null,
          decoration: _buildInputDecoration(
            'Enter the description of the book',
            Icons.description,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSectionTitle('Author of the Book'),
        TextFormField(
          controller: authorEditingController,
          keyboardType: TextInputType.phone,
          maxLines: null,
          decoration: _buildInputDecoration(
            'Enter the author of the book',
            Icons.perm_identity,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSectionTitle('Image of the book (Link)'),
        TextFormField(
          controller: imageEditingController,
          keyboardType: TextInputType.phone,
          maxLines: null,
          decoration: _buildInputDecoration(
            'Enter your display name',
            Icons.image,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSectionTitle('Price of the Book'),
        TextFormField(
          controller: priceEditingController,
          keyboardType: TextInputType.phone,
          maxLines: null,
          decoration: _buildInputDecoration(
            'Enter your display name',
            Icons.monetization_on,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSectionTitle('Publisher of the Book'),
        TextFormField(
          controller: publisherEditingController,
          keyboardType: TextInputType.phone,
          maxLines: null,
          decoration: _buildInputDecoration(
            'Enter the publisher of the book',
            Icons.perm_identity,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSectionTitle('Language of the book'),
        TextFormField(
          controller: languageEditingController,
          keyboardType: TextInputType.phone,
          maxLines: null,
          decoration: _buildInputDecoration(
            'Enter the language of the book',
            Icons.language,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSectionTitle('Number of pages in the Book'),
        TextFormField(
          controller: pageEditingController,
          keyboardType: TextInputType.phone,
          maxLines: null,
          decoration: _buildInputDecoration(
            'Enter the number of pages in the book',
            Icons.person_outline,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildSectionTitle('Release date of the book'),
        TextFormField(
          controller: releaseDateEditingController,
          keyboardType: TextInputType.phone,
          maxLines: null,
          decoration: _buildInputDecoration(
            'Enter the release data of the book',
            Icons.person_outline,
          ),
        ),
        const SizedBox(height: 20.0),
        ],
      ),
    )
      ),
    );
  }

  Future<void> saveBook()async{
    setState(() {
      _isLoading = true;
    });
    Book book = Book(
      title: titleEditingController.text,
      rating: 0,
      price: double.parse(priceEditingController.text),
      author: authorEditingController.text,
      image: imageEditingController.text,
      pages: int.parse(pageEditingController.text),
      description: descriptionEditingController.text,
      language: languageEditingController.text,
      publisher: publisherEditingController.text,
      progress: 0,
      currentChapter: "1",
      lastRead: "none",
    );
    await addNewBook(book);
  }

  Future<void> addNewBook(Book book) async{
    final bookCollection = FirebaseFirestore.instance.collection('Book');

    await bookCollection.add(book.toMap()).then((docRef){
      print("Book has been added with ID: ${docRef.id}");
    }).catchError((error){
      print("Error in adding book: $error");
    });
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

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.urbanist(
        color: Colors.grey,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

}