import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/reaction_result.dart';
import '../providers/reaction_history_provider.dart';
import '../screens/result_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/constants.dart';

enum TestState { waiting, ready, tooEarly }

class ReactionTestScreen extends StatefulWidget {
  const ReactionTestScreen({super.key});

  @override
  State<ReactionTestScreen> createState() => _ReactionTestScreenState();
}

class _ReactionTestScreenState extends State<ReactionTestScreen> {
  TestState _state = TestState.waiting;
  Timer? _timer;
  Timer? _elapsedTimer;
  DateTime? _colorChangeTime;
  int _elapsedMs = 0;
  final _random = Random();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startWaiting();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _elapsedTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startWaiting() {
    _timer?.cancel();
    _elapsedTimer?.cancel();
    setState(() {
      _state = TestState.waiting;
      _colorChangeTime = null;
      _elapsedMs = 0;
    });

    final delayMs = AppConstants.minDelayMs +
        _random.nextInt(AppConstants.maxDelayMs - AppConstants.minDelayMs);

    _timer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted) {
        setState(() {
          _state = TestState.ready;
          _colorChangeTime = DateTime.now();
        });
        _startElapsedTimer();
      }
    });
  }

  void _startElapsedTimer() {
    final showTimer = Provider.of<ReactionHistoryProvider>(context, listen: false).showTimer;
    if (!showTimer) return;
    _elapsedTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (mounted && _colorChangeTime != null) {
        setState(() {
          _elapsedMs = DateTime.now().difference(_colorChangeTime!).inMilliseconds;
        });
      }
    });
  }

  void _onTap() {
    switch (_state) {
      case TestState.waiting:
        _timer?.cancel();
        HapticFeedback.mediumImpact();
        setState(() {
          _state = TestState.tooEarly;
        });
        break;

      case TestState.ready:
        _elapsedTimer?.cancel();
        final tapTime = DateTime.now();
        HapticFeedback.mediumImpact();
        final reactionTimeMs =
            tapTime.difference(_colorChangeTime!).inMilliseconds;
        final result = ReactionResult(
          id: _uuid.v4(),
          colorChangeTime: _colorChangeTime!,
          tapTime: tapTime,
          reactionTimeMs: reactionTimeMs,
          createdAt: DateTime.now(),
        );

        final provider =
            Provider.of<ReactionHistoryProvider>(context, listen: false);
        final isNewBest = provider.isNewPersonalBest(reactionTimeMs);
        provider.addResult(result);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              result: result,
              isNewPersonalBest: isNewBest,
              totalTests: provider.totalTests,
              averageMs: provider.averageReactionTime,
            ),
          ),
        ).then((_) {
          if (mounted) _startWaiting();
        });
        break;

      case TestState.tooEarly:
        _startWaiting();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String text;
    String? subText;

    switch (_state) {
      case TestState.waiting:
        bgColor = AppColors.waiting;
        text = 'Wait for color change';
        break;
      case TestState.ready:
        bgColor = AppColors.ready;
        text = 'Tap now!';
        break;
      case TestState.tooEarly:
        bgColor = AppColors.tooEarly;
        text = 'Too early!';
        subText = 'Tap to try again';
        break;
    }

    return Scaffold(
      body: GestureDetector(
        onTapDown: (_) => _onTap(),
        child: Container(
          color: bgColor,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (subText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        subText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.bar_chart,
                      color: Colors.white70, size: 28),
                  onPressed: () {
                    _timer?.cancel();
                    _elapsedTimer?.cancel();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalyticsScreen(),
                      ),
                    ).then((_) {
                      if (mounted) _startWaiting();
                    });
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.settings,
                      color: Colors.white70, size: 28),
                  onPressed: () {
                    _timer?.cancel();
                    _elapsedTimer?.cancel();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ).then((_) {
                      if (mounted) _startWaiting();
                    });
                  },
                ),
              ),
              if (_state == TestState.ready &&
                  context.watch<ReactionHistoryProvider>().showTimer)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 48,
                  left: 0,
                  right: 0,
                  child: Text(
                    '${_elapsedMs}ms',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
