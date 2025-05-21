// Flutter Material パッケージをインポート
import 'package:flutter/material.dart';
import 'book_list_page.dart'; // bookIcons を使用するためにインポート

// 書籍詳細ページの StatelessWidget
class BookDetailPage extends StatelessWidget {
  final String title; // 書籍のタイトル
  final String author; // 書籍の著者
  final String review; // 書籍の感想
  // final String? imageUrl; // 画像 URL はアイコン表示のためコメントアウト
  final String? iconName; // 表示するアイコンの名前

  // コンストラクタ
  const BookDetailPage({
    super.key,
    required this.title,
    required this.author,
    required this.review,
    // this.imageUrl,
    this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    IconData? displayIcon;
    if (iconName != null) {
      final foundIconInfo = bookIcons.where((info) => info.name == iconName);
      if (foundIconInfo.isNotEmpty) {
        displayIcon = foundIconInfo.first.icon;
      }
    }

    // Scaffold ウィジェットを返す
    return Scaffold(
      appBar: AppBar(title: Text(title)), // AppBar のタイトルを書籍のタイトルに
      body: Padding(
        padding: const EdgeInsets.all(16), // 全体にパディング
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左寄せに配置
          children: [
            // アイコンが存在する場合に表示
            if (displayIcon != null)
              Center(
                child: Icon(displayIcon, size: 100, color: Theme.of(context).primaryColor),
              ),
            const SizedBox(height: 24),
            // タイトルを表示
            Text('タイトル: $title', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            // 著者を表示
            Text('著者: $author', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            // 「感想:」ラベルを表示
            Text('感想:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // 感想を表示
            Expanded(
              child: SingleChildScrollView(
                child: Text(review, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
