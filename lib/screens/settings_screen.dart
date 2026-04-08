import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reaction_history_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<ReactionHistoryProvider>(
        builder: (context, provider, _) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Show live timer'),
                subtitle:
                    const Text('Display elapsed milliseconds on green screen'),
                value: provider.showTimer,
                onChanged: (_) => provider.toggleShowTimer(),
              ),
            ],
          );
        },
      ),
    );
  }
}
