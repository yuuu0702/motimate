import 'package:flutter/material.dart';

class MotivationScreen extends StatelessWidget {
  const MotivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('モチベーション登録'),
      ),
      body: const Center(
        child: Text('モチベーション登録画面'),
      ),
    );
  }
}
