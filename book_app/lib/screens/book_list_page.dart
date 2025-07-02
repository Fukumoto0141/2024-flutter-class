// 必要なパッケージをインポート
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/book_card.dart'; // BookCard ウィジェットをインポート
import 'book_detail_page.dart'; // BookDetailPage をインポート
import 'settings_page.dart'; // SettingsPage をインポート
import '../widgets/custom_text_field.dart';

// アイコン情報を保持するクラス
class IconInfo {
  final String name;
  final IconData icon;

  IconInfo({required this.name, required this.icon});
}

// 利用可能なアイコンのリスト
final List<IconInfo> bookIcons = [
  IconInfo(name: '小説', icon: Icons.menu_book),
  IconInfo(name: 'ビジネス書', icon: Icons.work),
  IconInfo(name: '自己啓発', icon: Icons.self_improvement),
  IconInfo(name: '技術書', icon: Icons.code),
  IconInfo(name: '漫画・アート', icon: Icons.palette),
  IconInfo(name: '趣味・実用', icon: Icons.sports_esports),
  IconInfo(name: '学習参考書', icon: Icons.school),
  IconInfo(name: '旅行ガイド', icon: Icons.flight_takeoff),
  IconInfo(name: '歴史', icon: Icons.account_balance),
  IconInfo(name: 'サイエンス', icon: Icons.science),
  IconInfo(name: '健康・医学', icon: Icons.medical_services),
  IconInfo(name: '料理', icon: Icons.restaurant),
  IconInfo(name: '絵本', icon: Icons.child_friendly),
  IconInfo(name: 'その他', icon: Icons.help_outline),
];

// 書籍リストページの StatefulWidget
class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

// 書籍リストページの State
class _BookListPageState extends State<BookListPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final reviewController = TextEditingController();
  String? _selectedIconName; // Firestore保存用の選択されたアイコン名 (ジャンル名)

  Future<void> addBook() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users') // 修正: usersコレクション
        .doc(user.uid)
        .collection('books')
        .add({
      'title': titleController.text,
      'author': authorController.text,
      'review': reviewController.text,
      'iconName': _selectedIconName, // アイコン名 (ジャンル名) を保存
      'createdAt': FieldValue.serverTimestamp(),
    });

    titleController.clear();
    authorController.clear();
    reviewController.clear();
    setState(() {
      _selectedIconName = null;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
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

  void _showAddBookModal(BuildContext context) {
    String? localSelectedIconName = _selectedIconName; // モーダル内での選択状態

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView( // コンテンツがはみ出る場合にスクロール可能にする
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('書籍を追加', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: titleController,
                      labelText: 'タイトル',
                    ),
                    CustomTextField(
                      controller: authorController,
                      labelText: '著者',
                    ),
                    CustomTextField(
                      controller: reviewController,
                      labelText: '感想',
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'ジャンル (アイコン)'),
                      value: localSelectedIconName,
                      items: bookIcons.map((IconInfo iconInfo) {
                        return DropdownMenuItem<String>(
                          value: iconInfo.name, // 保存するのはジャンル名
                          child: Row(
                            children: <Widget>[
                              Icon(iconInfo.icon),
                              const SizedBox(width: 10),
                              Text(iconInfo.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setModalState(() {
                          localSelectedIconName = newValue;
                        });
                        setState(() { // _BookListPageState の状態も更新
                          _selectedIconName = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // addBook を呼び出す前に _selectedIconName を確定
                        // onChanged で setState しているので、ここで明示的な setState は不要
                        addBook();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('追加'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // モーダルが閉じたときにコントローラーをクリア
      titleController.clear();
      authorController.clear();
      reviewController.clear();
      setState(() {
        _selectedIconName = null; // 選択もリセット
      });
    });
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('books')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('書籍がありません。追加してください。'));
            }

            final books = snapshot.data!.docs;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                final bookData = book.data() as Map<String, dynamic>;
                final iconName = bookData['iconName'] as String?;
                IconData? displayIcon;
                if (iconName != null) {
                  final foundIconInfo = bookIcons.firstWhere((info) => info.name == iconName, orElse: () => bookIcons.last); // 見つからない場合は「その他」アイコン
                  displayIcon = foundIconInfo.icon;
                }

                return BookCard(
                  title: bookData['title'],
                  author: bookData['author'],
                  iconData: displayIcon, // BookCard に IconData を渡す
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailPage(
                          title: bookData['title'],
                          author: bookData['author'],
                          review: bookData['review'] ?? '',
                          iconName: iconName, // BookDetailPage に iconName を渡す
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
