import 'package:coupown_admin/Const/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data'; // Import this for Uint8List

class Category extends StatefulWidget {
  static const String id = "\webPageCategory";
  const Category({super.key});

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final _categoryController = TextEditingController();
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // Store bytes for web
  DateTime? _fromDate, _toDate;
  final _picker = ImagePicker();
  String _errorMessage = '';

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

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = selectedDate;
        } else {
          _toDate = selectedDate;
        }
      });
    }
  }

  bool _validateForm() {
    if (_categoryController.text.isEmpty ||
        (_selectedImage == null && _selectedImageBytes == null) ||
        _fromDate!.isAfter(_toDate!)) {
      setState(() {
        _errorMessage = 'Please complete all fields correctly.';
      });
      return false;
    }
    setState(() {
      _errorMessage = '';
    });
    return true;
  }

  Future<String?> _uploadImageToFirebaseStorage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child("advertisements/$fileName");
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_validateForm()) {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToFirebaseStorage(_selectedImage!);
      } else if (_selectedImageBytes != null) {
        // Upload image bytes for web
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance.ref().child("advertisements/$fileName");
        UploadTask uploadTask = storageReference.putData(_selectedImageBytes!); // Use putData for bytes
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      if (imageUrl != null) {
        DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('categories').push();
        await dbRef.set({
          'category': _categoryController.text,
          'imageUrl': imageUrl,
        });
        _resetForm();
        _showSnackBar("Category added successfully.");
      } else {
        _showSnackBar("Image upload failed.");
      }
    }
  }

  void _resetForm() {
    _categoryController.clear();
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null; // Clear web bytes
      _fromDate = null;
      _toDate = null;
      _errorMessage = '';
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorPrimary,
      appBar: AppBar(
        title: const Text('Add Category'),
        backgroundColor: appColorPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Image', style: TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            _buildTextField('Category Name', _categoryController),
            const SizedBox(height: 20),
              const SizedBox(height: 20),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Flexible(child: _buildActionButton('Submit', _submitForm),),
    Flexible( child: _buildActionButton('Reset', _resetForm),),
    Flexible(  child: _buildActionButton('Delete', _resetForm),),
  ],
),

          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Card(
          elevation: 5,
          color: appColorPrimary,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter $label',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  

    Widget _buildActionButton(String label, VoidCallback onPressed) {
  return Container(
    width: double.infinity, // Ensures the button takes the full width of its parent
    constraints: const BoxConstraints(maxWidth: 400), // Set the maximum width here
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey, // Replace with your desired color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Optional: adjust button size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // Adjusted border radius
        ),
      ),
      child: Text(
        label, // Use the label parameter for button text
        style: const TextStyle(color: appColorPrimary), // Set text color
      ),
    ),
  );


  }
}
