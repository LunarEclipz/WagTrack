import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/authorisation/authenticate.dart';
import 'package:wagtrack/screens/settings/data_policy_page.dart';
import 'package:wagtrack/screens/settings/delete_settings.dart';
import 'package:wagtrack/screens/settings/faqs_page.dart';
import 'package:wagtrack/screens/settings/report_vulnerabilities_page.dart';
import 'package:wagtrack/screens/settings/terms_page.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart' as dropdown_options;
import 'package:wagtrack/shared/themes.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  // Text controllers
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController phoneNumberController = TextEditingController(text: '');

  // Settings values
  late bool allowShareData = false;
  late bool allowShareContact = false;
  late bool allowCamera = false;
  late bool allowGallery = false;
  late String selectedLocation = '';

  // Temp location list
  List<String> locationList = dropdown_options.locationList;

  // Form key for personal info
  final _personalInfoFormKey = GlobalKey<FormState>();

  /// Initialise state
  @override
  void initState() {
    super.initState();

    /// load settings values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);
      // Load initial value if needed, e.g., from a service or API
      _loadSavedValues(userService);
    });
  }

  /// Load settings values
  void _loadSavedValues(UserService userService) async {
    setState(() {
      // USER VALUES
      nameController.text = userService.user.name ?? '';
      emailController.text = userService.user.email ?? '';
      phoneNumberController.text = userService.user.phoneNumber ?? '';
      selectedLocation = userService.user.defaultLocation ?? '';
      allowShareData = userService.user.allowShareData;
      allowShareContact = userService.user.allowShareContact;

      // DEVICE VALUES
      allowCamera = userService.user.allowCamera;
      allowGallery = userService.user.allowGallery;
    });
  }

  /// Save changes that need to be saved manually (with a button press).
  ///
  /// To minimise repeated api whenever boolean user data is changed.
  ///
  /// TODO change saving of boolean to leaving the settings screen?
  void _saveChangesManual(UserService userService) async {
    if (_personalInfoFormKey.currentState!.validate()) {
      // Save personal info values
      userService.setParams(
        name: nameController.text,
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        defaultLocation: selectedLocation,
        allowShareData: allowShareData,
        allowShareContact: allowShareContact,
      );

      await userService.updateUserInDb();

      // Tell user data is saved
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved!')),
      );
    }
  }

  /// Save changes to data that can be saved on every change (local)
  void _saveChangesAuto(UserService userService) async {
    userService.setParams(
      allowCamera: allowCamera,
      allowGallery: allowGallery,
    );

    await userService.updateLocalPrefs();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final UserService userService = context.watch<UserService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
          // Text('Currently selected: $selectedLocation'),
          AppDropdown(
              optionsList: locationList,
              selectedText: selectedLocation,
              onChanged: (String? value) {
                setState(() {
                  selectedLocation = value!;
                });
              },
              hint: const Text('Please select a location...')),
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
                validator: (value) => !context
                        .read<AuthenticationService>()
                        .isEmailValidEmail(value!)
                    ? 'Please enter a valid email'
                    : null,
              ),
              const SizedBoxh10(),
              AppTextFormField(
                controller: phoneNumberController,
                hintText: 'Phone Number',
                prefixIcon: SizedBox(
                  width: 72,
                  // height: 24,
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 10, left: 0),
                        child: Icon(Icons.phone_android_outlined),
                      ),
                      Text(
                        '+65 ',
                        style: textStyles.bodyLarge?.copyWith(
                            color: AppTheme.customColors.secondaryText),
                      )
                    ],
                  ),
                ),
                validator: (String? value) =>
                    !RegExp(r'^[0-9]{8}$').hasMatch(value!)
                        ? 'Please enter a valid Singapore phone number'
                        : null,
              ),
            ]),
          ),

          const SizedBoxh10(),
          // Save Personal Info Changes Button
          InkWell(
            onTap: () => _saveChangesManual(userService),
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
                  onChanged: (value) => setState(() {
                        allowShareData = value;
                        _saveChangesAuto(userService);
                      })),
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
                  onChanged: (value) => setState(() {
                        allowShareContact = value;
                        _saveChangesAuto(userService);
                      })),
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
                  onChanged: (value) => setState(() {
                        allowCamera = value;
                        _saveChangesAuto(userService);
                      })),
            ],
          ),
          const SizedBoxh10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gallery'),
              AppSwitch(
                  value: allowGallery,
                  onChanged: (value) => setState(() {
                        allowGallery = value;
                        _saveChangesAuto(userService);
                      })),
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
            onTap: TermsPage(),
            text: Text('Terms'),
          ),
          const SizedBoxh10(),
          const AppTextOnTap(
            onTap: DataPolicyPage(),
            text: Text('Data Policy'),
          ),
          const SizedBoxh10(),
          const AppTextOnTap(
            onTap: ReportVulnerabilities(),
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
            onTap: FaqsPage(),
            text: Text('Frequently Asked Questions'),
          ),
          const SizedBoxh10(),
          const AppTextOnTap(
            onTap: DeletionSettings(),
            text: Text('Reset Settings'),
          ),
          const SizedBoxh20(),
          // LOGOUT BUTTON
          Center(
            child: InkWell(
              onTap: () {
                context.read<AuthenticationService>().signOutUser();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Authenticate()),
                  (Route<dynamic> route) => false,
                );
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
