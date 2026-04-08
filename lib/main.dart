import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/review_service.dart';
import 'providers/reaction_history_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final box = await StorageService.init();
  await ReviewService.recordSessionStart();

  final provider = ReactionHistoryProvider();
  await provider.init(box);

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const ReactionTimeApp(),
    ),
  );
}
