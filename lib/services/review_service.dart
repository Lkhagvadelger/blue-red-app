import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys stored in SharedPreferences to control review prompt cadence.
class ReviewService {
  static const _lastPromptedDateKey = 'review_last_prompted_date';
  static const _firstSessionDateKey = 'review_first_session_date';
  static const _baselineAverageKey = 'review_baseline_average';
  static const _cooldownDays = 14;

  // ── Lifecycle ──────────────────────────────────────────────────

  /// Call once on every app start to record the first-ever session date.
  static Future<void> recordSessionStart() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_firstSessionDateKey)) {
      await prefs.setString(_firstSessionDateKey, _todayString());
    }
  }

  /// After the user's first few tests, snapshot their average so the
  /// analytics-improvement trigger has a reference point.
  static Future<void> recordBaselineIfNeeded(double currentAverage, int totalTests) async {
    if (totalTests != 5) return; // snapshot at exactly 5 tests
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_baselineAverageKey)) return;
    await prefs.setDouble(_baselineAverageKey, currentAverage);
  }

  // ── Guard checks ───────────────────────────────────────────────

  /// Returns true if ALL cooldown / eligibility gates pass.
  static Future<bool> _passesGuards(int totalTests) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Never on first session (same calendar day as install).
    final firstDate = prefs.getString(_firstSessionDateKey);
    if (firstDate == null || firstDate == _todayString()) return false;

    // 2. At least 20 tests completed.
    if (totalTests < 20) return false;

    // 3. 14-day cooldown since last prompt.
    final lastPrompted = prefs.getString(_lastPromptedDateKey);
    if (lastPrompted != null) {
      final last = DateTime.tryParse(lastPrompted);
      if (last != null && DateTime.now().difference(last).inDays < _cooldownDays) {
        return false;
      }
    }

    return true;
  }

  // ── Trigger: Personal Best ─────────────────────────────────────

  /// Call from ResultScreen when `isNewPersonalBest` is true.
  /// Returns true if the pre-ask dialog should be shown.
  static Future<bool> shouldPromptOnPersonalBest({
    required int totalTests,
    required int reactionTimeMs,
    required double averageMs,
  }) async {
    // Don't ask if the score is significantly worse than their average
    // (shouldn't happen on a PB, but defensive).
    if (reactionTimeMs > averageMs * 1.2) return false;

    return _passesGuards(totalTests);
  }

  // ── Trigger: Consistency Milestone ─────────────────────────────

  /// Call after every test. Returns true on the 25th, 50th, 100th, etc.
  static Future<bool> shouldPromptOnMilestone({required int totalTests}) async {
    const milestones = {25, 50, 100, 200, 500};
    if (!milestones.contains(totalTests)) return false;
    return _passesGuards(totalTests);
  }

  // ── Trigger: Analytics Improvement ─────────────────────────────

  /// Call when the user navigates to the Analytics screen.
  /// Returns true if their current average is better (lower) than baseline.
  static Future<bool> shouldPromptOnAnalyticsImprovement({
    required double currentAverage,
    required int totalTests,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final baseline = prefs.getDouble(_baselineAverageKey);
    if (baseline == null) return false;

    // Must have genuinely improved (at least 10ms lower).
    if (currentAverage >= baseline - 10) return false;

    return _passesGuards(totalTests);
  }

  // ── Pre-ask dialog ─────────────────────────────────────────────

  /// Shows the pre-ask "Are you enjoying Tirana?" dialog.
  /// If the user says yes, triggers the native OS review prompt.
  /// If no, opens a feedback path.
  ///
  /// Call this only after one of the `shouldPrompt*` methods returns true.
  static Future<void> showPreAskDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Happy with your score?',
          style: TextStyle(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Are you enjoying Tirana?',
          style: TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Needs work',
              style: TextStyle(color: Colors.white38, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes!', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );

    // Record that we prompted today regardless of answer.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPromptedDateKey, _todayString());

    if (result == true) {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    } else if (result == false) {
      // User said "Needs work" — show feedback dialog.
      if (context.mounted) {
        _showFeedbackDialog(context);
      }
    }
  }

  static void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'We\'d love to improve',
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Thanks for your honesty! We\'re always working to make Tirana better. '
          'Your feedback helps us prioritize what matters most.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
