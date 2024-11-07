import 'package:coupown_admin/Const/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class Subcategory extends StatefulWidget {
  static const String id = "\webPageSubcategory";
  const Subcategory({super.key});

  @override
  _SubcategoryState createState() => _SubcategoryState();
}

class _SubcategoryState extends State<Subcategory> {
  final _categoryController = TextEditingController();
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // Store bytes for web

  final _picker = ImagePicker();
  final List<Map<String, dynamic>> _submittedData = [];
  String? _selectedOption;
  final _dropdownOptions = [
    'Header Ad',
    'Trading Deal Ad',
    'Deals Of The Day Ad',
    'Special Offers Ad',
    'Exclusive Offers Ad',
    'Upcoming Offers Ad',
    'Installation & Services Ad'
  ];

  final List<String> _categories = ["Add New Category"];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _pickImage() async {
  //   if (kIsWeb) {
  //     final result = await FilePicker.platform.pickFiles(type: FileType.image);
  //     if (result != null && result.files.single.path != null) {
  //       setState(() => _selectedImage = File(result.files.single.path!));
  //     }
  //   } else {
  //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //     if (pickedFile != null) {
  //       final image = File(pickedFile.path);
  //       setState(() => _selectedImage = image);
  //     }
  //   }
  // }

 Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedImageBytes = result.files.single.bytes; // Save bytes for web
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final image = File(pickedFile.path);
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = null; // Clear web bytes if a mobile image is selected
        });
      }
    }
  }
  void _resetForm() {
    _categoryController.clear();
    setState(() {
      _selectedImage = null;
      _selectedCategory = null;
      _selectedOption = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addNewCategory() async {
    TextEditingController newCategoryController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Category"),
          content: TextField(
            controller: newCategoryController,
            decoration: const InputDecoration(hintText: "Enter category name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newCategory = newCategoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  final ref = FirebaseDatabase.instance.ref("categories").child(newCategory);
                  await ref.set({"name": newCategory});

                  setState(() {
                    _categories.insert(0, newCategory);
                    _selectedCategory = newCategory;
                  });
                  Navigator.of(context).pop();
                  _showSnackBar("Category added successfully!");
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorPrimary,
      appBar: AppBar(
        title: const Text('Add Sub Category'),
        backgroundColor: appColorPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(width: 40),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.blueGrey),
                  onPressed: _pickImage,
                ),
                const SizedBox(width: 16),
                DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  color: Colors.grey,
                  strokeWidth: 2,
                  child: Container(
                    width: 200,
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blueGrey,
                    ),
                    child: _selectedImageBytes != null
                        ? Image.memory(_selectedImageBytes!, width: 200, height: 100, fit: BoxFit.cover) // Use Image.memory for web
                        : _selectedImage != null
                            ? Image.file(_selectedImage!, width: 200, height: 100, fit: BoxFit.cover) // Use Image.file for mobile
                            : const Text('No Image', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 5,
                    color: appColorPrimary,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          hintText: 'Sub Category',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                 Card(
  elevation: 5,
  color: appColorPrimary,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedOption,
        isExpanded: true,
        dropdownColor: appColorPrimary,
        hint: const Text('Select Category'),
        items: _dropdownOptions
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: (newValue) => setState(() => _selectedOption = newValue),
      ),
    ),
  ),
),

                  const SizedBox(height: 32),
                 Container(
  width: double.infinity, // Ensures the button takes the full width of its parent
  constraints: const BoxConstraints(maxWidth: 400), // Set the maximum width here
  child: ElevatedButton(
    onPressed:(){} ,//_submitForm,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueGrey, // Replace with your desired color
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Optional: adjust button size
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
    ),
    child: const Text(
      'Submit',
      style: TextStyle(color: appColorPrimary),
    ),
  ),
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
