import 'package:flutter/material.dart';

class ProposalScreen extends StatelessWidget {
  const ProposalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日程提案'),
      ),
      body: const Center(
        child: Text('日程提案・投票画面'),
      ),
    );
  }
}
