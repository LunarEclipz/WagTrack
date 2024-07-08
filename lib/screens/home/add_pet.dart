// Adding of Personal and Community Pets
// Breed, Birthdate, weight, Appointment Date, Caretakers, Community Pet are milestone 2 Features

import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/user_model.dart';
import 'package:wagtrack/services/logging.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:wagtrack/shared/utils.dart';

/// Pet types
enum PetType {
  personal("personal"),
  community("community");

  final String string;

  const PetType(this.string);
}

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  late String? uid;
  late String? username;

  late Pet? selectedPet;

  PetType? petType;
  late String selectedLocation = "";
  late String selectedSex = "Male";
  late String selectedSpecies = "Dog";
  late bool birthday = false;
  late DateTime birthdayDateTime;

  late bool apptDate = false;
  late DateTime apptDateTime;

  late List<Caretaker> caretakers = [];

  File? _imageFile;
  final _picker = ImagePicker();

  TextEditingController nameController = TextEditingController(text: null);
  TextEditingController breedController = TextEditingController(text: null);

  TextEditingController descController = TextEditingController(text: null);
  TextEditingController idController = TextEditingController(text: null);
  TextEditingController weightController = TextEditingController(text: null);

  TextEditingController usersController = TextEditingController(text: "");

  late Pet? caretakerMode;

  setPetType(PetType? pType) {
    setState(() {
      if (pType == petType) {
        petType = null;
      } else {
        petType = pType;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    selectedPet = null;
    caretakerMode = null;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final CustomColors customColors = AppTheme.customColors;

    final UserService userService = context.watch<UserService>();
    final PetService petService = context.watch<PetService>();

    uid = userService.user.uid;
    if (selectedPet != null) {
      // means a pet is currently selected
      setState(() {
        // TODO: Zee need your help, if caretakeMode, all these fields should be disabled
        nameController.text = selectedPet!.name;
        breedController.text = selectedPet!.breed ?? "";
        descController.text = selectedPet!.description;
        idController.text = selectedPet!.idNumber;
        weightController.text = selectedPet!.weight[0].value;
        selectedSex = selectedPet!.sex;
        selectedSpecies = selectedPet!.species;
      });

      caretakerMode = selectedPet!;
      selectedPet = null;
    }

    // now set the selected location to the default user location.
    selectedLocation = userService.user.defaultLocation!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Pet',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: DefaultTextStyle.merge(
        style: textStyles.bodyLarge,
        child: AppScrollablePage(children: [
          // DEBUG ONLY BUTTON
          showDebugFillFieldsButton(context),

          // Section A : Pet Type
          Text(
            'My Pet is a ...',
            style: textStyles.headlineMedium,
          ),

          // choosing pet Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    setPetType(PetType.personal);
                  },
                  child: Card(
                    color: petType == PetType.personal
                        ? customColors.green
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            color: petType == PetType.personal
                                ? Colors.white
                                : Colors.black,
                          ),
                          Text("Personal\nPet",
                              style: textStyles.bodyMedium!.copyWith(
                                color: petType == PetType.personal
                                    ? Colors.white
                                    : Colors.black,
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    setPetType(PetType.community);
                  },
                  child: Card(
                    color: petType == PetType.community
                        ? customColors.green
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            color: petType == PetType.community
                                ? Colors.white
                                : Colors.black,
                          ),
                          Text("Community\nPet",
                              style: textStyles.bodyMedium!.copyWith(
                                color: petType == PetType.community
                                    ? Colors.white
                                    : Colors.black,
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Section B : Pet Type
          if (petType == PetType.personal) // personal
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
          if (petType == PetType.community)
            InkWell(
              onTap: () async {
                List<Pet> pets = await petService.getAllCommunityPetsByRegion(
                    location: selectedLocation);

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Pets"),
                        content: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  '${pets.length} pets in $selectedLocation.',
                                  style: textStyles.bodyMedium!
                                      .copyWith(color: colorScheme.primary),
                                ),
                              ),
                              Column(
                                children: List.generate(pets.length, (index) {
                                  return Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedPet = pets[index];
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: DropdownMenuItem(
                                            child: Row(
                                          children: [
                                            pets[index].imgPath == null
                                                ? const CircleAvatar(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 41, 41, 41),
                                                    radius: 60,
                                                  )
                                                : CircleAvatar(
                                                    backgroundImage:
                                                        Image.network(
                                                      pets[index].imgPath!,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    ).image,
                                                    radius: 60,
                                                  ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    pets[index].name,
                                                    style: textStyles.bodyLarge,
                                                  ),
                                                  Text(pets[index].description),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )),
                                      ),
                                    ],
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
                      ' Search for Community Pets in $selectedLocation',
                      style: textStyles.bodyMedium!
                          .copyWith(color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),

          // Section C : Pet Information
          if (petType != null && caretakerMode != null)
            InkWell(
              onTap: () {
                setState(() {
                  caretakerMode = null;
                });
              },
              child: Chip(
                backgroundColor: customColors.pastelBlue,
                side: const BorderSide(style: BorderStyle.none),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      caretakerMode!.name,
                      style: textStyles.bodyLarge,
                    ),
                    const Icon(
                      Icons.close,
                    )
                  ],
                ),
              ),
            ),
          if (petType != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBoxh20(),
                Text(
                  'Pet Information',
                  style: textStyles.headlineMedium,
                ),
                const SizedBoxh10(),
                if (caretakerMode != null)
                  caretakerMode!.imgPath == null
                      ? const CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 41, 41, 41),
                          radius: 100,
                        )
                      : CircleAvatar(
                          backgroundImage: Image.network(
                            caretakerMode!.imgPath!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ).image,
                          radius: 100,
                        ),

                if (_imageFile == null && caretakerMode == null)
                  InkWell(
                      onTap: () async => _pickImageFromGallery(),
                      child: const CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          size: 100,
                        ),
                      )),
                if (_imageFile != null && caretakerMode == null)
                  InkWell(
                      onTap: () async => _pickImageFromGallery(),
                      child: CircleAvatar(
                          radius: 100,
                          backgroundImage: Image.file(_imageFile!).image)),
                AppTextFormField(
                  controller: nameController,
                  hintText: 'Name',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                AppTextFormField(
                  controller: descController,
                  hintText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  showOptional: true,
                ),
                AppTextFormField(
                  controller: breedController,
                  hintText: 'Breed',
                  prefixIcon: const Icon(Icons.description),
                  showOptional: true,
                ),
                // Text(
                //   'Has this community pet been registered?',
                //   style: textStyles.bodyMedium,
                // ),
                const SizedBoxh20(),
                AppDropdown(
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
                  controller: idController,
                  hintText: 'Microchip Number',
                  prefixIcon: const Icon(Icons.card_membership_rounded),
                ),
                const SizedBoxh10(),
                AppTextFormField(
                  controller: weightController,
                  hintText: 'Weight',
                  prefixIcon: const Icon(Icons.scale_rounded),
                  showOptional: true,
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
                              birthday = true;
                            });
                          }, onCancel: () {
                            setState(() {
                              birthday = false;
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
                                  child: birthday == false
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Set Birthday",
                                              style: textStyles.bodyLarge!
                                                  .copyWith(
                                                      color:
                                                          colorScheme.primary),
                                            ),
                                            Icon(Icons.cake_rounded,
                                                size: 20,
                                                color: colorScheme.primary),
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
                                                    color: colorScheme.primary),
                                              ],
                                            ),
                                            Text(
                                                formatDateTime(birthdayDateTime)
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
                              apptDate = true;
                            });
                          }, onCancel: () {
                            setState(() {
                              apptDate = false;
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
                                  child: apptDate == false
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Check Up",
                                              style: textStyles.bodyLarge!
                                                  .copyWith(
                                                      color:
                                                          colorScheme.primary),
                                            ),
                                            Icon(Icons.calendar_month_rounded,
                                                size: 20,
                                                color: colorScheme.primary),
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
                                                    color: colorScheme.primary),
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
                if (caretakerMode == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBoxh20(),
                      Text(
                        'Ownership',
                        style: textStyles.headlineMedium,
                      ),
                      if (petType == PetType.personal)
                        Text(
                          'If this pet has already been added by someone, request role from them.',
                          style: textStyles.bodyMedium,
                        ),
                      AppTextFormField(
                        controller: usersController,
                        hintText: 'User\'s Email',
                        prefixIcon: const Icon(Icons.person),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            '${users.length} matching users.',
                                            style: textStyles.bodyMedium!
                                                .copyWith(
                                                    color: colorScheme.primary),
                                          ),
                                        ),
                                        Column(
                                          children: List.generate(users.length,
                                              (index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  caretakers.add(
                                                    Caretaker(
                                                        username:
                                                            users[index].name!,
                                                        uid: users[index].uid,
                                                        role: "Caretaker"),
                                                  );
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: DropdownMenuItem(
                                                  child:
                                                      Text(users[index].name!)),
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
                      RoleRow(
                          username: userService.user.name!,
                          popUser: () {},
                          role: "Main"),
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

                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        if (nameController.text != "" &&
                            selectedLocation != "" &&
                            descController.text != "" &&
                            idController.text != "" &&
                            birthday &&
                            selectedSpecies != "") {
                          if (petType == PetType.personal ||
                              caretakerMode == null) {
                            caretakers.add(Caretaker(
                                username: userService.user.name!,
                                uid: userService.user.uid,
                                role: "Main"));
                          }
                          List<String> caretakerIDs = caretakers
                              .map((caretaker) => caretaker.uid)
                              .toList();

                          Pet pet = Pet(
                            location: selectedLocation,
                            name: nameController.text,
                            description: descController.text,
                            sex: selectedSex,
                            species: selectedSpecies,
                            petType: petType?.string ?? '',
                            idNumber: idController.text,
                            breed: breedController.text,
                            posts: 0,
                            fans: 0,
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
                            vaccineRecords: [],
                            sessionRecords: apptDate
                                ? [
                                    DateTimeStringPair(
                                        dateTime: apptDateTime,
                                        value: "Next Appointment")
                                  ]
                                : [],
                          );
                          petService.addPet(
                              pet: pet,
                              img: _imageFile,
                              uid: userService.user.uid);
                          Navigator.pop(context);
                        }
                        if (caretakerMode != null) {
                          Navigator.pop(context);
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
                            'Add Pet',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

  /// Creates a button that is only shown when not in release mode that
  /// fills in fields automaticatically upon pressing.
  /// Used to quickly create a pet.
  ///
  /// Default pet name is 'AUTO-<random-number>'
  Widget showDebugFillFieldsButton(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (!kReleaseMode) {
      return InkWell(
        onTap: () {
          // setState to reset
          setState(() {
            nameController.text = "AUTO-${Random().nextInt(1000)}";
            selectedLocation =
                context.read<UserService>().user.defaultLocation ??
                    locationList[0];
            descController.text = "Automatically filled pet";
            idController.text = "0";
            breedController.text = "Untitled Breed";
            birthday = true;
            birthdayDateTime = DateTime.fromMillisecondsSinceEpoch(0);
          });

          AppLogger.d("[DEBUG]: Filled in pet fields");
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Text(
              'DEBUG: Fill Pet Fields',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class RoleRow extends StatefulWidget {
  final String username;
  final String role;
  final Function popUser;
  const RoleRow({
    super.key,
    required this.username,
    required this.popUser,
    required this.role,
  });

  @override
  State<RoleRow> createState() => _RoleListSRow();
}

class _RoleListSRow extends State<RoleRow> {
  late String selectedRole = "Caretaker";

  @override
  void initState() {
    super.initState();
    selectedRole = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
            flex: 2, child: Text(widget.username, style: textStyles.bodyLarge)),
        Flexible(
          flex: 2,
          child: widget.role == "Main"
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(),
                )
              : AppDropdown(
                  optionsList: rolesList,
                  selectedText: selectedRole,
                  onChanged: (String? value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
        ),
        Flexible(
            flex: widget.role == "Main" ? 2 : 1,
            child: widget.role == "Main"
                ? AppDropdown(
                    optionsList: const ["Main"],
                    selectedText: selectedRole,
                    onChanged: (String? value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  )
                : InkWell(
                    onTap: () {
                      widget.popUser();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.close_rounded),
                    ),
                  )),
      ],
    );
  }
}
