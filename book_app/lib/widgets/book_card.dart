// Flutter Material パッケージをインポート
import 'package:flutter/material.dart';

// 書籍情報を表示するカードウィジェット
class BookCard extends StatelessWidget {
  final String title; // 書籍のタイトル
  final String author; // 書籍の著者
  // final String? imageUrl; // 画像 URL はアイコン表示のためコメントアウト
  final IconData? iconData; // 表示するアイコンのデータ
  final VoidCallback onDelete; // 削除ボタンが押されたときのコールバック
  final VoidCallback onTap; // カードがタップされたときのコールバック

  // コンストラクタ
  const BookCard({
    super.key,
    required this.title,
    required this.author,
    // this.imageUrl,
    this.iconData,
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
        // 左側にアイコンを表示 (iconData があればそれを、なければデフォルトアイコン)
        leading: iconData != null
            ? Icon(iconData, size: 40)
            : const Icon(Icons.book_outlined, size: 40), // デフォルトアイコン
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), // タイトルを表示 (太字)
        subtitle: Text(author), // 著者を表示
        trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete), // 右側に削除ボタンを表示
        onTap: onTap, // タップ時の処理を設定
      ),
    );
  }
}
