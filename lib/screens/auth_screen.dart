import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  void _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInAnonymously();
      // If successful, the StreamBuilder in main.dart will handle navigation
    } on FirebaseAuthException catch (e) {
      String message = '匿名ログインに失敗しました。';
      if (e.code == 'operation-not-allowed') {
        message = '匿名認証がFirebaseプロジェクトで有効になっていません。Firebaseコンソールで有効にしてください。';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'モチメイトへようこそ！',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signInAnonymously,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      '匿名でログイン',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
            const SizedBox(height: 10),
            const Text(
              '(アカウント登録なしで利用できます)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
