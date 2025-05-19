import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/book_card.dart';
import 'book_detail_page.dart';
import 'dart:typed_data';
import 'dart:html' as html; // Webアップロード用

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final reviewController = TextEditingController();
  Uint8List? _imageBytes;
  String? _fileName;

  Future<void> addBook() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? imageUrl;
    if (_imageBytes != null && _fileName != null) {
      final ref = FirebaseStorage.instance
          .ref('books/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$_fileName');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putData(_imageBytes!, metadata);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('books')
        .add({
      'title': titleController.text,
      'author': authorController.text,
      'review': reviewController.text,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    titleController.clear();
    authorController.clear();
    reviewController.clear();
    setState(() {
      _imageBytes = null;
      _fileName = null;
    });
  }

  void pickImageWeb() {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file != null) {
        _fileName = file.name;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((_) {
          setState(() {
            _imageBytes = reader.result as Uint8List;
          });
        });
      }
    });
  }

  Future<void> deleteBook(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('books')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('ログインが必要です')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('書籍管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImageWeb,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _imageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_imageBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageBytes == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'タイトル'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: '著者'),
            ),
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(labelText: '感想'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: addBook,
              icon: const Icon(Icons.add),
              label: const Text('追加'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('books')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final books = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final bookData = book.data() as Map<String, dynamic>;

                      return BookCard(
                        title: bookData['title'],
                        author: bookData['author'],
                        imageUrl: bookData['imageUrl'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailPage(
                                title: bookData['title'],
                                author: bookData['author'],
                                review: bookData['review'] ?? '',
                                imageUrl: bookData['imageUrl'],
                              ),
                            ),
                          );
                        },
                        onDelete: () => deleteBook(book.id),
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
