import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive_ce.dart';
import '../models/reaction_result.dart';

class ReactionHistoryProvider extends ChangeNotifier {
  late Box<ReactionResult> _box;

  void init(Box<ReactionResult> box) {
    _box = box;
  }

  List<ReactionResult> get results {
    final list = _box.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<ReactionResult> get chronologicalResults {
    final list = _box.values.toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  int get totalTests => _box.length;

  double get averageReactionTime {
    if (_box.isEmpty) return 0;
    final sum = _box.values.fold<int>(0, (s, r) => s + r.reactionTimeMs);
    return sum / _box.length;
  }

  int get bestReactionTime {
    if (_box.isEmpty) return 0;
    return _box.values.map((r) => r.reactionTimeMs).reduce(min);
  }

  bool isNewPersonalBest(int reactionTimeMs) {
    if (_box.isEmpty) return true;
    return reactionTimeMs < bestReactionTime;
  }

  Future<void> addResult(ReactionResult result) async {
    await _box.add(result);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    notifyListeners();
  }
}
