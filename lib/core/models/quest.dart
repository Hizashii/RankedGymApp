import 'package:ranked_gym/core/data/models.dart';

extension QuestUiX on Quest {
  bool get isComplete => completed || progress >= target;
  bool get isClaimable => isComplete && !claimed;

  double get progressFraction {
    if (target <= 0) return 0;
    final value = progress / target;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  String get progressLabel {
    if (target == 1.0) {
      return '${(progressFraction * 100).toStringAsFixed(0)}%';
    }
    final wholeNumbers =
        progress == progress.roundToDouble() && target == target.roundToDouble();
    if (wholeNumbers) {
      return '${progress.toInt()} / ${target.toInt()}';
    }
    return '${progress.toStringAsFixed(2)} / ${target.toStringAsFixed(2)}';
  }
}