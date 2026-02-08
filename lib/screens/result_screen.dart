import 'package:flutter/material.dart';
import '../models/reaction_result.dart';
import '../services/review_service.dart';
import '../utils/constants.dart';
import 'analytics_screen.dart';

class ResultScreen extends StatefulWidget {
  final ReactionResult result;
  final bool isNewPersonalBest;

  const ResultScreen({
    super.key,
    required this.result,
    required this.isNewPersonalBest,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ReviewService.recordTest();
      await ReviewService.maybeRequestReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ms = widget.result.reactionTimeMs;
    final label = qualitativeLabel(ms);
    final color = reactionColor(ms);
    final ratio = (ms / AppConstants.humanAverageMs).clamp(0.1, 2.0);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isNewPersonalBest) ...[
                  const Icon(Icons.emoji_events,
                      color: Colors.amber, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'New Personal Best!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  '${ms}ms',
                  style: TextStyle(
                    color: color,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                _buildComparisonBar(ratio, ms),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ready,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnalyticsScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'View Analytics',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonBar(double ratio, int ms) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('You',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            Text(
              'Human avg: ${AppConstants.humanAverageMs}ms',
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (1 / ratio).clamp(0.05, 1.0),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: reactionColor(ms),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          ms < AppConstants.humanAverageMs
              ? '${AppConstants.humanAverageMs - ms}ms faster than average'
              : ms > AppConstants.humanAverageMs
                  ? '${ms - AppConstants.humanAverageMs}ms slower than average'
                  : 'Exactly average!',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}
