// Adding of Personal and Community Pets
// Breed, Birthdate, weight, Appointment Date, Caretakers, Community Pet are milestone 2 Features

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:image_picker/image_picker.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  late String? uid;

  late String petType = "";
  late String selectedLocation = "North";
  late String selectedSex = "Male";
  late String selectedSpecies = "Dog";
  late String selectedRole = "Owner";

  File? _imageFile;
  final _picker = ImagePicker();

  TextEditingController nameController = TextEditingController(text: null);
  TextEditingController descController = TextEditingController(text: null);
  TextEditingController idController = TextEditingController(text: null);
  TextEditingController weightController = TextEditingController(text: null);
  TextEditingController birthdateController = TextEditingController(text: null);

  TextEditingController ownersController =
      TextEditingController(text: "Damien");

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

  /// Get UID
  void getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
  }

  @override
  void initState() {
    super.initState();
    getUID();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final CustomColors customColors = AppTheme.customColors;

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
                // AppTextFormField(
                //   controller: weightController,
                //   hintText: 'Weight',
                //   prefixIcon: const Icon(Icons.scale_rounded),
                // ),
                // AppTextFormField(
                //   controller: birthdateController,
                //   hintText: 'Birthdate',
                //   prefixIcon: const Icon(Icons.cake_rounded),
                // ),
                // AppTextFormField(
                //   controller: nameController,
                //   hintText: 'Next Appointment Date',
                //   prefixIcon: const Icon(Icons.date_range_rounded),
                // ),
                // Section C : Pet Details
                const SizedBoxh20(),
                Text(
                  'Owners',
                  style: textStyles.headlineMedium,
                ),
                AppTextFormField(
                  controller: ownersController,
                  hintText: 'Owner Username',
                  prefixIcon: const Icon(Icons.person),
                ),
                const SizedBoxh20(),

                AppDropdown(
                  optionsList: rolesList,
                  selectedText: selectedRole,
                  onChanged: (String? value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                const SizedBoxh20(), const SizedBoxh20(),

                InkWell(
                  onTap: () {
                    if (nameController.text != "" &&
                        selectedLocation != "" &&
                        descController.text != "" &&
                        idController.text != "" &&
                        selectedCPet != "" &&
                        selectedRole != "" &&
                        selectedSpecies != "") {
                      Pet pet = Pet(
                          location: selectedLocation,
                          name: nameController.text,
                          uid: uid!,
                          description: descController.text,
                          sex: selectedRole,
                          species: selectedSpecies,
                          petType: petType,
                          idNumber: idController.text,
                          posts: 0,
                          fans: 0);
                      PetService().addPet(pet: pet);
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
