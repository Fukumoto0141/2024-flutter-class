// Flutter Material パッケージをインポート
import 'package:flutter/material.dart';

// 書籍詳細ページの StatelessWidget
class BookDetailPage extends StatelessWidget {
  final String title; // 書籍のタイトル
  final String author; // 書籍の著者
  final String review; // 書籍の感想
  final String? imageUrl; // 書籍の画像 URL (オプショナル)

  // コンストラクタ
  const BookDetailPage({
    super.key,
    required this.title,
    required this.author,
    required this.review,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Scaffold ウィジェットを返す
    return Scaffold(
      appBar: AppBar(title: const Text('詳細')), // AppBar のタイトル
      body: Padding(
        padding: const EdgeInsets.all(16), // 全体にパディング
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左寄せに配置
          children: [
            // 画像 URL が存在する場合に画像を表示
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12), // 画像の角丸
                child: Image.network(imageUrl!, height: 200, fit: BoxFit.cover), // ネットワーク画像を表示
              ),
            const SizedBox(height: 16), // スペーサー
            // タイトルを表示
            Text('タイトル: $title', style: Theme.of(context).textTheme.titleLarge),
            // 著者を表示
            Text('著者: $author', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16), // スペーサー
            // 「感想:」ラベルを表示
            Text('感想:', style: Theme.of(context).textTheme.titleSmall),
            // 感想を表示
            Text(review),
          ],
        ),
      ),
    );
  }
}
