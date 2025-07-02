// Flutter Material パッケージをインポート
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_list_page.dart'; // bookIcons を使用
import 'book_detail_page.dart';
import 'settings_page.dart';

// タイムラインページの StatefulWidget
class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('タイムライン'),
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
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('投稿がありません。'));
            }
            final posts = snapshot.data!.docs;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final data = posts[index].data() as Map<String, dynamic>;
                final iconName = data['iconName'] as String?;
                IconData? displayIcon;
                if (iconName != null) {
                  final info = bookIcons.firstWhere(
                      (i) => i.name == iconName,
                      orElse: () => bookIcons.last);
                  displayIcon = info.icon;
                }
                final posterName = data['userNickname'] as String? ?? data['userEmail'] as String? ?? '';
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: displayIcon != null
                        ? Icon(displayIcon, size: 40)
                        : const Icon(Icons.book_outlined, size: 40),
                    title: Text(data['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('著者: ${data['author']}'),
                        if ((data['review'] as String?)?.isNotEmpty ?? false)
                          Text(data['review']),
                        Text('共有者: $posterName',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailPage(
                            title: data['title'],
                            author: data['author'],
                            review: data['review'] ?? '',
                            iconName: iconName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showShareModal(context, user),
        child: const Icon(Icons.share),
      ),
    );
  }

  void _showShareModal(BuildContext context, User? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('books')
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final books = snapshot.data!.docs;
              String? selectedBookId;
              return StatefulBuilder(
                builder: (context, setModalState) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('書籍を共有',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...books.map((doc) {
                          final book = doc.data() as Map<String, dynamic>;
                          final iconName = book['iconName'] as String?;
                          IconData? displayIcon;
                          if (iconName != null) {
                            final info = bookIcons.firstWhere(
                                (i) => i.name == iconName,
                                orElse: () => bookIcons.last);
                            displayIcon = info.icon;
                          }
                          return RadioListTile<String>(
                            title: Row(
                              children: [
                                displayIcon != null
                                    ? Icon(displayIcon)
                                    : const Icon(Icons.book_outlined),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(book['title']),
                                    Text('著者: ${book['author']}',
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            value: doc.id,
                            groupValue: selectedBookId,
                            onChanged: (val) {
                              setModalState(() {
                                selectedBookId = val;
                              });
                            },
                          );
                        }).toList(),
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedBookId != null) {
                              final doc = books.firstWhere(
                                  (e) => e.id == selectedBookId);
                              final book = doc.data() as Map<String, dynamic>;
                              // 投稿時にユーザーのニックネームを取得して保存
                              final userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();
                              final nickname = userDoc.data()?['nickname'] as String? ?? user.email;
                              await FirebaseFirestore.instance
                                  .collection('posts')
                                  .add({
                                'title': book['title'],
                                'author': book['author'],
                                'review': book['review'] ?? '',
                                'iconName': book['iconName'],
                                'userEmail': user.email,
                                'userNickname': nickname,
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('共有'),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
