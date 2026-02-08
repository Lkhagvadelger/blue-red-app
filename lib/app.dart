import 'package:flutter/material.dart';
import 'screens/reaction_test_screen.dart';

class ReactionTimeApp extends StatelessWidget {
  const ReactionTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reaction Time',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ReactionTestScreen(),
    );
  }
}
