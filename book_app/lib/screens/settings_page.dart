// Flutter パッケージをインポート
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

// 設定画面: ニックネームの表示・変更
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final nicknameController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null && data['nickname'] != null) {
        nicknameController.text = data['nickname'];
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _updateNickname() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'nickname': nicknameController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ニックネームを更新しました')),
      );
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    controller: nicknameController,
                    labelText: 'ニックネーム',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateNickname,
                    child: const Text('更新'),
                  ),
                  const SizedBox(height: 16), // ログアウト用スペーサー
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('ログアウト'),
                  ),
                ],
              ),
            ),
    );
  }
}
