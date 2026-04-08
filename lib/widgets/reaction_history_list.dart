import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reaction_result.dart';
import '../utils/constants.dart';

class ReactionHistoryList extends StatefulWidget {
  final List<ReactionResult> results;
  final int bestTimeMs;
  static const int pageSize = 20;

  const ReactionHistoryList({
    super.key,
    required this.results,
    required this.bestTimeMs,
  });

  @override
  State<ReactionHistoryList> createState() => _ReactionHistoryListState();
}

class _ReactionHistoryListState extends State<ReactionHistoryList> {
  int _currentPage = 0;

  int get _totalPages =>
      (widget.results.length / ReactionHistoryList.pageSize).ceil();

  List<ReactionResult> get _pageResults {
    final start = _currentPage * ReactionHistoryList.pageSize;
    final end = (start + ReactionHistoryList.pageSize).clamp(0, widget.results.length);
    return widget.results.sublist(start, end);
  }

  @override
  void didUpdateWidget(ReactionHistoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPage >= _totalPages && _totalPages > 0) {
      _currentPage = _totalPages - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
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
    final pageResults = _pageResults;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pageResults.length,
          itemBuilder: (context, index) {
            final result = pageResults[index];
            final isBest = result.reactionTimeMs == widget.bestTimeMs;
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
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                trailing: isBest
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
        ),
        if (_totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white70),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white70),
                  onPressed: _currentPage < _totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
