import 'package:flutter/material.dart';
import 'package:gardians/screens/profile/simple_settings_scaffold.dart';

class AppLanguageScreen extends StatelessWidget {
  const AppLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleSettingsScaffold(
      title: 'App Language',
      child: _LanguageSelector(),
    );
  }
}

class _LanguageSelector extends StatefulWidget {
  const _LanguageSelector();

  @override
  State<_LanguageSelector> createState() => _LanguageSelectorState();
}

  final Color skyBlue = const Color(0xFF9ED7EB);
  final Color navyBlue = const Color(0xFF042459);

class _LanguageSelectorState extends State<_LanguageSelector> {
  String _selected = 'English (US)';
  final List<String> _languages = const [
    'English (US)',
    'English (UK)',
    'Arabic',
    'French',
  ];

  @override
Widget build(BuildContext context) {
  return Container(
    color: const Color(0xFFEEF8FC),
    child: RadioGroup<String>(
    groupValue: _selected,
    onChanged: (value) {
      setState(() {
        _selected = value!;
      });
    },
    child: ListView.separated(
        padding: const EdgeInsets.all(16),
      itemCount: _languages.length,
      separatorBuilder: (_, __) => const  SizedBox(height: 10),
      itemBuilder: (_, index) {
        final String lang = _languages[index];
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: RadioListTile<String>(
            value: lang,
            activeColor: navyBlue,
            title: Text(lang),
          ),
        );
      },
    ),
    ),
  );
}
}
