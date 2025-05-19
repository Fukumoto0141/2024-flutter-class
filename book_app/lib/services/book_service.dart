// services/book_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _bookCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(uid).collection('books');
  }

  Future<void> addBook(String title, String author) async {
    await _bookCollection.add({
      'title': title,
      'author': author,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBook(String bookId, String title, String author) async {
    await _bookCollection.doc(bookId).update({
      'title': title,
      'author': author,
    });
  }

  Future<void> deleteBook(String bookId) async {
    await _bookCollection.doc(bookId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getBookStream() {
    return _bookCollection.orderBy('createdAt', descending: true).snapshots();
  }
}
