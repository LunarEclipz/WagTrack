import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/post_model.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/themes.dart';

class AddPostPage extends StatefulWidget {
  final Pet pet;
  const AddPostPage({super.key, required this.pet});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  late String selectedLocation = "";
  late String selectedPostCategory = "Play";

  late String? uid;
  late String? username;
  late bool visibility = true;

  List<XFile> _imageFiles = [];
  final _picker = ImagePicker();
  late int _carouselIndex = 0;

  // currentPet
  late Pet pet;
  // all other pets of this user
  late List<Pet> allOtherPets = [];
  // selected pets for this post
  late List<Pet> selectedPets = [];

  TextEditingController titleController = TextEditingController(text: null);
  TextEditingController captionController = TextEditingController(text: null);

  @override
  void initState() {
    super.initState();
    // load userService to get default params
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);
      final PetService petService =
          Provider.of<PetService>(context, listen: false);

      allOtherPets = petService.communityPets + petService.personalPets;
      allOtherPets.removeWhere((item) => item.petID == widget.pet.petID);
      setState(() {
        selectedLocation = userService.user.defaultLocation!;
      });
      selectedPets.add(widget.pet);
      // Set the selected location to the default user location.
    });
    _pickMultipleImages();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final CustomColors customColors = AppTheme.customColors;

    final UserService userService = context.watch<UserService>();
    uid = userService.user.uid;
    pet = widget.pet;
    final PetService petService = context.watch<PetService>();

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Post',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: DefaultTextStyle.merge(
          style: textStyles.bodyLarge,
          child: AppScrollableNoPaddingPage(
            children: [
              // Image Picker if No Image Selected yet
              if (_imageFiles.isEmpty)
                InkWell(
                    onTap: () async => _pickMultipleImages(),
                    child: Container(
                      color: Colors.white,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        size: 100,
                      ),
                    )),
              // Display Image on Carousell
              if (_imageFiles.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          aspectRatio: 1,
                          enlargeCenterPage: true,
                          enlargeStrategy: CenterPageEnlargeStrategy.scale,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _carouselIndex = index;
                            });
                          },
                        ),
                        items: _imageFiles
                            .map((item) => SizedBox(
                                  height: 300,
                                  child: Center(
                                      child: Image.file(
                                    File(item.path),
                                    fit: BoxFit.fitWidth,
                                    width: double.infinity,
                                  )),
                                ))
                            .toList(),
                      ),
                    ),
                    // Carousel Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _imageFiles.map(
                        (image) {
                          int index = _imageFiles.indexOf(image);
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _carouselIndex == index
                                    ? const Color.fromRGBO(0, 0, 0, 0.9)
                                    : const Color.fromRGBO(0, 0, 0, 0.4)),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pets
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 10,
                      spacing: 10,
                      children: List.generate(selectedPets.length + 1, (index) {
                        if (index < selectedPets.length) {
                          print(selectedPets.length);
                          return selectedPets[index].imgPath == null
                              ? const CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Color.fromARGB(255, 41, 41, 41),
                                )
                              : CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      const Color.fromARGB(255, 41, 41, 41),
                                  backgroundImage: Image.network(
                                    selectedPets[index].imgPath!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ).image,
                                );
                        } else {
                          return InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext thisContext) {
                                    return AlertDialog(
                                      title: const Text("Pets"),
                                      content: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                '${allOtherPets.length} other pets.',
                                                style: textStyles.bodyMedium!
                                                    .copyWith(
                                                        color: colorScheme
                                                            .primary),
                                              ),
                                            ),
                                            if (allOtherPets.isEmpty)
                                              Text(
                                                'You do not have any other pets.',
                                                style: textStyles.bodyMedium!
                                                    .copyWith(
                                                        color: colorScheme
                                                            .primary),
                                              ),
                                            Column(
                                              children: List.generate(
                                                  allOtherPets.length, (index) {
                                                return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedPets.add(
                                                          allOtherPets[index]);
                                                      allOtherPets.removeWhere(
                                                          (item) =>
                                                              item.petID ==
                                                              allOtherPets[
                                                                      index]
                                                                  .petID);
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: DropdownMenuItem(
                                                      child: allOtherPets[index]
                                                                  .imgPath ==
                                                              null
                                                          ? const CircleAvatar(
                                                              radius: 30,
                                                              backgroundColor:
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          41,
                                                                          41,
                                                                          41),
                                                            )
                                                          : CircleAvatar(
                                                              radius: 30,
                                                              backgroundColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      41,
                                                                      41,
                                                                      41),
                                                              backgroundImage:
                                                                  Image.network(
                                                                allOtherPets[
                                                                        index]
                                                                    .imgPath!,
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                              ).image,
                                                            )),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: CircleAvatar(
                              backgroundColor: colorScheme.primary,
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                      }),
                    ),

                    const SizedBoxh10(),

                    //Category
                    AppDropdown(
                      optionsList: postCategory,
                      selectedText: selectedPostCategory,
                      onChanged: (String? value) {
                        setState(() {
                          selectedPostCategory = value!;
                        });
                      },
                    ),
                    const SizedBoxh10(),

                    // Title
                    AppTextFormField(
                      controller: titleController,
                      hintText: 'Title',
                      prefixIcon: const Icon(Icons.title_rounded),
                    ),
                    const SizedBoxh10(),

                    // Caption
                    AppTextFormField(
                      controller: captionController,
                      hintText: 'Caption',
                      prefixIcon: const Icon(Icons.description_rounded),
                    ),
                    const SizedBoxh20(),

                    // Location
                    Text(
                      'Location',
                      style: textStyles.headlineMedium,
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
                    const SizedBoxh20(),

                    // Visibility
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Tooltip(
                            message:
                                "Visibility of this post to users unrelated to this pet.",
                            child:
                                Icon(Icons.info, color: colorScheme.primary)),
                        const SizedBox(
                          width: 10,
                        ),
                        const Expanded(
                          child: Text('Show Post'),
                        ),
                        AppSwitch(
                            value: visibility,
                            onChanged: (value) => setState(() {
                                  visibility = value;
                                })),
                      ],
                    ),
                    const SizedBoxh20(),
                    const SizedBoxh20(),

                    // Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            if (titleController.text != "" &&
                                captionController.text != "") {
                              Post postData = Post(
                                  petID: selectedPets
                                      .map((item) => item.petID!)
                                      .toList(),
                                  petName: selectedPets
                                      .map((item) => item.name)
                                      .toList(),
                                  visibility: visibility,
                                  // Possible Bug : This is assuming all pets have an image path
                                  petImgUrl: selectedPets
                                      .map((item) => item.imgPath!)
                                      .toList(),
                                  likes: 0,
                                  saves: 0,
                                  category: selectedPostCategory,
                                  title: titleController.text,
                                  caption: captionController.text,
                                  location: selectedLocation,
                                  date: DateTime.now(),
                                  comments: []);

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
                                'Add Post',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBoxh20(),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Future<void> _pickMultipleImages() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
        maxHeight: 600, // Optional: Set a maximum height for images
        maxWidth: 800, // Optional: Set a maximum width for images
        limit: 10);

    if (images.length > 10) {
      // Show an error message if more than 10 images are selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only select up to 5 images!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _imageFiles = images;
    });
  }
}
