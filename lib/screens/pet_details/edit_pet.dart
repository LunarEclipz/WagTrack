import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/user_model.dart';
import 'package:wagtrack/screens/pet_details/add_pet.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/components/button_components.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/utils.dart';

/// Pet editing page
///
/// Note: `RoleRow` and `PetType` are imported from `add_pet.dart` to avoid
/// unnecessary duplication of code.
class EditPetPage extends StatefulWidget {
  final Pet petData;

  const EditPetPage({super.key, required this.petData});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  // Form key for all pet fields
  final _petInputFormKey = GlobalKey<FormState>();

  late String? uid;
  late String? username;

  late Pet selectedPet;

  PetType? selectedPetType;
  late String selectedLocation = "";
  late String selectedSex = "Male";
  late String selectedSpecies = "Dog";
  late bool isBirthdaySet = false;
  late DateTime birthdayDateTime;

  late bool isApptDateSet = false;

  // TODO changing this is broken (not set) because I have no bloody idea how it works
  late DateTime apptDateTime;

  late List<Caretaker> caretakers = [];

  /// file of profile picture of pet. Only gets set if the image is changed.
  File? _imageFile;
  final _picker = ImagePicker();

  TextEditingController nameController = TextEditingController(text: null);
  TextEditingController breedController = TextEditingController(text: null);

  TextEditingController descController = TextEditingController(text: null);
  TextEditingController idController = TextEditingController(text: null);
  TextEditingController weightController = TextEditingController(text: null);

  TextEditingController usersController = TextEditingController(text: "");

  // CARETAKER MODE
  /// A pet that is selected that the user is attaching themselves as a caretaker to
  Pet? caretakerModeSelectedPet;

  /// whether there is a pet in caretaker mode
  bool get caretakerModeHasSelectedPet => caretakerModeSelectedPet != null;

  setPetType(PetType? pType) {
    setState(() {
      if (pType == selectedPetType) {
        selectedPetType = null;
      } else {
        selectedPetType = pType;
      }
    });
  }

  // load details of the pet to be edited
  @override
  void initState() {
    super.initState();
    final petData = widget.petData;
    selectedPet = petData;

    // load userService to get default params
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);
      final petService = Provider.of<PetService>(context, listen: false);

      // check for role
      String? userRole = petService.checkUserPetRole(
        petID: petData.petID ?? "",
        userID: userService.user.uid,
      );

