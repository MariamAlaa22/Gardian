import 'package:flutter/material.dart';
import 'package:gardians/screens/profile/profile_constants.dart';
import 'package:gardians/screens/profile/simple_settings_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleSettingsScaffold(
      title: 'Settings',
      child: Container(
        color: const Color(0xFFEEF8FC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Privacy & Security',
                      style: TextStyle(
                        color: Color(0xFF1D6772),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 46,
                        color: ProfileColors.navyBlue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Last updated: October 24, 2023',
                      style: TextStyle(color: Color(0xFF6D7D95), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _policyCard(
                icon: Icons.shield_outlined,
                title: 'Data Protection',
                body:
                    "Your child's safety is our priority. We encrypt all sensitive data locally before it ever reaches our secure cloud servers.",
              ),
              const SizedBox(height: 10),
              _policyCard(
                icon: Icons.no_accounts_rounded,
                title: 'Zero Sale Policy',
                body:
                    'SafeGuard does not sell or lease user data to third-party advertisers. Your information stays within our private ecosystem.',
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4EAF4)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SafeGuard Commitment',
                      style: TextStyle(
                        color: Color(0xFF1F6174),
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Transparent practices for a safer digital childhood.',
                      style: TextStyle(color: Color(0xFF5D6B83)),
                    ),
                    Divider(height: 22),
                    Text(
                      'Data Collection',
                      style: TextStyle(
                        color: Color(0xFF7BAFC1),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'To provide safe monitoring features, we collect specific categories of data from protected devices:',
                      style: TextStyle(color: Color(0xFF5A687E), fontSize: 15),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '- Real-time location data for geofencing and tracking alerts.',
                      style: TextStyle(color: Color(0xFF4D5A70), fontSize: 14),
                    ),
                    Text(
                      '- Application usage statistics for screen-time reports.',
                      style: TextStyle(color: Color(0xFF4D5A70), fontSize: 14),
                    ),
                    Text(
                      '- Web browsing metadata for inappropriate-content filtering.',
                      style: TextStyle(color: Color(0xFF4D5A70), fontSize: 14),
                    ),
                    Divider(height: 22),
                    Text(
                      'User Rights',
                      style: TextStyle(
                        color: Color(0xFF7BAFC1),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'As a parent or guardian, you have full control over the data shared through our platform. You can request updates or deletion at any time.',
                      style: TextStyle(color: Color(0xFF5A687E), fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE4EAF4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Have questions about your data?',
                        style: TextStyle(
                          color: ProfileColors.navyBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Legal support request started.'),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: ProfileColors.navyBlue,
                      ),
                      child: const Text('Contact Legal'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _policyCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6ECF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFBCEAF6).withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: ProfileColors.navyBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ProfileColors.navyBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF5B6A81),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
