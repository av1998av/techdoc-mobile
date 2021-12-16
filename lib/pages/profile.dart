import 'package:flutter/material.dart';
import '../navbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile')
      ),
      body: Column(
        children: const [
          Text("Profile")
        ],
      ),
      drawer: const NavBar(),
    );
  }
}