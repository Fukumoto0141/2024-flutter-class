// Flutter Material パッケージをインポート
import 'package:flutter/material.dart';

// 書籍情報を表示するカードウィジェット
class BookCard extends StatelessWidget {
  final String title; // 書籍のタイトル
  final String author; // 書籍の著者
  final String? imageUrl; // 書籍の画像 URL (オプショナル)
  final VoidCallback onDelete; // 削除ボタンが押されたときのコールバック
  final VoidCallback onTap; // カードがタップされたときのコールバック

  // コンストラクタ
  const BookCard({
    super.key,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Card ウィジェットを返す
    return Card(
      elevation: 3, // カードの影の深さ
      margin: const EdgeInsets.symmetric(vertical: 8), // カードの上下マージン
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // カードの形状 (角丸)
      // ListTile ウィジェットでカードの内容を構成
      child: ListTile(
        // 左側に画像またはアイコンを表示
        leading: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8), // 画像の角丸
                child: Image.network(imageUrl!, width: 50, height: 50, fit: BoxFit.cover), // ネットワーク画像を表示
              )
            : const Icon(Icons.book_outlined), // 画像がない場合は本のアイコンを表示
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), // タイトルを表示 (太字)
        subtitle: Text(author), // 著者を表示
        trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete), // 右側に削除ボタンを表示
        onTap: onTap, // タップ時の処理を設定
      ),
    );
  }
}
