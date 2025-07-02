import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {}; // Stores available users for each day
  Map<DateTime, bool> _myAvailability = {}; // Stores my availability

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Fetch all users' availability
    final allAvailabilitySnapshot = await FirebaseFirestore.instance
        .collection('availability')
        .get();

    final Map<DateTime, List<String>> newEvents = {};
    final Map<DateTime, bool> newMyAvailability = {};

    for (var doc in allAvailabilitySnapshot.docs) {
      final data = doc.data();
      final userId = data['userId'];
      final date = (data['date'] as Timestamp).toDate();
      final isAvailable = data['isAvailable'];

      if (isAvailable) {
        if (newEvents[date] == null) {
          newEvents[date] = [];
        }
        newEvents[date]!.add(userId);
      }

      if (userId == currentUser.uid) {
        newMyAvailability[date] = isAvailable;
      }
    }

    setState(() {
      _events = newEvents;
      _myAvailability = newMyAvailability;
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ログインしていません。空き状況を登録できません。')),
        );
        return;
      }

      final docRef = FirebaseFirestore.instance.collection('availability').doc(
          '${currentUser.uid}_${selectedDay.year}-${selectedDay.month}-${selectedDay.day}');

      final currentAvailability = _myAvailability[selectedDay] ?? false;
      final newAvailability = !currentAvailability;

      try {
        await docRef.set({
          'userId': currentUser.uid,
          'date': Timestamp.fromDate(selectedDay),
          'isAvailable': newAvailability,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedDay.month}/${selectedDay.day} の空き状況を ${newAvailability ? '登録' : '解除'} しました！')),
        );
        _fetchAvailability(); // Refresh data after update
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('空き状況の登録に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール登録'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildEventsMarker(day, events),
                  );
                }
                return null;
              },
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
              todayBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: ValueNotifier(_getEventsForDay(_selectedDay!)),
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index]} tapped!'),
                        title: Text('空き: ユーザーID ${value[index]}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    final myAvailability = _myAvailability[date] ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: myAvailability ? Colors.green : Colors.red,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ),
    );
  }
}
