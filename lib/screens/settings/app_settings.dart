import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/screens/blank_page.dart';
import 'package:wagtrack/screens/settings/delete_settings.dart';
import 'package:wagtrack/services/auth.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
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
  // note that selectedLocation CAN be null.
  // Required for dropdown hint text to work.
  String? selectedLocation;

  // Temp location list
  // TODO: Should be imported from elsewhere
  List<String> locationList = <String>[
    'Yishun',
    'Jurong',
    'Tampines',
    'Bedok',
    'Hougang',
  ];

  // Form key for personal info
  final _personalInfoFormKey = GlobalKey<FormState>();

  /// Initialise state
  @override
  void initState() {
    super.initState();

    /// load settings values
    _loadSavedValues();
  }

  /// Load values from saved preferences
  void _loadSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // USER VALUES - local for the time being
      nameController.text = prefs.getString('user_name') ?? "";
      emailController.text = prefs.getString('user_email') ?? "";
      phoneNumberController.text = prefs.getString('user_phone_number') ?? "";
      selectedLocation = prefs.getString('user_location');
      selectedLocation = selectedLocation!.isNotEmpty ? selectedLocation : null;
      allowShareData = prefs.getBool('user_allow_share_data') ?? false;
      allowShareContact = prefs.getBool('user_allow_share_contact') ?? false;

      // DEVICE VALUES
      allowCamera = prefs.getBool('device_allow_camera') ?? false;
      allowGallery = prefs.getBool('device_allow_gallery') ?? false;
    });
  }

  /// Save changes to personal info from form.
  ///
  /// Saves to shared preferences
  void _savePersonalInfoChanges() async {
    if (_personalInfoFormKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Save personal info values
      await prefs.setString('user_name', nameController.text);
      await prefs.setString('user_email', emailController.text);
      await prefs.setString('user_phone_number', phoneNumberController.text);
      await prefs.setString('user_location', selectedLocation!);
      // await prefs.setBool('user_allow_share_data', allowShareData);
      // await prefs.setBool('user_allow_share_contact', allowShareContact);
      // await prefs.setBool('device_allow_camera', allowCamera);
      // await prefs.setBool('device_allow_gallery', allowGallery);

      // Tell user data is saved
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved!')),
      );
    }
  }

  /// Save changes to boolean data
  void _saveBooleanPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_allow_share_data', allowShareData);
    await prefs.setBool('user_allow_share_contact', allowShareContact);
    await prefs.setBool('device_allow_camera', allowCamera);
    await prefs.setBool('device_allow_gallery', allowGallery);
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
                  width: 90,
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 10, left: 12),
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
                  onChanged: (value) => setState(() {
                        allowShareData = value;
                        _saveBooleanPreferences();
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
                        _saveBooleanPreferences();
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
                        _saveBooleanPreferences();
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
                        _saveBooleanPreferences();
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
