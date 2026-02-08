import 'package:hive_ce/hive_ce.dart';

part 'reaction_result.g.dart';

@HiveType(typeId: 0)
class ReactionResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime colorChangeTime;

  @HiveField(2)
  final DateTime tapTime;

  @HiveField(3)
  final int reactionTimeMs;

  @HiveField(4)
  final DateTime createdAt;

  ReactionResult({
    required this.id,
    required this.colorChangeTime,
    required this.tapTime,
    required this.reactionTimeMs,
    required this.createdAt,
  });
}
