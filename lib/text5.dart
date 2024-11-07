import 'package:coupown_admin/Const/app_colors.dart';
import 'package:coupown_admin/pages/Data/deals_of_the_day.dart';
import 'package:coupown_admin/pages/Data/excludive_offers.dart';
import 'package:coupown_admin/pages/Data/header_ad.dart';
import 'package:coupown_admin/pages/Data/special_offers.dart';
import 'package:coupown_admin/pages/Data/trading_deals_ad.dart';
import 'package:coupown_admin/pages/Data/upcoming_offers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:dotted_border/dotted_border.dart';

class Text5 extends StatefulWidget {
  static const String id = "/webPageText5";
  const Text5({super.key});

  @override
  _Text5State createState() => _Text5State();
}

class _Text5State extends State<Text5> {
  final TextEditingController _webLinkController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedOption;
  bool _isLoading = false;
  String _phoneError = '';
  String _imageError = '';
  String _dateError = '';

  final ImagePicker _picker = ImagePicker();
  final List<String> _dropdownOptions = [
    'Header Ad',
    'Trading Deal Ad',
    'Deals Of The Day Ad',
    'Special Offers Ad',
    'Exclusive Offers Ad',
    'Upcoming Offers Ad',
    'Installation & Services Ad'
  ];

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedImageBytes = result.files.single.bytes;
          _selectedImage = null; // Ensure no file object is set in web
          _imageError = '';
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedImageBytes = null; // Clear bytes for mobile
          _imageError = '';
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isFromDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        final DateTime combinedDateTime = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
        setState(() {
          if (isFromDate) {
            _fromDateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(combinedDateTime);
          } else {
            _toDateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(combinedDateTime);
          }
          _dateError = '';
        });
      }
    }
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _phoneError = '';
      _imageError = '';
      _dateError = '';
    });

    if (_webLinkController.text.isEmpty || _selectedOption == null ||
        _phoneController.text.isEmpty || _companyNameController.text.isEmpty) {
      _showSnackBar('Please complete all fields correctly.');
      isValid = false;
    }

    if (_selectedImage == null && _selectedImageBytes == null) {
      setState(() => _imageError = 'Please select an image.');
      isValid = false;
    }

    if (_fromDateController.text.isEmpty || _toDateController.text.isEmpty) {
      setState(() => _dateError = 'Please select both dates.');
      isValid = false;
    }

    if (_phoneController.text.length != 10 || !RegExp(r'^\d+$').hasMatch(_phoneController.text)) {
      setState(() => _phoneError = 'Please enter a valid 10-digit phone number');
      isValid = false;
    }
    return isValid;
  }

 
  Future<String?> _uploadImageToFirebaseStorage() async {
  try {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference storageReference = FirebaseStorage.instance.ref().child("advertisements/$fileName");

    UploadTask uploadTask;
    if (kIsWeb && _selectedImageBytes != null) {
      // Web upload (Uint8List)
      uploadTask = storageReference.putData(_selectedImageBytes!);
    } else if (_selectedImage != null) {
      // Mobile upload (File)
      uploadTask = storageReference.putFile(_selectedImage!);
    } else {
      // No image selected
      return null;
    }
 // Await upload and retrieve download URL
  TaskSnapshot snapshot = await uploadTask;
  String imageUrl = await snapshot.ref.getDownloadURL();
  
  return imageUrl;
  } catch (e) {
    debugPrint("Error uploading image: $e");
    return null;
  }
}


 Future<void> _submitForm() async {
  if (_validateForm()) {
    setState(() => _isLoading = true);
    _showLoadingDialog();

    String? imageUrl = await _uploadImageToFirebaseStorage();

    if (imageUrl != null) {
      final Map<String, dynamic> formData = {
        'webLink': _webLinkController.text,
        'fromDate': _fromDateController.text,
        'toDate': _toDateController.text,
        'selectedOption': _selectedOption,
        'selectedImage': imageUrl,
        'phone': _phoneController.text,
        'companyName': _companyNameController.text,
      };
      await _saveDataToFirebase(formData);
      Navigator.pop(context);
      setState(() => _isLoading = false);
      _resetForm();
    } else {
      Navigator.pop(context);
      setState(() => _isLoading = false);
      _showSnackBar('Failed to upload the image');
    }
  }
}


  Future<void> _saveDataToFirebase(Map<String, dynamic> formData) async {
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    final String selectedPath = "advertisements/${_selectedOption!.replaceAll(" ", "_").toLowerCase()}";
    await databaseReference.child(selectedPath).push().set(formData);
  }

  void _resetForm() {
    _webLinkController.clear();
    _fromDateController.clear();
    _toDateController.clear();
    _phoneController.clear();
    _companyNameController.clear();
    _selectedImage = null;
    _selectedImageBytes = null; // Clear image bytes
    _selectedOption = null;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          content: CupertinoActivityIndicator(radius: 20),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorPrimary,
      appBar: AppBar(
        title: const Text('Add Form'),
        backgroundColor: appColorPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.photo_library), onPressed: _pickImage),
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
                        ? Image.memory(_selectedImageBytes!, width: 200, height: 100, fit: BoxFit.cover)
                        : _selectedImage != null
                            ? Image.file(_selectedImage!, width: 200, height: 100, fit: BoxFit.cover)
                            : const Text('Select an image', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            if (_imageError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_imageError, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _webLinkController,
              decoration: const InputDecoration(labelText: 'Web Link'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedOption,
              onChanged: (value) => setState(() => _selectedOption = value),
              items: _dropdownOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Select Ad Type'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                errorText: _phoneError.isEmpty ? null : _phoneError,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context, _fromDateController, true),
              child: AbsorbPointer(
                child: TextField(
                  controller: _fromDateController,
                  decoration: InputDecoration(
                    labelText: 'From Date',
                    errorText: _dateError.isEmpty ? null : _dateError,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context, _toDateController, false),
              child: AbsorbPointer(
                child: TextField(
                  controller: _toDateController,
                  decoration: InputDecoration(
                    labelText: 'To Date',
                    errorText: _dateError.isEmpty ? null : _dateError,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
            if (_isLoading) const CircularProgressIndicator(),
             const SizedBox(height: 32),
                    const Text('Submitted Data',style: TextStyle(fontWeight:FontWeight.bold ,fontSize: 20),),
                    const SizedBox(height: 20),
                    
                    const Text('Header',style: TextStyle(fontWeight:FontWeight.bold ),),
                    const SizedBox(height: 400,child: AdvertisementList()),
                    
                    const Text('Trading Deals',style: TextStyle(fontWeight:FontWeight.bold ),),
                    const SizedBox(height: 400,child: TradingDealsAd()),
                                   
                      
                    const Text('Dealds Of The Day',style: TextStyle(fontWeight:FontWeight.bold ),),
                    const SizedBox(height: 400,child: DealsOfTheDay()),
                                   
              
                    const Text('Special Offers',style: TextStyle(fontWeight:FontWeight.bold ),),
                    const SizedBox(height: 400,child: SpecialOffers()),

                    const Text('Exclusive Offers',style: TextStyle(fontWeight:FontWeight.bold ),),
                    const SizedBox(height: 400,child: ExclusiveOffers()),
                                   
                                   
                    const Text('Upcoming Offers',style: TextStyle(fontWeight:FontWeight.bold ),),
                    const SizedBox(height: 400,child: UpcomingOffers()),
          ],
        ),
      ),
    );
  }
}
