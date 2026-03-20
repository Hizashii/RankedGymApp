import 'dart:math';

class NotificationMessages {
  static const List<String> morningPrompts = [
    "Sun's up. Your 10-minute window is waiting whenever you're ready.",
    "Morning! A short session today counts for more than a long one tomorrow.",
    "Ready to restart? Your plan is ready for you.",
    "Don't worry about intensity. Just show up for 5 minutes today.",
  ];

  static const List<String> breakPrompts = [
    "No pressure, but a 5-minute stretch might make your afternoon feel better.",
    "Welcome back. Life happens. Let's do a quick 're-entry' flow.",
    "Small steps are the fastest way back. 10 minutes today?",
    "Your continuity score misses you! A quick set of squats?",
  ];

  static const List<String> adaptivePrompts = [
    "Last one was hard. I've dialed today's session back so you can catch your breath.",
    "Great work lately. I've slightly increased the challenge for your next session.",
    "Not feeling it? I've prepared a 'Low Energy' alternative for you.",
  ];

  static String getRandomMorning() {
    return morningPrompts[Random().nextInt(morningPrompts.length)];
  }

  static String getRandomBreak() {
    return breakPrompts[Random().nextInt(breakPrompts.length)];
  }

  static String getAdaptive(double intensity) {
    if (intensity < 0.8) return adaptivePrompts[0];
    if (intensity > 1.1) return adaptivePrompts[1];
    return adaptivePrompts[2];
  }
}
