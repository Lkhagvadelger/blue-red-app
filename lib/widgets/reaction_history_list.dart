import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reaction_result.dart';
import '../utils/constants.dart';

class ReactionHistoryList extends StatelessWidget {
  final List<ReactionResult> results;
  final int bestTimeMs;

  const ReactionHistoryList({
    super.key,
    required this.results,
    required this.bestTimeMs,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No tests yet.\nGo back and start testing!',
            style: TextStyle(color: Colors.white38, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final isBest = result.reactionTimeMs == bestTimeMs;
        final color = reactionColor(result.reactionTimeMs);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              '${result.reactionTimeMs}ms',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              dateFormat.format(result.createdAt),
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: isBest
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'BEST',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
