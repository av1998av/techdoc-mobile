// ignore_for_file: prefer_const_constructors, avoid_returning_null_for_void

import 'package:flutter/material.dart';
import './helpers/shared_pref_helper.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Dr. Mathan'),
            accountEmail: Text(''),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/images/logo.png',fit: BoxFit.cover,width: 120,height: 120,),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Appointments'),
            onTap: () => Navigator.pushReplacementNamed(context, '/appointments'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Patients'),
            onTap: () => Navigator.pushReplacementNamed(context, '/patients'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Bills'),
            onTap: () => Navigator.pushReplacementNamed(context, '/bills'),
          ),
          Divider(),
          ListTile(
            onTap: () => Navigator.pushReplacementNamed(context, '/drugs'),
            leading: Icon(Icons.notifications),
            title: Text('Drugs/Processes'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Profile'),
            onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              await SharePreferenceHelper.logout();
              Navigator.pushReplacementNamed(context, '/');
            }
          )
        ],
      ),
    );
  }
}
