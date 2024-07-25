import 'package:flutter/material.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_section.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: DefaultTextStyle.merge(
        style: textStyles.bodyLarge,
        child: const AppScrollablePage(
          children: [
            TextSection(
              header: '1. Acceptance of Terms',
              body: 'By accessing or using the WagTrack application or website '
                  '(collectively, the "Service"), you agree to be bound by '
                  'these Terms of Service. If you do not agree to these terms, '
                  'please do not use the Service.',
            ),
            TextSection(
              header: '2. User Account',
              body:
                  'To use certain features of the Service, you are required to '
                  'create a user account. You are responsible for maintaining '
                  'the confidentiality of your account credentials and for all '
                  'activities that occur under your account.',
            ),
            TextSection(
              header: '3. User Content',
              body: 'You are solely responsible for the content you submit or '
                  'post through the Service. You represent and warrant that '
                  'you own or have the necessary rights to the content you '
                  'submit.',
            ),
            TextSection(
              header: '4. Disclaimer of Warranties',
              body: 'The Service is provided "as is" without warranties of any '
                  'kind, either express or implied. WagTrack disclaims all '
                  'warranties, including but not limited to, implied '
                  'warranties of merchantability, fitness for a particular '
                  'purpose, and non-infringement.',
            ),
            TextSection(
              header: '5. Limitation of Liability',
              body: 'In no event shall WagTrack be liable for any indirect, '
                  'incidental, special, consequential, or exemplary damages, '
                  'including but not limited to, damages for loss of profits, '
                  'data, or other intangible losses, arising out of or in '
                  'connection with the use of the Service.',
            ),
            TextSection(
              header: '6. Indemnification',
              body: 'You agree to indemnify and hold harmless WagTrack and its '
                  'affiliates, officers, agents, and employees from any claims, '
                  'liabilities, damages, losses, or expenses arising out of your '
                  'use of the Service or your violation of these Terms of Service.',
            ),
            TextSection(
              header: '7. Governing Law',
              body: 'These Terms of Service shall be governed by and construed '
                  'in accordance with the laws of Singapore.',
            ),
            TextSection(
              header: '8. Changes to Terms of Service',
              body: 'WagTrack reserves the right to modify or update these '
                  'Terms of Service at any time without prior notice. Your '
                  'continued use of the Service after any changes constitutes '
                  'your acceptance of the modified terms.',
            ),
            TextSection(
              header: '9. Contact Us',
              body: 'If you have any questions about these Terms of Service, '
                  'please contact us at wagtracksg@gmail.com',
            ),
          ],
        ),
      ),
    );
  }
}
