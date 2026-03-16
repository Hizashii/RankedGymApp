import 'package:ranked_gym/core/data/models.dart';

class QuestEngine {
  List<Quest> generateQuests({
    required List<WorkoutSession> sessions,
    required List<MuscleStatus> muscleStatuses,
    required AdminTuning tuning,
  }) {
    final completedLastWeek = sessions
        .where(
          (s) => s.completed && s.date.isAfter(DateTime.now().subtract(const Duration(days: 7))),
        )
        .length;

    final weakPoints = muscleStatuses.where((m) => m.isWeakPoint).toList();

    final base = <Quest>[
      Quest(
        id: 'q_consistency',
        title: 'Consistency Quest',
        description: 'Complete 3 sessions this week.',
        type: QuestType.consistency,
        difficulty: DifficultyTier.moderate,
        target: 3,
        progress: completedLastWeek.toDouble(),
        rewardXp: (180 * tuning.rewardMultiplier).round(),
        rewardCoins: (60 * tuning.rewardMultiplier).round(),
        completed: completedLastWeek >= 3,
        claimed: false,
      ),
      Quest(
        id: 'q_overload',
        title: 'Progressive Overload',
        description: 'Increase total session volume by 5% this week.',
        type: QuestType.overload,
        difficulty: DifficultyTier.hard,
        target: 1,
        progress: completedLastWeek >= 2 ? 0.65 : 0.35,
        rewardXp: (260 * tuning.rewardMultiplier).round(),
        rewardCoins: (95 * tuning.rewardMultiplier).round(),
        completed: completedLastWeek >= 4,
        claimed: false,
      ),
      Quest(
        id: 'q_milestone',
        title: 'Program Week Streak',
        description: 'Finish all planned sessions for one program week.',
        type: QuestType.milestone,
        difficulty: DifficultyTier.hard,
        target: 1,
        progress: completedLastWeek >= 3 ? 1.0 : 0.3,
        rewardXp: (300 * tuning.rewardMultiplier).round(),
        rewardCoins: (120 * tuning.rewardMultiplier).round(),
        completed: completedLastWeek >= 3,
        claimed: false,
      ),
    ];

    if (weakPoints.isNotEmpty) {
      final label = weakPoints.first.group.name.toUpperCase();
      base.add(
        Quest(
          id: 'q_weak_${weakPoints.first.group.name}',
          title: 'Weak Point Focus',
          description: 'Complete 2 targeted $label accessories.',
          type: QuestType.weakPoint,
          difficulty: DifficultyTier.moderate,
          target: 2,
          progress: completedLastWeek >= 1 ? 1.0 : 0.5,
          rewardXp: (200 * tuning.rewardMultiplier).round(),
          rewardCoins: (80 * tuning.rewardMultiplier).round(),
          completed: completedLastWeek >= 2,
          claimed: false,
        ),
      );
    }

    return base;
  }

  Quest updateProgressFromSession(Quest quest, WorkoutSession session) {
    if (!session.completed) return quest;
    switch (quest.type) {
      case QuestType.consistency:
        final next = quest.progress + 1;
        return quest.copyWith(progress: next, completed: next >= quest.target);
      case QuestType.overload:
        final tierPoints = switch (session.difficultyTier) {
          DifficultyTier.easy => 0.15,
          DifficultyTier.moderate => 0.3,
          DifficultyTier.hard => 0.45,
          DifficultyTier.elite => 0.6,
        };
        final next = quest.progress + tierPoints;
        return quest.copyWith(progress: next, completed: next >= quest.target);
      case QuestType.weakPoint:
      case QuestType.milestone:
        final next = quest.progress + 1;
        return quest.copyWith(progress: next, completed: next >= quest.target);
    }
  }
}
