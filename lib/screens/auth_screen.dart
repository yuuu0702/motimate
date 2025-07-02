import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _signInAnonymously(); // Automatically try to sign in
  }

  void _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signInAnonymously();
      // If successful, the StreamBuilder in main.dart will handle navigation
    } on FirebaseAuthException catch (e) {
      String message = '匿名ログインに失敗しました。';
      if (e.code == 'operation-not-allowed') {
        message = '匿名認証がFirebaseプロジェクトで有効になっていません。Firebaseコンソールで有効にしてください。';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'エラーが発生しました: $e';
      });
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
            Image.asset(
              'assets/images/welcome_illustration.png',
              height: 200, // Adjust height as needed
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Column(
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signInAnonymously,
                    child: const Text('再試行'),
                  ),
                ],
              )
            else
              const Text(
                'ログイン中...',
                style: TextStyle(fontSize: 18, color: Colors.grey),
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
