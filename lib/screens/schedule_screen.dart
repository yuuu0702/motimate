import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール登録'),
      ),
      body: const Center(
        child: Text('スケジュール登録画面'),
      ),
    );
  }
}
