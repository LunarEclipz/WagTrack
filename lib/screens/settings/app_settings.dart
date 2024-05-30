import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/blank_page.dart';
import 'package:wagtrack/services/auth.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  // please change
  TextEditingController nameController = TextEditingController(text: 'XD');
  TextEditingController emailController = TextEditingController(text: ':3');
  TextEditingController phoneNumberController =
      TextEditingController(text: 'UwU');

  // TEMPORARY, NOT CONNECTED TO ANY STORAGE
  bool allowShareData = false;
  bool allowShareContact = false;
  bool allowCamera = true;
  bool allowGallery = true;

  List<String> locationList = <String>[
    'Yishun',
    'Jurong',
    'Tampines',
    'Bedok',
    'Hougang'
  ];
  String selectedLocation = 'Yishun';

  // Form key for personal info
  final _personalInfoFormKey = GlobalKey<FormState>();

  /// Save changes to personal info from form.
  void _savePersonalInfoChanges() {
    if (_personalInfoFormKey.currentState!.validate()) {
      // TODO: save changes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Application Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: DefaultTextStyle.merge(
        style: textStyles.bodyLarge,
        child: AppScrollablePage(children: [
          // SECTION: PERSONAL INFORMATION
          Text(
            'Personal Information',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          Text('Default Location', style: textStyles.bodySmall),
          AppDropdown(
            optionsList: locationList,
            selectedText: selectedLocation,
            onChanged: (String? value) {
              setState(() {
                selectedLocation = value!;
              });
            },
          ),
          const SizedBoxh10(),
          Form(
            key: _personalInfoFormKey,
            child: Column(children: [
              AppTextFormField(
                controller: nameController,
                hintText: 'Name',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBoxh10(),
              AppTextFormField(
                controller: emailController,
                hintText: 'Email',
                prefixIcon: const Icon(Icons.mail_outline),
              ),
              const SizedBoxh10(),
              AppTextFormField(
                controller: phoneNumberController,
                hintText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_android_outlined),
              ),
            ]),
          ),

          const SizedBoxh10(),
          // Save Personal Info Changes Button
          InkWell(
            onTap: () => _savePersonalInfoChanges(),
            child: Container(
              width: 200,
              height: 30,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBoxh20(),
          // SECTION: DATA CONSENT
          Text(
            'Data Consent',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.info, color: colorScheme.primary),
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child:
                    Text('Allow sharing of data to WagTrack Community & AVS'),
              ),
              AppSwitch(
                  value: allowShareData,
                  onChanged: (value) => setState(() => allowShareData = value)),
            ],
          ),
          const SizedBoxh10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.info, color: colorScheme.primary),
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child: Text(
                    'Allow sharing of your contact details for critical follow ups'),
              ),
              AppSwitch(
                  value: allowShareContact,
                  onChanged: (value) =>
                      setState(() => allowShareContact = value)),
            ],
          ),
          const SizedBoxh20(),
          // SECTION: APP PERMISSIONS
          Text(
            'App Permissions',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Camera'),
              AppSwitch(
                  value: allowCamera,
                  onChanged: (value) => setState(() => allowCamera = value)),
            ],
          ),
          const SizedBoxh10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gallery'),
              AppSwitch(
                  value: allowGallery,
                  onChanged: (value) => setState(() => allowGallery = value)),
            ],
          ),
          const SizedBoxh20(),
          // SECTION: LEGAL
          Text(
            'Legal',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          const AppTextOnTap(
            onTap: BlankPage(),
            text: Text('Terms'),
          ),
          const SizedBoxh10(),
          const AppTextOnTap(
            onTap: BlankPage(),
            text: Text('Data Policy'),
          ),
          const SizedBoxh10(),
          const AppTextOnTap(
            onTap: BlankPage(),
            text: Text('Report Vulnerabilities'),
          ),
          const SizedBoxh20(),
          // SECTION: SUPPORT
          Text(
            'Support',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          const AppTextOnTap(
            onTap: BlankPage(),
            text: Text('Frequently Asked Questions'),
          ),
          const SizedBoxh20(),
          // LOGOUT BUTTON
          Center(
            child: InkWell(
              onTap: () {
                context.read<AuthenticationService>().signOutUser();
                Navigator.pop(context);
              },
              child: Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Text(
                    'Log Out',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
