import 'package:flutter/material.dart';
import 'package:gardians/screens/profile/profile_constants.dart';
import 'package:gardians/screens/profile/simple_settings_scaffold.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<_FaqEntry> _faqItems = [
    _FaqEntry(
      question: 'How do I add a new child profile?',
      answer:
          'Open the home dashboard, tap Add Child, then complete the setup code from the child device. The profile appears immediately after successful pairing.',
    ),
    _FaqEntry(
      question: 'Can I set different limits for weekends?',
      answer:
          'Yes. Go to Rules, choose Screen Time, then define weekday and weekend schedules separately for each child profile.',
    ),
    _FaqEntry(
      question: 'What devices are currently supported?',
      answer:
          'SafeGuard currently supports Android and iOS mobile devices. Some monitoring features depend on OS permission availability.',
    ),
    _FaqEntry(
      question: 'How does content filtering work?',
      answer:
          'The app analyzes browsing and messaging metadata to detect risky patterns and blocks flagged categories using your selected policy level.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SimpleSettingsScaffold(
      title: 'Settings',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoSearchCard(),
            const SizedBox(height: 18),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 19,
                color: ProfileColors.navyBlue,
              ),
            ),
            const SizedBox(height: 10),
            ..._faqItems.map((item) => _faqItem(item)).toList(),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDEEF8)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA9DEEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: ProfileColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Still need help?',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                      color: ProfileColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our support team is available 24/7 to help keep your family safe online.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF5C6B81), fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support request started.'),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8ED8EF),
                      foregroundColor: ProfileColors.navyBlue,
                      minimumSize: const Size(170, 48),
                    ),
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSearchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EBF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How can we help you today?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: ProfileColors.navyBlue,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Search for answers or browse common topics below.',
            style: TextStyle(color: Color(0xFF69788E), fontSize: 15),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4E9F2)),
            ),
            child: const TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search FAQs, setup guides...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(_FaqEntry item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EAF3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        iconColor: ProfileColors.navyBlue,
        collapsedIconColor: ProfileColors.navyBlue,
        title: Text(
          item.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: ProfileColors.navyBlue,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: const TextStyle(
                color: Color(0xFF55647B),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqEntry {
  const _FaqEntry({required this.question, required this.answer});

  final String question;
  final String answer;
}
