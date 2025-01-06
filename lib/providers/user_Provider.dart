import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  // Set user data after sign-in
  Future<void> setUserData(String uid) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('User').doc(uid).get();
      if (docSnapshot.exists) {
        _user = User.fromMap(docSnapshot.data()!);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Clear user data on logout
  void clearUserData() {
    _user = null;
    notifyListeners();
  }
}
