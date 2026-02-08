import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/reaction_history_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final box = await StorageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ReactionHistoryProvider()..init(box),
      child: const ReactionTimeApp(),
    ),
  );
}
