import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  double _motivationLevel = 3.0; // Default motivation level
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitMotivation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインしていません。モチベーションを登録できません。')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('motivations').add({
        'userId': user.uid,
        'level': _motivationLevel.round(),
        'comment': _commentController.text,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('モチベーションを登録しました！')),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('モチベーションの登録に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('モチベーション登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'バスケに行きたい度',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _motivationLevel,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              label: _getEmojiForMotivation(_motivationLevel.round()),
              onChanged: (double value) {
                setState(() {
                  _motivationLevel = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('😩', style: TextStyle(fontSize: 24)),
                Text('🙁', style: TextStyle(fontSize: 24)),
                Text('😐', style: TextStyle(fontSize: 24)),
                Text('😊', style: TextStyle(fontSize: 24)),
                Text('🤩', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'コメント (任意)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: '今日の気分や意気込みをどうぞ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitMotivation,
                child: const Text('モチベーションを登録'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmojiForMotivation(int level) {
    switch (level) {
      case 1:
        return '😩';
      case 2:
        return '🙁';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '';
    }
  }
}
