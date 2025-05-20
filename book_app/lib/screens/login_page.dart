// Flutter Material パッケージをインポート
import 'package:flutter/material.dart';
// Firebase Auth パッケージをインポート
import 'package:firebase_auth/firebase_auth.dart';

// ログインページの StatefulWidget
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// ログインページの State
class _LoginPageState extends State<LoginPage> {
  // メールアドレス入力用の TextEditingController
  final emailController = TextEditingController();
  // パスワード入力用の TextEditingController
  final passwordController = TextEditingController();
  // ログインモードか新規登録モードかを管理するフラグ (true: ログイン, false: 新規登録)
  bool isLogin = true;
  // エラーメッセージを格納する文字列
  String error = '';

  // 認証処理を行う非同期関数
  Future<void> handleAuth() async {
    try {
      // ログインモードの場合
      if (isLogin) {
        // メールアドレスとパスワードでサインイン
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        // 新規登録モードの場合
        // メールアドレスとパスワードでユーザーを作成
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Firebase Auth 関連のエラーが発生した場合
      // エラーメッセージを更新して再描画
      setState(() => error = e.message ?? 'エラーが発生しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold ウィジェットを返す
    return Scaffold(
      backgroundColor: Colors.grey[100], // 背景色
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // 全体にパディング
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // 最大幅を制限
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // カードの形状 (角丸)
              elevation: 8, // カードの影の深さ
              child: Padding(
                padding: const EdgeInsets.all(24.0), // カード内部のパディング
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Column の高さを最小限にする
                  children: [
                    // タイトル (ログインまたは新規登録)
                    Text(
                      isLogin ? 'ログイン' : '新規登録',
                      style: Theme.of(context).textTheme.headlineMedium, // テキストスタイル
                    ),
                    const SizedBox(height: 16), // スペーサー
                    // メールアドレス入力フィールド
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'メールアドレス'),
                    ),
                    const SizedBox(height: 8), // スペーサー
                    // パスワード入力フィールド
                    TextField(
                      controller: passwordController,
                      obscureText: true, // パスワードを隠す
                      decoration: const InputDecoration(labelText: 'パスワード'),
                    ),
                    const SizedBox(height: 16), // スペーサー
                    // 認証ボタン (ログインまたは登録)
                    ElevatedButton(
                      onPressed: handleAuth, // ボタンが押されたら認証処理を実行
                      child: Text(isLogin ? 'ログイン' : '登録'),
                    ),
                    // モード切り替えボタン (新規登録はこちらまたはログインはこちら)
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin), // ボタンが押されたら isLogin フラグを反転して再描画
                      child: Text(isLogin ? '新規登録はこちら' : 'ログインはこちら'),
                    ),
                    // エラーメッセージ表示エリア
                    if (error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(error, style: const TextStyle(color: Colors.red)), // 赤色のテキストでエラーメッセージを表示
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
