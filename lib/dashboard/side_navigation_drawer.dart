
import 'package:coupown_admin/Const/app_colors.dart';
import 'package:coupown_admin/dashboard/dashboard.dart';
import 'package:coupown_admin/pages/Data/help_and_support.dart';
import 'package:coupown_admin/pages/Data/terms_condition.dart';
import 'package:coupown_admin/pages/category.dart';
import 'package:coupown_admin/pages/advertisement.dart';
import 'package:coupown_admin/pages/subcategory.dart';
import 'package:coupown_admin/pages/users_page.dart';
import 'package:coupown_admin/text5.dart';
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
          case Category.id:
        setState(() {
          chosenScreen = const Category();
        });
        break;
          case Subcategory.id:
        setState(() {
          chosenScreen = const Subcategory();
        });
        break;
          case HelpAndSupport.id:
        setState(() {
          chosenScreen = const HelpAndSupport();
        });
        break;

          case TermsCondition.id:
        setState(() {
          chosenScreen = const TermsCondition();
        });
        break;

          case Text5.id:
        setState(() {
          chosenScreen = const Text5();
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
            icon: CupertinoIcons.person,
          ),
            AdminMenuItem(
            title: "Add",
            route: Advertisement.id,
            icon: CupertinoIcons.list_bullet_below_rectangle,
          ),
            AdminMenuItem(
            title: "Category",
            route: Category.id,
            icon: CupertinoIcons.layers,
          ),
            AdminMenuItem(
            title: "Sub Category",
            route: Subcategory.id,
            icon: CupertinoIcons.layers_alt,
          ),
           AdminMenuItem(
            title: "Help & Support",
            route: HelpAndSupport.id,
            icon: CupertinoIcons.exclamationmark_shield,
          ),
            AdminMenuItem(
            title: "Terms & Condition",
            route: TermsCondition.id,
            icon: CupertinoIcons.shield_lefthalf_fill,
          ),
            AdminMenuItem(
            title: "Text5",
            route: Text5.id,
            icon: CupertinoIcons.shield_lefthalf_fill,
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
