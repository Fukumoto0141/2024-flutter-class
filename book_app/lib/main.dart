// 必要なパッケージをインポート
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core パッケージをインポート
import 'firebase_options.dart'; // Firebase の設定オプションをインポート
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth パッケージをインポート
import 'screens/book_list_page.dart'; // 書籍リストページをインポート
import 'screens/login_page.dart'; // ログインページをインポート

// main 関数: アプリケーションのエントリーポイント
void main() async {
  // Flutter のウィジェットバインディングを初期化
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase を初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 現在のプラットフォーム用の Firebase 設定を使用
  );
  // MyApp ウィジェットを実行
  runApp(const MyApp());
}

// MyApp ウィジェット: アプリケーションのルートウィジェット
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp ウィジェットを返す
    return MaterialApp(
      title: '書籍管理アプリ', // アプリのタイトル
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo), // アプリのテーマ設定
      // StreamBuilder を使用して認証状態の変化を監視
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // 認証状態の変化をストリームとして取得
        builder: (context, snapshot) {
          // 接続状態が待機中の場合はローディング表示
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // データ（ユーザー情報）がある場合は書籍リストページを表示
          if (snapshot.hasData) {
            return const BookListPage();
          }
          // データがない場合はログインページを表示
          return const LoginPage();
        },
      ),
    );
  }
}