      setState(() {
        if (userRole != null && userRole.toLowerCase() == "main") {
          // main user
          caretakerModeSelectedPet = null;
        } else {
          // else, set user as caretaker - shouldn't be able to edit fields.
          caretakerModeSelectedPet = selectedPet;
        }

        debugPrint('User role: $userRole');
      });
    });

    setState(() {
      // set pet type - yes it is pain
      if (petData.petType == "personal") {
        selectedPetType = PetType.personal;
      } else {
        selectedPetType = PetType.community;
      }

      // set birthday and apptdate booleans (why T.T)
      isBirthdaySet = true; // always true
      // TODO WHY THE FUCK IS THERE NO APPOINTMENT DATE
      // isApptDateSet = petData.appo != null;

      birthdayDateTime = selectedPet.birthDate;

      // set data
      selectedLocation = selectedPet.location;
      nameController.text = selectedPet.name;
      breedController.text = selectedPet.breed ?? "";
      descController.text = selectedPet.description;
      idController.text = selectedPet.idNumber;
      weightController.text = selectedPet.weight[0].value;
      selectedSex = selectedPet.sex;
      selectedSpecies = selectedPet.species;

      // load caretakers
      caretakers = selectedPet.caretakers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // final CustomColors customColors = AppTheme.customColors;

    final UserService userService = context.watch<UserService>();
    final PetService petService = context.watch<PetService>();

    uid = userService.user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Pet',
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
          // DEBUG ONLY stuff
          showDebugInfo(context),
          // showDebugFillFieldsButton(context),

          // Section B : LOCATION
          // show for all pets
          if (selectedPetType != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBoxh20(),
                Text(
                  'Location',
                  style: textStyles.headlineMedium,
                ),
                const SizedBoxh10(),
                Text(
                  'Alerts in this location will be prioritised.',
                  style: textStyles.bodyMedium,
                ),
                const SizedBoxh10(),
                AppDropdown(
                  enabled: !caretakerModeHasSelectedPet,
                  optionsList: locationList,
                  selectedText: selectedLocation,
                  onChanged: (String? value) {
                    setState(() {
                      selectedLocation = value!;
                    });
                  },
                ),
              ],
            ),

          // Section C : Pet Information

          // Main pet info section
          if (selectedPetType != null)
            Form(
              key: _petInputFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBoxh20(),
                  Text(
                    'Pet Information',
                    style: textStyles.headlineMedium,
                  ),
                  const SizedBoxh10(),

                  if (_imageFile == null)
                    InkWell(
                      onTap: () async => _pickImageFromGallery(),
                      child: CircleAvatar(
                        backgroundImage: Image.network(
                          selectedPet.imgPath!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ).image,
                        radius: 100,
                      ),
                    ),
                  if (_imageFile != null)
                    InkWell(
                        onTap: () async => _pickImageFromGallery(),
                        child: CircleAvatar(
                            radius: 100,
                            backgroundImage: Image.file(_imageFile!).image)),
                  AppTextFormField(
                    enabled: !caretakerModeHasSelectedPet,
                    controller: nameController,
                    hintText: 'Name',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  AppTextFormField(
                    enabled: !caretakerModeHasSelectedPet,
                    controller: descController,
                    hintText: 'Description',
                    prefixIcon: const Icon(Icons.description),
                    showOptional: true,
                    validator: (value) =>
                        InputStringValidators.emptyValidator(value),
                  ),
                  AppTextFormField(
                    enabled: !caretakerModeHasSelectedPet,
                    controller: breedController,
                    hintText: 'Breed',
                    prefixIcon: const Icon(Icons.description),
                    showOptional: true,
                    validator: (value) =>
                        InputStringValidators.emptyValidator(value),
                  ),
                  // Text(
                  //   'Has this community pet been registered?',
                  //   style: textStyles.bodyMedium,
                  // ),
                  const SizedBoxh20(),
                  AppDropdown(
                    enabled: !caretakerModeHasSelectedPet,
                    optionsList: sexList,
                    selectedText: selectedSex,
                    onChanged: (String? value) {
                      setState(() {
                        selectedSex = value!;
                      });
                    },
                  ),
                  const SizedBoxh20(),

                  AppDropdown(
                    enabled: !caretakerModeHasSelectedPet,
                    optionsList: speciesList,
                    selectedText: selectedSpecies,
                    onChanged: (String? value) {
                      setState(() {
                        selectedSpecies = value!;
                      });
                    },
                  ),

                  // Section C : Pet Details
                  const SizedBoxh20(),
                  Text(
                    'Pet Details',
                    style: textStyles.headlineMedium,
                  ),
                  AppTextFormField(
                    enabled: !caretakerModeHasSelectedPet,
                    controller: idController,
                    hintText: 'Microchip Number',
                    prefixIcon: const Icon(Icons.card_membership_rounded),
                  ),
                  const SizedBoxh10(),
                  AppTextFormField(
                    enabled: !caretakerModeHasSelectedPet,
                    controller: weightController,
                    hintText: 'Weight',
                    prefixIcon: const Icon(Icons.scale_rounded),
                    showOptional: true,
                    suffixString: "kg",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        // if empty don't do anything (since optional)
                        return null;
                      }

                      if (!_isDouble(value) || value[0] == "-") {
                        // Input string is not numeric
                        // Also checking if negative,
                        // easier than just converting it to a double
                        return "Please enter a valid weight";
                      }

                      return null;
                    },
                  ),
                  const SizedBoxh10(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Birthday
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(1999, 1, 1),
                                maxTime: DateTime.now(), onConfirm: (date) {
                              setState(() {
                                birthdayDateTime = date;
                                isBirthdaySet = true;
                              });
                            }, onCancel: () {
                              setState(() {
                                isBirthdaySet = false;
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.en);
                          },
                          child: Column(
                            children: [
                              Card(
                                color: Colors.white,
                                child: SizedBox(
                                  width: 170,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      8,
                                    ),
                                    child: isBirthdaySet == false
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Set Birthday",
                                                    style: textStyles.bodyLarge!
                                                        .copyWith(
                                                            color: colorScheme
                                                                .primary),
                                                  ),
                                                  Icon(Icons.cake_rounded,
                                                      size: 20,
                                                      color:
                                                          colorScheme.primary),
                                                ],
                                              ),
                                              Text(
                                                "Mandatory*",
                                                style: textStyles.bodyMedium!
                                                    .copyWith(
                                                        color: colorScheme
                                                            .primary),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Birthday",
                                                    style: textStyles.bodyLarge!
                                                        .copyWith(
                                                            color: colorScheme
                                                                .primary),
                                                  ),
                                                  Icon(Icons.cake_rounded,
                                                      size: 20,
                                                      color:
                                                          colorScheme.primary),
                                                ],
                                              ),
                                              Text(
                                                  formatDateTime(
                                                          birthdayDateTime)
                                                      .date,
                                                  style: textStyles.labelLarge),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Next Appointment
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            DateTime now = DateTime.now();

                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: now,
                                maxTime:
                                    DateTime(now.year + 10, now.month, now.day),
                                onConfirm: (date) {
                              setState(() {
                                apptDateTime = date;
                                isApptDateSet = true;
                              });
                            }, onCancel: () {
                              setState(() {
                                isApptDateSet = false;
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.en);
                          },
                          child: Column(
                            children: [
                              Card(
                                color: Colors.white,
                                child: SizedBox(
                                  width: 170,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      8,
                                    ),
                                    child: isApptDateSet == false
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Check Up",
                                                    style: textStyles.bodyLarge!
                                                        .copyWith(
                                                            color: colorScheme
                                                                .primary),
                                                  ),
                                                  Icon(
                                                      Icons
                                                          .calendar_month_rounded,
                                                      size: 20,
                                                      color:
                                                          colorScheme.primary),
                                                ],
                                              ),
                                              Text("(optional)",
                                                  style: textStyles.bodyMedium),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Check Up",
                                                    style: textStyles.bodyLarge!
                                                        .copyWith(
                                                            color: colorScheme
                                                                .primary),
                                                  ),
                                                  Icon(
                                                      Icons
                                                          .calendar_month_rounded,
                                                      size: 20,
                                                      color:
                                                          colorScheme.primary),
                                                ],
                                              ),
                                              Text(
                                                  formatDateTime(apptDateTime)
                                                      .date,
                                                  style: textStyles.labelLarge),
                                              Text(
                                                  formatDateTime(apptDateTime)
                                                      .time,
                                                  style: textStyles.labelLarge),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Caretaker/user editing section
          // Only shows if it's not a caretakerModeSelectedPet
          if (selectedPetType != null && !caretakerModeHasSelectedPet)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBoxh20(),
                Text(
                  'Ownership',
                  style: textStyles.headlineMedium,
                ),
                if (selectedPetType == PetType.personal)
                  // Text(
                  //   'If this pet has already been added by someone, request role from them.',
                  //   style: textStyles.bodyMedium,
                  // ),
                  AppTextFormField(
                    controller: usersController,
                    hintText: 'User\'s Email',
                    prefixIcon: const Icon(Icons.person),
                    validator: (value) => !context
                            .read<AuthenticationService>()
                            .isEmailValidEmail(value!)
                        ? 'Invalid email'
                        : null,
                  ),
                InkWell(
                  onTap: () async {
                    List<AppUser> users =
                        await userService.getUsersFromDbByName(
                            uid: userService.user.uid,
                            email: usersController.text);

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Users"),
                            content: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      '${users.length} matching users.',
                                      style: textStyles.bodyMedium!
                                          .copyWith(color: colorScheme.primary),
                                    ),
                                  ),
                                  Column(
                                    children:
                                        List.generate(users.length, (index) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            caretakers.add(
                                              Caretaker(
                                                  username: users[index].name!,
                                                  uid: users[index].uid,
                                                  role: "Caretaker"),
                                            );
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: DropdownMenuItem(
                                            child: Text(users[index].name!)),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: colorScheme.primary,
                        ),
                        Text(
                          'Search',
                          style: textStyles.bodyMedium!
                              .copyWith(color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                // RoleRow(
                //     username: userService.user.name!,
                //     popUser: () {},
                //     role: "Main"),
                Column(
                  children: List.generate(caretakers.length, (index) {
                    return Column(
                      children: [
                        const SizedBoxh10(),
                        RoleRow(
                            username: caretakers[index].username,
                            popUser: () {
                              setState(() {
                                caretakers.remove(caretakers[index]);
                              });
                            },
                            role: caretakers[index].role),
                      ],
                    );
                  }),
                ),
              ],
            ),

          const SizedBoxh20(), const SizedBoxh20(),

          // Final section for ADD PET button
          if (selectedPetType != null)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: AppButtonLarge(
                  onTap: () {
                    if (_petInputFormKey.currentState!.validate() &&
                        isBirthdaySet &&
                        selectedSpecies != "") {
                      List<String> caretakerIDs =
                          caretakers.map((caretaker) => caretaker.uid).toList();

                      petService.updatePet(
                        id: widget.petData.petID ?? "",

                        // image file is null if unchanged and won't be reupdated
                        img: _imageFile,
                        location: selectedLocation,
                        name: nameController.text,
                        description: descController.text,
                        sex: selectedSex,
                        species: selectedSpecies,
                        petType: selectedPetType?.string ?? '',
                        idNumber: idController.text,
                        breed: breedController.text,
                        birthDate: birthdayDateTime,
                        weight: weightController.text == ""
                            ? [
                                DateTimeStringPair(
                                    dateTime: DateTime.now(), value: "0")
                              ]
                            : [
                                DateTimeStringPair(
                                    dateTime: DateTime.now(),
                                    value: weightController.text)
                              ],
                        caretakers: caretakers,
                        caretakerIDs: caretakerIDs,
                        sessionRecords: isApptDateSet
                            ? [
                                DateTimeStringPair(
                                    dateTime: apptDateTime,
                                    value: "Next Appointment")
                              ]
                            : [],
                      );
                      Navigator.pop(context);
                    }
                    if (caretakerModeHasSelectedPet) {
                      // and nothing happens?
                      Navigator.pop(context);
                    }
                  },
                  width: 300,
                  height: 40,
                  text: 'Update Pet',
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // Future<void> _pickImageFromCamera() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() => _imageFile = File(pickedFile.path));
  //   }
  // }
  /// A section used to just show a bunch of debug info
  Widget showDebugInfo(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    if (!kReleaseMode) {
      return DefaultTextStyle(
          style: textStyles.bodySmall!,
          child: Column(
            children: [
              Text(
                'THIS IS SHOWN IN DEBUG MODE ONLY',
                style: textStyles.titleSmall,
              ),
              Text('caretakerModeSelectedPet: $caretakerModeSelectedPet'),
              Text('caretakerModeHasSelectedPet: $caretakerModeHasSelectedPet'),
              Text('Length of caretakers: ${caretakers.length}'),
              const SizedBoxh10()
            ],
          ));
    }

    return Container();
  }

  bool _isDouble(String str) {
    return double.tryParse(str) != null;
  }
}
