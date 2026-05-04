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
      title: 'Help & Support',
      child: Container(
        color: const Color(0xFFEEF8FC), 
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SearchCard(),
            const SizedBox(height: 18),

            _SectionLabel('Frequently Asked Questions'),
            const SizedBox(height: 10),

            ..._faqItems.map((e) => _FaqTile(item: e)),

            const SizedBox(height: 18),

            _SupportCard(),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How can we help you today?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ProfileColors.navyBlue,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Search for answers or browse common topics below.',
            style: TextStyle(
              color: Color(0xFF7C8FA6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            decoration: InputDecoration(
              hintText: 'Search FAQs, setup guides...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF8FBFD),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5EBF4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5EBF4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF7C8FA6),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final _FaqEntry item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        iconColor: ProfileColors.navyBlue,
        collapsedIconColor: ProfileColors.navyBlue,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding:
            const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Text(
          item.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: ProfileColors.navyBlue,
            fontSize: 14,
          ),
        ),
        children: [
          Text(
            item.answer,
            style: const TextStyle(
              color: Color(0xFF7C8FA6),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent_rounded,
            color: ProfileColors.navyBlue,
            size: 40,
          ),
          const SizedBox(height: 10),

          const Text(
            'Still need help?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ProfileColors.navyBlue,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Our support team is available 24/7 to help keep your family safe online.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7C8FA6),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfileColors.navyBlue,
              foregroundColor: const Color(0xFFEAF6FB),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Contact Support',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqEntry {
  const _FaqEntry({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}