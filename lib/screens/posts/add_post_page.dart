import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/themes.dart';

class AddPostPage extends StatefulWidget {
  final Pet pet;
  const AddPostPage({super.key, required this.pet});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  late String selectedLocation = "";
  late String? uid;
  late String? username;

  List<XFile> _imageFiles = [];
  final _picker = ImagePicker();
  late int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    // load userService to get default params
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);
      // Set the selected location to the default user location.
      selectedLocation = userService.user.defaultLocation!;
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
                      ).toList(), // this was the part the I had to add
                    ),
                  ],
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
