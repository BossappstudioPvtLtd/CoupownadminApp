import 'dart:math';

import 'package:coupown_admin/Const/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For platform checking

class TermsCondition extends StatefulWidget {
  static const String id = "\webPageTermsCondition";
  const TermsCondition({super.key});

  @override
  _TermsConditionState createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {
  late quill.QuillController _quillController;
  late FocusNode _focusNode; // Add this line

  final String _documentKey = 'saved_document';

  Future<void> _loadDocument() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDocument = prefs.getString(_documentKey);
    if (savedDocument != null) {
      final document = quill.Document.fromJson(
          List<Map<String, dynamic>>.from(prefs.get(_documentKey) as List));
      setState(() {
        _quillController = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _focusNode = FocusNode(); // Initialize the FocusNode here
  }

  @override
  void dispose() {
    _quillController.dispose();
    _focusNode.dispose(); // Dispose of the FocusNode here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorPrimary,
      appBar: AppBar(
        title: const Text('Add Terms and Conditions'),
        backgroundColor: appColorPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(width: 40),
            Card(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      child: QuillSimpleToolbar(
                        controller: _quillController,
                        configurations: QuillSimpleToolbarConfigurations(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          sectionDividerColor: appColorAccent,
                          toolbarIconAlignment: WrapAlignment.start,
                          toolbarSectionSpacing: sqrt2,
                          multiRowsDisplay: false,
                          toolbarSize: 30,
                          showFontSize: true,
                          showJustifyAlignment: true,
                          showListCheck: true,
                          showCodeBlock: true,
                          showInlineCode: true,
                          showQuote: true,
                          showStrikeThrough: true,
                          showUnderLineButton: true,
                          showBoldButton: true,
                          showItalicButton: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      color: const Color.fromARGB(235, 247, 247, 250),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: quill.QuillEditor(
                          scrollController: ScrollController(),
                          focusNode: _focusNode, // Assign FocusNode here
                          controller: _quillController,
                        
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                 
                ],
              ),
            ),
            
                  const SizedBox(height: 32),
             Container( width: double.infinity,  constraints: const BoxConstraints(maxWidth: 400),
               child: ElevatedButton( onPressed:(){} ,
                style: ElevatedButton.styleFrom( backgroundColor: Colors.blueGrey, 
                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32),), ),
              child: const Text('Submit',
                style: TextStyle(color: appColorPrimary),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

