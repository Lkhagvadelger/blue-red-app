import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reaction_test_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  String? _selfAssessment;
  String? _motivation;
  String? _goal;

  static const _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectAndAdvance({
    required String key,
    required String value,
  }) {
    setState(() {
      switch (key) {
        case 'self_assessment':
          _selfAssessment = value;
        case 'user_motivation':
          _motivation = value;
        case 'user_goal':
          _goal = value;
      }
    });

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selfAssessment != null) {
      await prefs.setString('self_assessment', _selfAssessment!);
    }
    if (_motivation != null) {
      await prefs.setString('user_motivation', _motivation!);
    }
    if (_goal != null) {
      await prefs.setString('user_goal', _goal!);
    }
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ReactionTestScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= _currentPage
                          ? Colors.blue
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _buildQuestion1(),
                    _buildQuestion2(),
                    _buildQuestion3(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion1() {
    return _QuestionPage(
      title: 'How fast do you think\nyour reaction time is?',
      options: const [
        _OptionData('esports_pro', 'E-sports Pro', 'Under 200ms', '⚡'),
        _OptionData('above_average', 'Above Average', '200ms - 250ms', '🐆'),
        _OptionData('average', 'Average', '250ms - 300ms', '🚶'),
        _OptionData('no_idea', 'No idea, let\'s find out!', '', '🤷'),
      ],
      selectedValue: _selfAssessment,
      onSelect: (value) =>
          _selectAndAdvance(key: 'self_assessment', value: value),
    );
  }

  Widget _buildQuestion2() {
    return _QuestionPage(
      title: 'Why are you testing your\nreaction time today?',
      options: const [
        _OptionData('gaming', 'Improving my gaming reflexes', '', '🎮'),
        _OptionData('sports', 'Sports & athletic training', '', '🏃'),
        _OptionData('health', 'Tracking my brain focus / health', '', '🧠'),
        _OptionData('fun', 'Just for fun!', '', '🎯'),
      ],
      selectedValue: _motivation,
      onSelect: (value) =>
          _selectAndAdvance(key: 'user_motivation', value: value),
    );
  }

  Widget _buildQuestion3() {
    return _QuestionPage(
      title: 'What reaction time\nare you aiming for?',
      options: const [
        _OptionData('under_200', 'Break the 200ms barrier', '', '🚀'),
        _OptionData('under_250', 'Consistently under 250ms', '', '🎯'),
        _OptionData('baseline', 'Just want to see my baseline', '', '📊'),
      ],
      selectedValue: _goal,
      onSelect: (value) =>
          _selectAndAdvance(key: 'user_goal', value: value),
    );
  }
}

class _OptionData {
  final String value;
  final String label;
  final String subtitle;
  final String emoji;

  const _OptionData(this.value, this.label, this.subtitle, this.emoji);
}

class _QuestionPage extends StatelessWidget {
  final String title;
  final List<_OptionData> options;
  final String? selectedValue;
  final ValueChanged<String> onSelect;

  const _QuestionPage({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...options.map((option) {
            final isSelected = selectedValue == option.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onSelect(option.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withValues(alpha: 0.2)
                        : const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        option.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (option.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                option.subtitle,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: Colors.blue, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
