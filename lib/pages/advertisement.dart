import 'package:coupown_admin/Const/app_colors.dart';
import 'package:coupown_admin/pages/Data/deals_of_the_day.dart';
import 'package:coupown_admin/pages/Data/excludive_offers.dart';
import 'package:coupown_admin/pages/Data/header_ad.dart';
import 'package:coupown_admin/pages/Data/installation_service.dart';
import 'package:coupown_admin/pages/Data/special_offers.dart';
import 'package:coupown_admin/pages/Data/trading_deals_ad.dart';
import 'package:coupown_admin/pages/Data/upcoming_offers.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // For platform checking

class Advertisement extends StatefulWidget {
  static const String id = "\webPageAdvertisement";
  const Advertisement({super.key});

  @override
  _AdvertisementState createState() => _AdvertisementState();
}

class _AdvertisementState extends State<Advertisement> {
  final _webLinkController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController =TextEditingController();
  
  File? _selectedImage;
  String? _selectedOption;
  DateTime? _fromDate, _toDate;
  final _dropdownOptions = ['Header Ad', 'Trading Deald Ad', 'Deals Of The Day ad','Special Offers Ad' ,'Exclusive Offers Ad','Upcoming Offers Ad',"Instaltion & Services Ad"];
  final _picker = ImagePicker();
  final List<Map<String, dynamic>> _submittedData = [];
  String _phoneError = '';

