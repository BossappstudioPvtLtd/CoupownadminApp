
import 'package:coupown_admin/Const/app_colors.dart';
import 'package:coupown_admin/dashboard/dashboard.dart';
import 'package:coupown_admin/pages/advertisement.dart';
import 'package:coupown_admin/pages/users_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

//common users
//drivers
//admins

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({super.key});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer>
{
  Widget chosenScreen = const Dashboard();

  sendAdminTo(selectedPage)
  {
    switch(selectedPage.route)
    {
      

      case UsersPage.id:
        setState(() {
          chosenScreen = const UsersPage();
        });
        break;
         case Advertisement.id:
        setState(() {
          chosenScreen = const Advertisement();
        });
        break;

      
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return AdminScaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor:Colors.blueGrey,
        title: const Text(
          "Admin  Panel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:appColorPrimary
          ),
        ),
      ),
      sideBar: SideBar(
        activeIconColor:  Colors.blueGrey,
        activeTextStyle: const TextStyle(color: Colors.blueGrey),
        backgroundColor: Colors.blueGrey,
        iconColor:  appColorPrimary,
        
        textStyle: const TextStyle(color: appColorPrimary),
        items: const [
         
          AdminMenuItem(
            title: "Users",
            route: UsersPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
            AdminMenuItem(
            title: "ADD",
            route: Advertisement.id,
            icon: CupertinoIcons.tv_fill,
          ),
         
        ],
        selectedRoute: UsersPage.id,
        onSelected: (selectedPage)
        {
          sendAdminTo(selectedPage);
        },
        header: Container(
          height: 52,
          width: double.infinity,
          color:Colors.blueGrey,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ],
          ),
        ),
        footer: Container(
          height: 52,
          width: double.infinity,
          color:Colors.blueGrey,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.computer,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: chosenScreen,
    );
  }
}
