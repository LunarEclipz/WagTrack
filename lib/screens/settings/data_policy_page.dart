import 'package:flutter/material.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_section.dart';

class DataPolicyPage extends StatefulWidget {
  const DataPolicyPage({super.key});

  @override
  State<DataPolicyPage> createState() => _DataPolicyPageState();
}

class _DataPolicyPageState extends State<DataPolicyPage> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Privacy Policy',
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
              header: '1. Introduction',
              body: 'WagTrack respects your privacy and is committed to '
                  'protecting your personal information. This Data Policy '
                  'outlines how we collect, use, disclose, and protect your '
                  'data when you use our services.',
            ),
            TextSection(
              header: '2. Data Collection',
              body: 'We may collect personal information from you when you '
                  'create an account, use our services, or interact with us. '
                  'This information may include: \n\n'
                  'Personal details (username, email, phone number)\n'
                  'Pet information (name, breed, age, medical history)\n'
                  'Location data (for services requiring geolocation)\n'
                  'Device information (type, operating system, app version)',
            ),
            TextSection(
              header: '3. Data Usage',
              body: 'We use your data to: \n\n'
                  'Provide and improve our services.\n'
                  'Create a personalized user experience.\n'
                  'Communicate with you about our services and updates.\n'
                  'Protect the security of our platform.\n'
                  'Comply with legal obligations.\n',
            ),
            TextSection(
              header: '4. Data Sharing',
              body: 'We may share your data with third-party service providers '
                  'who assist us in operating our business (e.g., payment '
                  'processors, cloud service providers). We will only share '
                  'necessary information and require these third parties to '
                  'maintain appropriate security measures. \n\n'
                  'Sharing with AVS: We may share your data with AVS '
                  '(Agri-Veterinary Authority of Singapore) for purposes '
                  'related to animal welfare and public health, with your '
                  'explicit consent. This sharing is optional and you can '
                  'choose to opt-out at any time.',
            ),
            TextSection(
              header: '5. Data Security',
              body: 'We implement reasonable security measures to protect your '
                  'data from unauthorized access, disclosure, alteration, or '
                  'destruction. However, no method of transmission over the '
                  'internet or electronic storage is completely secure.',
            ),
            TextSection(
              header: '6. Your Rights',
              body: 'You have the right to access, correct, or delete your '
                  'personal information. You can also object to the processing '
                  'of your data or request data portability. To exercise these '
                  'rights, please contact us at wagtracksg@gmail.com',
            ),
            TextSection(
              header: '7. Data Retention',
              body: 'We will retain your personal information for as long as '
                  'necessary to fulfill the purposes outlined in this Data '
                  'Policy, unless a longer retention period is required or '
                  'permitted by law.',
            ),
            TextSection(
              header: "8. Children's Privacy",
              body: 'Our services are not intended for children under the age '
                  'of 13. We do not knowingly collect personal information '
                  'from children.',
            ),
            TextSection(
              header: '9. Changes to This Policy',
              body: 'We may update this Data Policy from time to time. '
                  'We will notify you of any significant changes by posting '
                  'the new policy on our app.',
            ),
            TextSection(
              header: '10. Contact Us',
              body: 'If you have any questions or concerns about this Data '
                  'Policy, please contact us at wagtracksg@gmail.com',
            ),
          ],
        ),
      ),
    );
  }
}
