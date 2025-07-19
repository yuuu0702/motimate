import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/practice_decision_model.dart';
import '../models/schedule_model.dart';
import '../services/motivation_service.dart';
import '../services/schedule_service.dart';
import '../services/practice_service.dart';

part 'home_viewmodel.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMotivation,
    @Default(false) bool isLoadingSchedule,
    @Default(false) bool isLoadingPractices,
    @Default(false) bool isLoadingPastPractices,
    @Default(3.0) double currentMotivation,
    @Default([]) List<DateTime> nextPlayDates,
    @Default([]) List<ScheduleModel> popularDates,
    @Default([]) List<PracticeDecisionModel> pendingPractices,
    @Default([]) List<PracticeDecisionModel> pastPractices,
    String? error,
  }) = _HomeState;
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel(
    this._motivationService,
    this._scheduleService,
    this._practiceService,
  ) : super(const HomeState()) {
    _loadData();
  }

  final MotivationService _motivationService;
  final ScheduleService _scheduleService;
  final PracticeService _practiceService;

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    
    await Future.wait([
      _loadNextPlayDate(),
      _loadCurrentMotivation(),
      _loadPopularDates(),
      _loadPendingPractices(),
      _loadPastPractices(),
    ]);
    
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadNextPlayDate() async {
    try {
      final playDates = await _scheduleService.getNextPlayDates();
      state = state.copyWith(nextPlayDates: playDates);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _loadCurrentMotivation() async {
    try {
      final motivation = await _motivationService.getCurrentMotivation();
      state = state.copyWith(currentMotivation: motivation);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateMotivation(double newLevel) async {
    state = state.copyWith(isLoadingMotivation: true);

    try {
      await _motivationService.updateMotivation(newLevel);
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
      final schedules = await _scheduleService.getPopularDates();
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
    state = state.copyWith(isLoadingPractices: true);

    try {
      final practices = await _practiceService.getPendingPractices();
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

  Future<void> _loadPastPractices() async {
    state = state.copyWith(isLoadingPastPractices: true);

    try {
      final practices = await _practiceService.getPastPractices();
      state = state.copyWith(
        pastPractices: practices,
        isLoadingPastPractices: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingPastPractices: false,
      );
    }
  }

  Future<void> decidePracticeDate(ScheduleModel schedule) async {
    try {
      await _scheduleService.decidePracticeDate(schedule);
      await _loadPopularDates();
      await _loadPendingPractices();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> respondToPractice(String docId, String response) async {
    try {
      await _practiceService.respondToPractice(docId, response);
      await _loadPendingPractices();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updatePracticeMemo(String practiceId, String memo) async {
    try {
      await _practiceService.updatePracticeMemo(practiceId, memo);
      await _loadPastPractices(); // 履歴を再読み込み
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateActualParticipants(String practiceId, List<String> participants) async {
    try {
      await _practiceService.updateActualParticipants(practiceId, participants);
      await _loadPastPractices(); // 履歴を再読み込み
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}