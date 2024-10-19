
import 'package:flutter/material.dart';

class CommonMethods {
  Widget header(int headerFlexValue, String headerTitle, BuildContext context) {
    // Get the screen width to determine if it's phone or web
    double screenWidth = MediaQuery.of(context).size.width;

    // Define font size and padding based on screen size
    double fontSize = screenWidth > 600 ? 20.0 : 14.0; // Larger font for web, smaller for phone
    EdgeInsetsGeometry padding = screenWidth > 600
        ? const EdgeInsets.all(16.0) // More padding for web
        : const EdgeInsets.all(8.0); // Less padding for phone

    return Expanded(
      flex: headerFlexValue,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color:Colors.teal,
        ),
        child: Padding(
          padding: padding,
          child: Text(
            headerTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
  