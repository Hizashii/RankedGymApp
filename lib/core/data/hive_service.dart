import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ranked_gym/core/data/models.dart';

class HiveService {
  static const _onboardingBoxName = 'onboarding';
  static const _stateBoxName = 'state';
  static const _completedBoxName = 'completed';
  static const _metaBoxName = 'meta';
  static const _legacyBoxes = [
    'profile',
    'sessions',
    'quests',
    'messages',
    'nutrition',
  ];

  static Future<void> init() async {
    await Hive.initFlutter();
    final targets = [
      _onboardingBoxName,
      _stateBoxName,
      _completedBoxName,
      _metaBoxName,
      ..._legacyBoxes,
    ];
    await Future.wait(targets.map(Hive.openBox));
  }

  static Box get _onboardingBox => Hive.box(_onboardingBoxName);
  static Box get _stateBox => Hive.box(_stateBoxName);
  static Box get _completedBox => Hive.box(_completedBoxName);
  static Box get _metaBox => Hive.box(_metaBoxName);

  static OnboardingAnswers? loadOnboardingAnswers() {
    final raw = _onboardingBox.get('data');
    if (raw is! String) return null;
    return OnboardingAnswers.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  static AssignedSession? loadCurrentSession() {
    final raw = _stateBox.get('current');
    if (raw is! String) return null;
    return AssignedSession.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  static List<AssignedSession> loadUpcomingSessions() {
    final raw = _stateBox.get('upcoming');
    if (raw is! String) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => AssignedSession.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static List<CompletedSession> loadCompletedSessions() {
    final raw = _completedBox.get('data');
    if (raw is! String) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => CompletedSession.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static bool loadOnboardingComplete() {
    return _metaBox.get('comebackOnboardingComplete', defaultValue: false)
        as bool;
  }

  static int loadDifficultyOffset() {
    return (_metaBox.get('difficultyOffset', defaultValue: 0) as num).toInt();
  }

  static bool loadReduceLoadFlag() {
    return _metaBox.get('reduceLoadFlag', defaultValue: false) as bool;
  }

  static Future<void> saveOnboardingAnswers(OnboardingAnswers answers) async {
    await _onboardingBox.put('data', jsonEncode(answers.toMap()));
  }

  static Future<void> saveCurrentSession(AssignedSession? session) async {
    if (session == null) {
      await _stateBox.delete('current');
      return;
    }
    await _stateBox.put('current', jsonEncode(session.toMap()));
  }

  static Future<void> saveUpcomingSessions(
      List<AssignedSession> sessions) async {
    await _stateBox.put(
      'upcoming',
      jsonEncode(sessions.map((item) => item.toMap()).toList()),
    );
  }

  static Future<void> saveCompletedSessions(
      List<CompletedSession> sessions) async {
    await _completedBox.put(
      'data',
      jsonEncode(sessions.map((item) => item.toMap()).toList()),
    );
  }

  static Future<void> saveOnboardingComplete(bool value) async {
    await _metaBox.put('comebackOnboardingComplete', value);
  }

  static Future<void> saveDifficultyOffset(int value) async {
    await _metaBox.put('difficultyOffset', value);
  }

  static Future<void> saveReduceLoadFlag(bool value) async {
    await _metaBox.put('reduceLoadFlag', value);
  }
}
