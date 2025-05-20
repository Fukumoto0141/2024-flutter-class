// 必要なパッケージをインポート
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../widgets/book_card.dart'; // BookCard ウィジェットをインポート
import 'book_detail_page.dart'; // BookDetailPage をインポート
import 'dart:typed_data'; // Uint8List を使用するためにインポート
import 'dart:html' as html; // Web でのファイルアップロード用にインポート

// 書籍リストページの StatefulWidget
class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

// 書籍リストページの State
class _BookListPageState extends State<BookListPage> {
  // 各 TextField のコントローラー
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final reviewController = TextEditingController();
  // 選択された画像のバイトデータ
  Uint8List? _imageBytes;
  // 選択された画像のファイル名
  String? _fileName;

  // 書籍を追加する非同期関数
  Future<void> addBook() async {
    // 現在のユーザーを取得
    final user = FirebaseAuth.instance.currentUser;
    // ユーザーが null の場合は処理を中断
    if (user == null) return;

    String? imageUrl;
    // 画像が選択されている場合
    if (_imageBytes != null && _fileName != null) {
      // Firebase Storage の参照を作成
      final ref = FirebaseStorage.instance
          .ref('books/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$_fileName');
      // メタデータを設定 (画像形式を JPEG に指定)
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      // 画像データをアップロード
      await ref.putData(_imageBytes!, metadata);
      // アップロードした画像の URL を取得
      imageUrl = await ref.getDownloadURL();
    }

    // Firestore に書籍情報を追加
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('books')
        .add({
      'title': titleController.text, // タイトル
      'author': authorController.text, // 著者
      'review': reviewController.text, // 感想
      'imageUrl': imageUrl, // 画像 URL
      'createdAt': FieldValue.serverTimestamp(), // 作成日時
    });

    // 各 TextField をクリア
    titleController.clear();
    authorController.clear();
    reviewController.clear();
    // 状態を更新して画像選択をリセット
    setState(() {
      _imageBytes = null;
      _fileName = null;
    });
  }

  // Web で画像を選択する関数
  void pickImageWeb() {
    // ファイルアップロード用の input 要素を作成
    final input = html.FileUploadInputElement()..accept = 'image/*';
    // input 要素をクリックしてファイル選択ダイアログを開く
    input.click();
    // ファイルが選択されたときの処理
    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file != null) {
        _fileName = file.name; // ファイル名を取得
        final reader = html.FileReader();
        // ファイルを ArrayBuffer として読み込む
        reader.readAsArrayBuffer(file);
        // 読み込み完了時の処理
        reader.onLoadEnd.listen((_) {
          // 状態を更新して画像バイトデータを設定
          setState(() {
            _imageBytes = reader.result as Uint8List;
          });
        });
      }
    });
  }

  // 書籍を削除する非同期関数
  Future<void> deleteBook(String id) async {
    // 現在のユーザーを取得
    final user = FirebaseAuth.instance.currentUser;
    // ユーザーが null の場合は処理を中断
    if (user == null) return;

    // Firestore から指定された ID の書籍を削除
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('books')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    // 現在のユーザーを取得
    final user = FirebaseAuth.instance.currentUser;
    // ユーザーが null の場合はログインが必要であることを表示
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('ログインが必要です')),
      );
    }

    // メインの Scaffold を返す
    return Scaffold(
      appBar: AppBar(
        title: const Text('書籍管理'), // AppBar のタイトル
        actions: [
          // ログアウトボタン
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(), // ログアウト処理を実行
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // 全体にパディングを設定
        child: Column(
          children: [
            // 画像選択エリア
            GestureDetector(
              onTap: pickImageWeb, // タップで画像選択処理を実行
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200], // 背景色
                  borderRadius: BorderRadius.circular(12), // 角丸
                  // 画像が選択されていれば表示
                  image: _imageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_imageBytes!), // メモリから画像を表示
                          fit: BoxFit.cover, // 画像の表示方法
                        )
                      : null,
                ),
                // 画像が選択されていなければアイコンを表示
                child: _imageBytes == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 8), // スペーサー
            // タイトル入力フィールド
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'タイトル'),
            ),
            // 著者入力フィールド
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: '著者'),
            ),
            // 感想入力フィールド
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(labelText: '感想'),
              maxLines: 2, // 複数行入力可能
            ),
            const SizedBox(height: 8), // スペーサー
            // 追加ボタン
            ElevatedButton.icon(
              onPressed: addBook, // タップで書籍追加処理を実行
              icon: const Icon(Icons.add),
              label: const Text('追加'),
            ),
            const SizedBox(height: 16), // スペーサー
            // 書籍リスト表示エリア
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Firestore から書籍リストを取得するストリーム
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('books')
                    .orderBy('createdAt', descending: true) // 作成日時の降順でソート
                    .snapshots(),
                builder: (context, snapshot) {
                  // データがない場合はローディング表示
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final books = snapshot.data!.docs; // 書籍リストを取得
                  // ListView で書籍リストを表示
                  return ListView.builder(
                    itemCount: books.length, // リストのアイテム数
                    itemBuilder: (context, index) {
                      final book = books[index]; // 各書籍データ
                      final bookData = book.data() as Map<String, dynamic>; // 書籍データを Map に変換

                      // BookCard ウィジェットで書籍情報を表示
                      return BookCard(
                        title: bookData['title'],
                        author: bookData['author'],
                        imageUrl: bookData['imageUrl'],
                        onTap: () {
                          // タップで書籍詳細ページに遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailPage(
                                title: bookData['title'],
                                author: bookData['author'],
                                review: bookData['review'] ?? '', // review が null の場合は空文字
                                imageUrl: bookData['imageUrl'],
                              ),
                            ),
                          );
                        },
                        onDelete: () => deleteBook(book.id), // 削除ボタンタップで書籍削除処理を実行
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
