import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Set<DateTime> selectedDates = {};
  DateTime currentDate = DateTime.now();
  Map<String, Map<String, dynamic>> scheduleData = {};
  bool isLoading = true;

  final List<String> daysOfWeek = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .get();
      
      Map<String, Map<String, dynamic>> data = {};
      for (var doc in snapshot.docs) {
        final docData = doc.data();
        data[doc.id] = {
          'available': (docData['members'] as List?)?.length ?? 0,
          'members': docData['members'] ?? [],
        };
      }
      
      setState(() {
        scheduleData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<DateTime?> getDaysInMonth() {
    final year = currentDate.year;
    final month = currentDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingDayOfWeek = firstDay.weekday % 7;

    List<DateTime?> days = [];

    // 月初より前の空白セル
    for (int i = 0; i < startingDayOfWeek; i++) {
      days.add(null);
    }

    // 月の日付
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(year, month, day));
    }

    return days;
  }

  void toggleDate(DateTime date) {
    setState(() {
      if (selectedDates.contains(date)) {
        selectedDates.remove(date);
      } else {
        selectedDates.add(date);
      }
    });
  }

  String getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic>? getDateInfo(DateTime date) {
    return scheduleData[getDateKey(date)];
  }

  Future<void> _updateAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      for (DateTime date in selectedDates) {
        final dateKey = getDateKey(date);
        final docRef = FirebaseFirestore.instance.collection('schedules').doc(dateKey);
        
        batch.set(docRef, {
          'members': FieldValue.arrayUnion([user.uid]),
        }, SetOptions(merge: true));
      }
      
      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('空き状況を更新しました (${selectedDates.length}日)')),
        );
      }
      
      setState(() {
        selectedDates.clear();
      });
      
      _loadScheduleData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final days = getDaysInMonth();
    final currentMonthText = '${currentDate.year}年${currentDate.month}月';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDCFCE7), Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'スケジュール',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Calendar Card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentMonthText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '空いている日をタップしてね',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Days of week header
                              Row(
                                children: daysOfWeek.map((day) => Expanded(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                )).toList(),
                              ),
                              const SizedBox(height: 8),

                              // Calendar grid
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                                itemCount: days.length,
                                itemBuilder: (context, index) {
                                  final day = days[index];
                                  if (day == null) {
                                    return const SizedBox();
                                  }

                                  final isSelected = selectedDates.contains(day);
                                  final dateInfo = getDateInfo(day);

                                  return GestureDetector(
                                    onTap: () => toggleDate(day),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                colors: [Colors.blue, Colors.purple],
                                              )
                                            : null,
                                        color: isSelected ? null : Colors.transparent,
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Text(
                                              '${day.day}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFF1F2937),
                                              ),
                                            ),
                                          ),
                                          if (dateInfo != null)
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: Container(
                                                width: 16,
                                                height: 16,
                                                decoration: const BoxDecoration(
                                                  color: Colors.orange,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${dateInfo['available']}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Popular Dates Card
                      if (scheduleData.isNotEmpty)
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.people, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      '人気の日程',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...(scheduleData.entries
                                    .toList()
                                    ..sort((a, b) => b.value['available'].compareTo(a.value['available'])))
                                    .take(3)
                                    .map((entry) {
                                      final date = DateTime.parse(entry.key);
                                      final info = entry.value;
                                      final dayName = daysOfWeek[date.weekday % 7];

                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  '${date.day}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1F2937),
                                                  ),
                                                ),
                                                Text(
                                                  '($dayName)',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${info['available']}人参加可能',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Submit Button
                      if (selectedDates.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _updateAvailability,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              '空き状況を更新する (${selectedDates.length}日選択中)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
