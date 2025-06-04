// services/auth_service.dart
// Firebase Auth パッケージをインポート
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

// 認証関連の処理を行うサービスクラス
class AuthService {
  // Firebase Auth のインスタンス
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // メールアドレスとパスワードでサインインする非同期関数
  Future<User?> signIn(String email, String password) async {
    try {
      // メールアドレスとパスワードでサインインを実行
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // サインインしたユーザー情報を返す
      return credential.user;
    } catch (e) {
      log('SignIn Error: $e');
      rethrow;
    }
  }

  // メールアドレスとパスワードで新規登録する非同期関数
  Future<User?> signUp(String email, String password) async {
    try {
      // メールアドレスとパスワードでユーザーを作成
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 作成されたユーザー情報を返す
      return credential.user;
    } catch (e) {
      log('SignUp Error: $e');
      rethrow;
    }
  }

  // サインアウトする非同期関数
  Future<void> signOut() async {
    try {
      // サインアウトを実行
      await _auth.signOut();
    } catch (e) {
      log('SignOut Error: $e');
      rethrow;
    }
  }

  // ユーザーの認証状態の変化を監視するストリームを返すゲッター
  Stream<User?> get userChanges => _auth.userChanges();
}
