// services/book_service.dart
// Cloud Firestore パッケージをインポート
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Auth パッケージをインポート
import 'package:firebase_auth/firebase_auth.dart';

// 書籍関連の Firestore 操作を行うサービスクラス
class BookService {
  // Firestore のインスタンス
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Firebase Auth のインスタンス
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 現在のユーザーの書籍コレクションへの参照を返すゲッター
  CollectionReference<Map<String, dynamic>> get _bookCollection {
    // 現在のユーザーの UID を取得
    final uid = _auth.currentUser?.uid;
    // UID が null (未ログイン) の場合は例外をスロー
    if (uid == null) {
      throw Exception('User not logged in');
    }
    // users/{uid}/books コレクションへの参照を返す
    return _firestore.collection('users').doc(uid).collection('books');
  }

  // 書籍を追加する非同期関数
  Future<void> addBook(String title, String author) async {
    // 書籍コレクションに新しいドキュメントを追加
    await _bookCollection.add({
      'title': title, // タイトル
      'author': author, // 著者
      'createdAt': FieldValue.serverTimestamp(), // 作成日時 (サーバータイムスタンプ)
    });
  }

  // 書籍情報を更新する非同期関数
  Future<void> updateBook(String bookId, String title, String author) async {
    // 指定された bookId のドキュメントを更新
    await _bookCollection.doc(bookId).update({
      'title': title, // タイトル
      'author': author, // 著者
    });
  }

  // 書籍を削除する非同期関数
  Future<void> deleteBook(String bookId) async {
    // 指定された bookId のドキュメントを削除
    await _bookCollection.doc(bookId).delete();
  }

  // 書籍リストのストリームを返す関数
  Stream<QuerySnapshot<Map<String, dynamic>>> getBookStream() {
    // 書籍コレクションの変更を監視するストリームを返す (作成日時の降順でソート)
    return _bookCollection.orderBy('createdAt', descending: true).snapshots();
  }
}
