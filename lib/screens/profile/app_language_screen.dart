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
    return ListView.separated(
      itemCount: _languages.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final String lang = _languages[index];
        return RadioListTile<String>(
          value: lang,
          groupValue: _selected,
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _selected = value;
            });
          },
          title: Text(lang),
        );
      },
    );
  }
}