 Future<void> _pickImage() async {
  if (kIsWeb) {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _selectedImage = File(result.files.single.path!));
    }
  } else {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      setState(() => _selectedImage = image);
    }
  }
}


  Future<void> _selectDateAndTime(BuildContext context, TextEditingController controller, bool isFromDate) async {
    final selectedDate = await showDatePicker( context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
    if (selectedDate != null) {
      final selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      
      if (selectedTime != null) {
        final combinedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
        setState(() {
          if (isFromDate) {
            _fromDate = combinedDateTime;
            controller.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(combinedDateTime);
          } else {
            _toDate = combinedDateTime;
            controller.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(combinedDateTime);
          }
        });
      }
    }
  }

  bool _validateForm() {
    if (_webLinkController.text.isEmpty || _fromDate == null || _toDate == null || _selectedImage == null || _fromDate!.isAfter(_toDate!)) {
      _showSnackBar('Please complete all fields correctly.');
      return false;
    }
    if (_phoneController.text.length != 10 || !RegExp(r'^\d+$').hasMatch(_phoneController.text)) {
      setState(() {
        _phoneError = 'Please enter a valid 10-digit phone number';
      });
      return false;
    } else {
      setState(() {
        _phoneError = '';
      });
    }
    return true;
  }



Future<String?> _uploadImageToFirebaseStorage(File imageFile) async {
  try {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child("advertisements/$fileName");

    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    
    return imageUrl; // Return the URL of the uploaded image
  } catch (e) {
    print("Error uploading image: $e");
    return null;  // Return null if upload fails
  }
}

bool _isLoading = false; // Add this to your class


 void _submitForm() async {
    if (_validateForm()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing dialog when tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: _isLoading
                ? const CupertinoActivityIndicator(radius: 20,) // Cupertino loader
                : const Text('Submitting...'),
          );
        },
      );

      setState(() {
        _isLoading = true; // Start loading
      });

      // Upload the image to Firebase Storage if image is selected
      if (_selectedImage != null) {
        try {
          String? imageUrl = await _uploadImageToFirebaseStorage(_selectedImage!);
          if (imageUrl != null) {
            // Add data to local list
            _submittedData.add({
              'webLink': _webLinkController.text,
              'fromDate': _fromDate?.toIso8601String(),
              'toDate': _toDate?.toIso8601String(),
              'selectedOption': _selectedOption,
              'selectedImage': imageUrl, // Save the image URL, not the file
              'phone': _phoneController.text,
              'companyname': _companyNameController.text,
            });

            // Send data to Firebase Realtime Database under a path based on selectedOption
            final databaseReference = FirebaseDatabase.instance.ref();
            String selectedPath = "advertisements/${_selectedOption!.replaceAll(" ", "_").toLowerCase()}";
            await databaseReference.child(selectedPath).push().set({
              'webLink': _webLinkController.text,
              'fromDate': _fromDate?.toIso8601String(),
              'toDate': _toDate?.toIso8601String(),
              'selectedOption': _selectedOption,
              'selectedImage': imageUrl,
              'phone': _phoneController.text,
              'companyname': _companyNameController.text,
            });

            Navigator.pop(context); // Close the loading dialog

            setState(() {
              _isLoading = false;
            });

            print("Data saved successfully!");
            _resetForm();
          } else {
            Navigator.pop(context); // Close the loading dialog on failure
            setState(() {
              _isLoading = false;
            });
            _showSnackBar('Failed to upload the image');
          }
        } catch (error) {
          Navigator.pop(context); // Close the loading dialog on error
          setState(() {
            _isLoading = false;
          });
          print("Failed to upload image or save data: $error");
          _showSnackBar('Failed to save data');
        }
      } else {
        Navigator.pop(context); // Close the loading dialog if no image
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('No image selected');
      }
    }
  }







  void _resetForm() {
    _webLinkController.clear();
    _fromDateController.clear();
    _toDateController.clear();
    _phoneController.clear();

    _companyNameController.clear();
    _selectedImage = null;
    _selectedOption = null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: appColorPrimary,
      appBar: AppBar(title: const Text('Add Form'), backgroundColor: appColorPrimary),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16.0),
              
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Row( children: [
                      IconButton(icon: const Icon(Icons.photo_library), onPressed: _pickImage),
                     const SizedBox(width: 16),
                        DottedBorder( borderType: BorderType.RRect,radius: const Radius.circular(8), color: Colors.grey, strokeWidth: 2,
                          child: Container( width: 200, height: 100, alignment: Alignment.center,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.blueGrey),
                            child: _selectedImage != null ? Image.file(_selectedImage!, width: 200, height: 100, fit: BoxFit.cover)
                                : const Center(child: Text('No Image', style: TextStyle(color: appColorPrimary))),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                  Card( elevation: 5,color: appColorPrimary,
                        child: DropdownButton<String>(borderRadius: BorderRadius.circular(8), dropdownColor: appColorPrimary,value: _selectedOption,isExpanded: true,
                          hint: const Padding( padding: EdgeInsets.only(left: 10), child: Text('Select Option'),),
                          items: _dropdownOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
                          onChanged: (newValue) => setState(() => _selectedOption = newValue),
                        ), 
                       ),
                    const SizedBox(width: 16),
                
                  Card( elevation: 5, color: appColorPrimary,
                           child: Padding(padding: const EdgeInsets.only(left: 10),child: TextField(controller: _companyNameController,
                          decoration: const InputDecoration(hintText: 'Company Name',border: InputBorder.none,), ), ), ),
                
                    const SizedBox(height: 16),
                
                    Card(elevation: 5, color: appColorPrimary,
                      child: Padding( padding: const EdgeInsets.only(left: 10),
                        child: TextField(controller: _webLinkController,
                          decoration: const InputDecoration(hintText: 'Web Link',border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 16),
                
                    Card(elevation: 5,color: appColorPrimary,
                      child: Padding( padding: const EdgeInsets.only(left: 10),
                        child: TextField( controller: _phoneController,  keyboardType: TextInputType.phone,
                          decoration: InputDecoration(hintText: 'Phone Number', border: InputBorder.none,errorText: _phoneError.isNotEmpty ? _phoneError : null, ),
                          onChanged: (value) { if (value.length != 10 || !RegExp(r'^\d+$').hasMatch(value)) {setState(() => _phoneError = 'Please enter a valid 10-digit phone number');
                            } else { setState(() => _phoneError = '');}
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row( children: [
                        Expanded( child: Card(elevation: 5, color: appColorPrimary,
                            child: Padding(padding: const EdgeInsets.only(left: 10),
                              child: TextField(controller: _fromDateController,
                                decoration: const InputDecoration(  hintText: 'From Date/Time', border: InputBorder.none, ),
                                readOnly: true, onTap: () => _selectDateAndTime(context, _fromDateController, true),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Card(elevation: 5, color: appColorPrimary,
                            child: Padding( padding: const EdgeInsets.only(left: 10),
                              child: TextField(controller: _toDateController,
                                decoration: const InputDecoration( hintText: 'To Date/Time',border: InputBorder.none,),
                                readOnly: true, onTap: () => _selectDateAndTime(context, _toDateController, false),),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                   
                    /*const SizedBox(height: 32),ElevatedButton(onPressed: _submitForm,style: ElevatedButton.styleFrom( backgroundColor: Colors.blueGrey, // Replace with your desired color
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Optional: adjust button size
                       shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(32),  ), ),
                       child: const Text('Submit',style: TextStyle(color: appColorPrimary),),),*/
                       const SizedBox(height: 32),
Container(
  width: double.infinity, // Ensures the button takes the full width of its parent
  constraints: const BoxConstraints(maxWidth: 400), // Set the maximum width here
  child: ElevatedButton(
    onPressed: _submitForm,
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
