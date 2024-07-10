import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Authentication/Sing-in.dart'; // Ensure correct import path
import '../Base_Url/BaseUrl.dart';
import '../bottombar.dart';
import '../home.dart';
import 'Settings.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key); // Corrected super.key to Key key

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late SharedPreferences _prefs;
  String? authToken;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    authToken = _prefs.getString('authToken');
    setState(() {
      isSignedIn = _prefs.getBool('isSignedIn') ?? false;
    });
  }

  Future<void> logoutAndClearStorage(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get token and email from shared preferences
    String token = prefs.getString('token') ?? '';
    String username = prefs.getString('email') ?? '';

    // Clear token and email from shared preferences
    await prefs.remove('token');
    await prefs.remove('email');

    // Logout API call
    try {
      final response = await http.post(
        Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Adjust content type if needed
        },
      );

      // Check response status and handle accordingly
      if (response.statusCode == 200) {
        // Handle successful logout (navigate to homepage)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged out successfully')),
        );
        // Example navigation to homepage
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        // Handle errors or unauthorized access
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out')),
        );
      }
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out')),
      );
    }
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow bottom inset to avoid keyboard
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'My Profile',
          style: GoogleFonts.raleway(
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2B2B),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: 15,
                ),
                onPressed: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  });
                },
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Add your search action here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matilda Brown',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      Text(
                        'matildabrown@mail.com',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.04,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.07),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My orders',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      Text(
                        'Already have 12 orders',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.03,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: screenWidth * 0.06,
                    color: Color(0xFF9B9B9B),
                  ),
                ],
              ),
              Divider(
                color: Color(0xFF9B9B9B),
                thickness: 0.1,
                height: 20,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping addresses',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      Text(
                        '3 addresses',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.03,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: screenWidth * 0.06,
                    color: Color(0xFF9B9B9B),
                  ),
                ],
              ),
              Divider(
                color: Color(0xFF9B9B9B),
                thickness: 0.1,
                height: 20,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment methods',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      Text(
                        'Visa **34',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.03,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: screenWidth * 0.06,
                    color: Color(0xFF9B9B9B),
                  ),
                ],
              ),
              Divider(
                color: Color(0xFF9B9B9B),
                thickness: 0.1,
                height: 20,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promocodes',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      Text(
                        'You have special promocodes',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.03,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: screenWidth * 0.06,
                    color: Color(0xFF9B9B9B),
                  ),
                ],
              ),
              Divider(
                color: Color(0xFF9B9B9B),
                thickness: 0.1,
                height: 20,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My reviews',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      Text(
                        'Reviews for 4 items',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.03,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: screenWidth * 0.06,
                    color: Color(0xFF9B9B9B),
                  ),
                ],
              ),
              Divider(
                color: Color(0xFF9B9B9B),
                thickness: 0.1,
                height: 20,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      Text(
                        'Notifications, password',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.03,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Settings()),
                      );
                    },
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      size: screenWidth * 0.06,
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
                ],
              ),
              Divider(
                color: Color(0xFF9B9B9B),
                thickness: 0.1,
                height: 20,
              ),
              SizedBox(height: screenHeight * 0.02),
              FutureBuilder<bool>(
                future: _checkLoginStatus(),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    bool isLoggedIn = snapshot.data ?? false;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isLoggedIn ? 'Logout' : 'Login',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.w700,
                            color: isLoggedIn ? Color(0xFFEA1712) : Colors.blue,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (isLoggedIn) {
                              logoutAndClearStorage(context);
                            } else {
                              // Navigate to login screen or handle login action
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Signin(),
                                ),
                              );
                            }
                          },
                          child: Icon(
                            isLoggedIn ? Icons.logout : Icons.login,
                            size: screenWidth * 0.06,
                            color: isLoggedIn ? Color(0xFFEA1712) : Colors.blue,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              Divider(
                color: Color(0xFF9B9B9B),
                thickness: 0.1,
                height: 20,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {
          setState(() {});
        },
        favoriteProducts: [],
      ),
    );
  }
}
