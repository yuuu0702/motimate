import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:motimate/models/practice_decision_model.dart';
import 'package:motimate/models/schedule_model.dart';
import 'package:motimate/services/notification_service.dart';

part 'home_viewmodel.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMotivation,
    @Default(false) bool isLoadingSchedule,
    @Default(false) bool isLoadingPractices,
    @Default(3.0) double currentMotivation,
    @Default([]) List<DateTime> nextPlayDates,
    @Default([]) List<ScheduleModel> popularDates,
    @Default([]) List<PracticeDecisionModel> pendingPractices,
    String? error,
  }) = _HomeState;
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel(this._auth, this._firestore)
      : super(const HomeState()) {
    _loadData();
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    
    await Future.wait([
      _loadNextPlayDate(),
      _loadCurrentMotivation(),
      _loadPopularDates(),
      _loadPendingPractices(),
    ]);
    
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadNextPlayDate() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData.containsKey('nextPlayDates')) {
          final List<dynamic> dates = userData['nextPlayDates'];
          final playDates = dates
              .map((timestamp) => (timestamp as Timestamp).toDate())
              .toList();
          
          // Ensure there are always two elements, but use empty list for state
          // since Freezed doesn't allow null in non-nullable lists
          
          state = state.copyWith(nextPlayDates: playDates);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _loadCurrentMotivation() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData.containsKey('latestMotivationLevel')) {
          final motivation = (userData['latestMotivationLevel'] as num).toDouble();
          state = state.copyWith(currentMotivation: motivation);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateMotivation(double newLevel) async {
    final user = _auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoadingMotivation: true);

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'latestMotivationLevel': newLevel.round(),
        'latestMotivationTimestamp': Timestamp.now(),
      }, SetOptions(merge: true));

      state = state.copyWith(
        currentMotivation: newLevel,
        isLoadingMotivation: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingMotivation: false,
      );
    }
  }

  Future<void> _loadPopularDates() async {
    state = state.copyWith(isLoadingSchedule: true);

    try {
      final snapshot = await _firestore.collection('schedules').get();
      final decisionsSnapshot = await _firestore
          .collection('practice_decisions')
          .get();

      final decidedDateKeys = decisionsSnapshot.docs
          .map((doc) => doc.data()['dateKey'])
          .where((key) => key != null)
          .cast<String>()
          .toSet();

      final schedules = <ScheduleModel>[];
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        try {
          final schedule = ScheduleModel.fromFirestore(doc);
          if (schedule.date.isAfter(now) && 
              schedule.members.isNotEmpty &&
              !decidedDateKeys.contains(schedule.id)) {
            schedules.add(schedule);
          }
        } catch (e) {
          continue;
        }
      }

      schedules.sort((a, b) {
        final memberComparison = b.memberCount.compareTo(a.memberCount);
        if (memberComparison != 0) return memberComparison;
        return a.date.compareTo(b.date);
      });

      state = state.copyWith(
        popularDates: schedules.take(3).toList(),
        isLoadingSchedule: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingSchedule: false,
      );
    }
  }

  Future<void> _loadPendingPractices() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = state.copyWith(isLoadingPractices: false);
      return;
    }

    state = state.copyWith(isLoadingPractices: true);

    try {
      final snapshot = await _firestore
          .collection('practice_decisions')
          .where('status', isEqualTo: 'pending')
          .get();

      final practices = <PracticeDecisionModel>[];
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final practice = PracticeDecisionModel.fromFirestore(doc);
        if (practice.practiceDate.isAfter(now) &&
            practice.availableMembers.contains(user.uid)) {
          practices.add(practice);
        }
      }

      practices.sort((a, b) => a.practiceDate.compareTo(b.practiceDate));

      state = state.copyWith(
        pendingPractices: practices,
        isLoadingPractices: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingPractices: false,
      );
    }
  }

  Future<void> decidePracticeDate(ScheduleModel schedule) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('practice_decisions').add({
        'decidedBy': user.uid,
        'decidedAt': Timestamp.now(),
        'practiceDate': Timestamp.fromDate(schedule.date),
        'dateKey': schedule.id,
        'availableMembers': schedule.members,
        'status': 'pending',
        'responses': {},
      });

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final deciderName = userData?['displayName'] ?? 
                         userData?['username'] ?? 
                         '誰か';

      for (final memberId in schedule.members) {
        if (memberId != user.uid) {
          await NotificationService.createPracticeDecisionNotification(
            userId: memberId,
            practiceDate: schedule.date,
            deciderName: deciderName,
          );
        }
      }

      await _loadPopularDates();
      await _loadPendingPractices();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> respondToPractice(String docId, String response) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('practice_decisions')
          .doc(docId)
          .update({'responses.${user.uid}': response});

      await _loadPendingPractices();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}