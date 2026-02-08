import 'package:flutter/material.dart';

class AppColors {
  static const Color waiting = Color(0xFFE53935);
  static const Color ready = Color(0xFF1E88E5);
  static const Color tooEarly = Color(0xFFFB8C00);
}

class AppConstants {
  static const int humanAverageMs = 250;
  static const int minDelayMs = 2000;
  static const int maxDelayMs = 5000;
}

String qualitativeLabel(int ms) {
  if (ms < 150) return 'Incredible!';
  if (ms < 200) return 'Excellent!';
  if (ms < 250) return 'Great!';
  if (ms < 350) return 'Average';
  if (ms < 500) return 'Below Average';
  return 'Keep Practicing';
}

Color reactionColor(int ms) {
  if (ms < 250) return Colors.green;
  if (ms < 350) return Colors.orange;
  return Colors.red;
}
