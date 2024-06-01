import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/screens/home/home.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart' as dropdown_options;
import 'package:wagtrack/shared/themes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // username, to be displayed.
  String? name;

  // Text controllers
  TextEditingController phoneNumberController = TextEditingController(text: '');

  // Settings values
  late bool allowShareData = false;
  late bool allowShareContact = false;
  late bool allowCamera = false;
  late bool allowGallery = false;
  late String selectedLocation = '';

  // location list
  List<String> locationList = dropdown_options.locationList;

  // Form key for personal info
  final _personalInfoFormKey = GlobalKey<FormState>();

  /// Initialise state
  // @override
  // void initState() {
  //   super.initState();
  // }

  /// Saves all changes from the onboarding form
  ///
  /// Saves to shared preferences
  void _saveAllChanges() async {
    if (_personalInfoFormKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Save personal info values
      await prefs.setString('user_phone_number', phoneNumberController.text);
      await prefs.setString('user_location', selectedLocation);
      await prefs.setBool('user_allow_share_data', allowShareData);
      await prefs.setBool('user_allow_share_contact', allowShareContact);
      await prefs.setBool('device_allow_camera', allowCamera);
      await prefs.setBool('device_allow_gallery', allowGallery);

      // and set hasOnboarded to true!
      await prefs.setBool('user_has_onboarded', true);
    }
  }

  /// Loads username - MOVE TODO:
  void getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('user_name');
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          // TODO: change!!!
          'Welcome!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: DefaultTextStyle.merge(
        style: textStyles.bodyLarge,
        child: AppScrollablePage(children: [
          Text(
              '''Note: WagTrack data is currently stored locally on your device. 
As such, your data will persist between different accounts. and not be synced between different devices. 
          ''',
              style: textStyles.bodySmall),
          const SizedBoxh10(),
          Text('Hello, ${name ?? ''}!'),
          const SizedBoxh10(),
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
                      })),
            ],
          ),
          const SizedBoxh20(),
          // SUBMIT BUTTON
          Center(
            child: InkWell(
              onTap: () {
                _saveAllChanges();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
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
                    'Get Started!',
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
