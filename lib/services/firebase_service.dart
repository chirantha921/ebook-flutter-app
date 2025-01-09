// lib/services/firebase_service.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebook_app/main.dart';
import 'package:ebook_app/models/book.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference booksCollection = FirebaseFirestore.instance.collection('Book');


  // Firestore methods
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String collection, String documentId) async {
    return await _firestore.collection(collection).doc(documentId).get();
  }

  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> setDocument(String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).set(data, SetOptions(merge: true));
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(String collection) async {
    return await _firestore.collection(collection).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollectionWithQuery(
    String collection,
    List<List<dynamic>> conditions,
  ) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    for (var condition in conditions) {
      if (condition.length == 3) {
        query = query.where(condition[0], isEqualTo: condition[1]);
      }
    }

    return await query.get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Storage methods
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      throw FirebaseException('Failed to get download URL: $e');
    }
  }

  Future<String> uploadFile(String path, List<int> bytes) async {
    try {
      final ref = _storage.ref(path);
      await ref.putData(Uint8List.fromList(bytes));
      return await ref.getDownloadURL();
    } catch (e) {
      throw FirebaseException('Failed to upload file: $e');
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      throw FirebaseException('Failed to delete file: $e');
    }
  }

  Future<List<Book>> searchBooksByTitle(String title)async{
    final snapshot = await booksCollection.where('title',isGreaterThanOrEqualTo: title).where('title',isLessThanOrEqualTo: title+'\uf8ff').get();
    return snapshot.docs.map((doc) => Book.fromFireStore(doc)).toList();
  }

  Future<void> purchaseBook(Book book)async{
    final userDoc = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    try{
      final userRef = _firestore.collection('User').doc(userDoc).update({
        'purchasedBooks': purchasedBooks.map((book) => book.toMap()).toList(),
      });

    }catch(e){
      print("Error adding books to purchased list: $e");
      throw Exception("Failed to add book to purchase list");
    }
  }
}

class FirebaseException implements Exception {
  final String message;
  FirebaseException(this.message);

  @override
  String toString() => 'FirebaseException: $message';
}