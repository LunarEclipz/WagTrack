// Adding of Personal and Community Pets
// Breed, Birthdate, weight, Appointment Date, Caretakers, Community Pet are milestone 2 Features

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/user_model.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:wagtrack/shared/utils.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  late String? uid;
  late String? username;

  late String petType = "";
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

  // Placeholder. By milestone 2, this will be in backend.
  late String selectedCPet = "Pet 1 in Region X";
  final List<String> communityPets = [
    "Pet 1 in Region X",
    "Pet 2 in Region X",
    "Pet 3 in Region X",
  ];

  setPetType(String pType) {
    setState(() {
      if (pType == petType) {
        petType = "";
      } else {
        petType = pType;
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final CustomColors customColors = AppTheme.customColors;

    final UserService userService = context.watch<UserService>();
    uid = userService.user.uid;

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
          // Section A : Pet Type
          Text(
            'My Pet is a ...',
            style: textStyles.headlineMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    setPetType("personal");
                  },
                  child: Card(
                    color: petType == "personal"
                        ? customColors.green
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            color: petType == "personal"
                                ? Colors.white
                                : Colors.black,
                          ),
                          Text("Personal\nPet",
                              style: textStyles.bodyMedium!.copyWith(
                                color: petType == "personal"
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
                    setPetType("community");
                  },
                  child: Card(
                    color: petType == "community"
                        ? customColors.green
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            color: petType == "community"
                                ? Colors.white
                                : Colors.black,
                          ),
                          Text("Community\nPet",
                              style: textStyles.bodyMedium!.copyWith(
                                color: petType == "community"
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
          if (petType != "")
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

          // if (petType == "community")
          //   Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       const SizedBoxh10(),
          //       Text(
          //         'Has this community pet been registered?',
          //         style: textStyles.bodyMedium,
          //       ),
          //       const SizedBoxh10(),
          //       AppDropdown(
          //         optionsList: communityPets,
          //         selectedText: selectedCPet,
          //         onChanged: (String? value) {
          //           setState(() {
          //             selectedCPet = value!;
          //           });
          //         },
          //       ),
          //     ],
          //   ),

          // Section B : Pet Information
          if (petType != "")
            Column(
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
                      child: const CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          size: 100,
                        ),
                      ))
                else
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
                ),
                AppTextFormField(
                  controller: breedController,
                  hintText: 'Breed (optional)',
                  prefixIcon: const Icon(Icons.description),
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
                              minTime: DateTime(2024, 1, 1),
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
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2024, 1, 1),
                              maxTime: DateTime(2040, 1, 1), onConfirm: (date) {
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
                // Section C : Pet Details
                const SizedBoxh20(),
                Text(
                  'Ownership',
                  style: textStyles.headlineMedium,
                ),
                if (petType == "personal")
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
                RoleRow(
                    username: userService.user.name!,
                    popUser: () {},
                    role: "Owner"),

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
                            selectedCPet != "" &&
                            selectedSpecies != "") {
                          Pet pet = Pet(
                            location: selectedLocation,
                            name: nameController.text,
                            uid: uid!,
                            description: descController.text,
                            sex: selectedSex,
                            species: selectedSpecies,
                            petType: petType,
                            idNumber: idController.text,
                            breed: breedController.text,
                            nextAppt:
                                apptDate ? apptDateTime : DateTime(1, 1, 1),
                            posts: 0,
                            fans: 0,
                            birthDate: birthdayDateTime,
                            weight: weightController.text == ""
                                ? 0
                                : int.parse(weightController.text),
                            caretakers: caretakers,
                          );
                          PetService().addPet(
                              pet: pet,
                              img: _imageFile,
                              uid: userService.user.uid);
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
          child: widget.role == "Owner"
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
            flex: widget.role == "Owner" ? 2 : 1,
            child: widget.role == "Owner"
                ? AppDropdown(
                    optionsList: const ["Owner"],
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
