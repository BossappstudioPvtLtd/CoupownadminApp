
import 'package:coupown_admin/dashboard/side_navigation_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main()async
{
  WidgetsFlutterBinding.ensureInitialized();
  
   await Firebase.initializeApp( options: const FirebaseOptions( 
  
  apiKey: "AIzaSyCYOxKE5nOGfh2ebYCqq5LTVGXGG12ZP2A",
  authDomain: "coupown-b4b84.firebaseapp.com",
  databaseURL: "https://coupown-b4b84-default-rtdb.firebaseio.com",
  projectId: "coupown-b4b84",
  storageBucket: "coupown-b4b84.appspot.com",
  messagingSenderId: "565852755125",
  appId: "1:565852755125:web:e8b78c8ebcf5e0e6a8dafc",
  measurementId: "G-5R90G0KGVK") );
 


  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: SideNavigationDrawer(),
    );
  }
}


