import 'package:flutter/material.dart';
import 'package:prm_project/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prm_project/ui/screens/widgets/profile_widget.dart';
import 'package:prm_project/ui/screens/signin_page.dart'; // Import the sign-in page

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Unknown User';
      userEmail = prefs.getString('userEmail') ?? 'No email available';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    // Navigate back to the SignIn page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: size.height,
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 150,
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: ExactAssetImage('assets/images/profile.jpg'),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Constants.primaryColor.withOpacity(.5),
                    width: 5.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width * .3,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        style: TextStyle(
                          color: Constants.blackColor,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: Image.asset("assets/images/verified.png"),
                    ),
                  ],
                ),
              ),
              Text(
                userEmail,
                style: TextStyle(
                  color: Constants.blackColor.withOpacity(.3),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: size.height * .7,
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ProfileWidget(
                      icon: Icons.person,
                      title: 'My Profile',
                    ),
                    const ProfileWidget(
                      icon: Icons.settings,
                      title: 'Settings',
                    ),
                    const ProfileWidget(
                      icon: Icons.notifications,
                      title: 'Notifications',
                    ),
                    const ProfileWidget(
                      icon: Icons.chat,
                      title: 'FAQs',
                    ),
                    const ProfileWidget(
                      icon: Icons.share,
                      title: 'Share',
                    ),
                    GestureDetector(
                      onTap: _logout, // Call _logout on tap
                      child: const ProfileWidget(
                        icon: Icons.logout,
                        title: 'Log Out',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
