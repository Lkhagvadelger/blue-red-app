import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reaction_history_provider.dart';
import '../utils/constants.dart';
import '../widgets/stats_card.dart';
import '../widgets/reaction_history_chart.dart';
import '../widgets/reaction_history_list.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text('Analytics'),
        elevation: 0,
        actions: [
          Consumer<ReactionHistoryProvider>(
            builder: (context, provider, _) {
              if (provider.totalTests == 0) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white38),
                onPressed: () => _confirmClear(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReactionHistoryProvider>(
        builder: (context, provider, _) {
          final avg = provider.averageReactionTime;
          final best = provider.bestReactionTime;
          final total = provider.totalTests;
          final chronological = provider.chronologicalResults;
          final reverseChronological = provider.results;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatsCard(
                      title: 'Average',
                      value: total > 0 ? '${avg.round()}ms' : '--',
                      subtitle: 'Human avg: ${AppConstants.humanAverageMs}ms',
                      icon: Icons.speed,
                      iconColor: total > 0
                          ? reactionColor(avg.round())
                          : Colors.white38,
                    ),
                    const SizedBox(width: 8),
                    StatsCard(
                      title: 'Best',
                      value: total > 0 ? '${best}ms' : '--',
                      icon: Icons.emoji_events,
                      iconColor:
                          total > 0 ? Colors.amber : Colors.white38,
                    ),
                    const SizedBox(width: 8),
                    StatsCard(
                      title: 'Tests',
                      value: '$total',
                      icon: Icons.touch_app,
                      iconColor: Colors.white54,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Reaction Time Trend',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ReactionHistoryChart(results: chronological),
                const SizedBox(height: 24),
                Text(
                  'History (${reverseChronological.length})',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ReactionHistoryList(
                  results: reverseChronological,
                  bestTimeMs: best,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, ReactionHistoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Clear History',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete all your reaction test data. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
