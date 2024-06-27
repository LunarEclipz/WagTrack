import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/user_model.dart';
import 'package:wagtrack/screens/authorisation/authenticate.dart';
import 'package:wagtrack/services/user_service.dart';
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

  /// Saves all changes from the onboarding form
  void _saveAllChanges(UserService userService) async {
    // validation is not done here.
    userService.user.onboard(
      phoneNumber: phoneNumberController.text,
      defaultLocation: selectedLocation,
      allowShareData: allowShareData,
      allowShareContact: allowShareContact,
      allowCamera: allowCamera,
      allowGallery: allowGallery,
    );

    await userService.updateUserInDb();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final UserService userService = context.watch<UserService>();
    final AppUser user = userService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          // TODO: change!!!
          'Welcome!',
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
          const SizedBoxh10(),
          Text('Hello, ${user.name ?? ''}!'),
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
                if (_personalInfoFormKey.currentState!.validate()) {
                  _saveAllChanges(userService);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Authenticate()),
                    (Route<dynamic> route) => false,
                  );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const Authenticate()),
                  // );
                }
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
