import 'package:flutter/material.dart';

class MemberListScreen extends StatelessWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メンバー一覧'),
      ),
      body: const Center(
        child: Text('メンバー一覧画面'),
      ),
    );
  }
}
