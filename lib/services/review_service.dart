import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const _lastPromptedDateKey = 'review_last_prompted_date';
  static const _dailyTestCountKey = 'daily_test_count';
  static const _dailyTestDateKey = 'daily_test_date';
  static const _triggerCount = 3;

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<void> recordTest() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final storedDate = prefs.getString(_dailyTestDateKey) ?? '';

    if (storedDate == today) {
      final count = prefs.getInt(_dailyTestCountKey) ?? 0;
      await prefs.setInt(_dailyTestCountKey, count + 1);
    } else {
      await prefs.setString(_dailyTestDateKey, today);
      await prefs.setInt(_dailyTestCountKey, 1);
    }
  }

  static Future<void> maybeRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();

    // Check if already prompted today
    final lastPromptedDate = prefs.getString(_lastPromptedDateKey) ?? '';
    if (lastPromptedDate == today) return;

    // Check if 3rd test of the day
    final storedDate = prefs.getString(_dailyTestDateKey) ?? '';
    final dailyCount = prefs.getInt(_dailyTestCountKey) ?? 0;

    if (storedDate != today || dailyCount < _triggerCount) return;

    // Only trigger on exactly the 3rd test
    if (dailyCount != _triggerCount) return;

    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      await prefs.setString(_lastPromptedDateKey, today);
    }
  }
}
