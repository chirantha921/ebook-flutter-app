import 'book.dart';
class Admin{
  final int adminId;
  final String name;
  final String password;
  final List<Book>? insertedBooks;

  Admin({
      this.adminId = 1,
      this.name = "Admin",
      this.password = "Admin123Lak",
      this.insertedBooks,
  });

  factory Admin.fromMap(Map<String, dynamic> data) {
    return Admin(
      adminId: data['adminID'],
      name: data['name'],
      password: data['password'],
      insertedBooks: (data['insertedBooks'] as List<dynamic>?)
          ?.map((bookData) => Book.fromMap(bookData))
          .toList(),
    );
  }

}