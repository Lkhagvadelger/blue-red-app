import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/reaction_result.dart';

class StorageService {
  static const String reactionBoxName = 'reactions';

  static Future<Box<ReactionResult>> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ReactionResultAdapter());
    return await Hive.openBox<ReactionResult>(reactionBoxName);
  }
}
