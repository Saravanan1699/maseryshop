import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:maseryshop/Responsive/responsive.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Base_Url/BaseUrl.dart';
import 'Sign_up.dart';
import 'auth_service.dart'; // Import the AuthService

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText1 = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _saveToLocalStorage(
      String token, String name, String email, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Token is $token");
    print("name is $name");
    print("email is $email");
    print("id is $id");
    await prefs.setString('token', token);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('id', id);
  }

  Future<Map<String, dynamic>> _authenticate(
      String username, String password) async {
    late Map<String, dynamic> responseData;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        responseData = jsonDecode(response.body);
        print(
            'Response data: $responseData'); // Print the entire response for inspection
        final String token = responseData['data']['token'] ?? '';
        final String email = responseData['data']['userDetails']['email'] ?? '';
        final String name = responseData['data']['userDetails']['name'] ?? '';
        final String id = responseData['data']['userDetails']['id'].toString();
        print('Retrieved email: $email');

        await _saveToLocalStorage(token, name, email, id);
        return {
          'success': true,
          'message': 'User LoggedIn Successfully!',
          'token': token,
          'email': email,
          'name': name,
          'id': id,
        };
      } else if (response.statusCode == 402) {
        responseData = jsonDecode(response.body);
        final String errorMessage =
            responseData['data']['error'] ?? 'Unauthorized';
        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        responseData = jsonDecode(response.body);
        final String errorMessage =
            responseData['message'] ?? 'Failed to authenticate';
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to authenticate: $e',
      };
    }
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final responseData = await _authenticate(email, password);
      if (responseData['success']) {
        // Show success message as Snackbar
        _showSuccessSnackBar(responseData['message']);

        // Use the AuthService to handle login and navigation
        await AuthService.login(context, email, password);
      } else {
        // Handle login failure
        _showError(responseData['message']);
      }
    } catch (e) {
      // Handle server error
      _showError('Failed to authenticate: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust as needed
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Getting the screen width and height for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final responsive = Responsive(context);
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow bottom inset to avoid keyboard
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05), // 5% of screen width padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello Again!',
                    style: GoogleFonts.raleway(
                      // Using Google Fonts
                      fontSize:
                          responsive.textSize(3.5), // Responsive font size
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: responsive.heightPercentage(6)), // Responsive height
              Row(
                children: [
                  Text(
                    'Email Address',
                    style: GoogleFonts.raleway(
                      // Using Google Fonts
                      fontSize:
                          responsive.textSize(2.5), // Responsive font size
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2B2B2B),
                    ),
                    textAlign: TextAlign.center, // Align the text to the center
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  fillColor: Color(0xFFF7F7F9),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Curved border
                    borderSide: BorderSide.none, // No border
                  ),
                  labelStyle: TextStyle(
                    fontSize: responsive.textSize(2.5),
                    color: Color(0xFF6A6A6A),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 10.0,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
                      .hasMatch(value)) {
                    return 'Please enter a valid Gmail address';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Text(
                    'Password',
                    style: GoogleFonts.raleway(
                      // Using Google Fonts
                      fontSize:
                          responsive.textSize(2.5), // Responsive font size
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2B2B2B),
                    ),
                    textAlign: TextAlign.center, // Align the text to the center
                  ),
                ],
              ),
              SizedBox(height: responsive.heightPercentage(2.5)),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  fillColor: Color(0xFFF7F7F9),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Curved border
                    borderSide: BorderSide.none, // No border
                  ),
                  labelStyle: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Color(0xFF6A6A6A),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 10.0,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText1 = !_obscureText1;
                      });
                    },
                    child: Icon(
                      _obscureText1 ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xff707B81),
                    ),
                  ),
                ),
                obscureText: _obscureText1, // Use the _obscureText1 variable
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),

              SizedBox(height: responsive.heightPercentage(10)),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login(); // Call login function when the button is pressed
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0D6EFD),
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: screenWidth * 0.35,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12.0), // Curved border with 12.0 radius
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.raleway(
                    // Using Google Fonts
                    fontSize: responsive.textSize(3), // Responsive font size
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                  textAlign: TextAlign.center, // Align the text to the center
                ),
              ),
              SizedBox(height: responsive.heightPercentage(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New User ? ',
                    style: GoogleFonts.raleway(
                      fontSize: responsive.textSize(3),
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF707B81),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignUp()));
                    },
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.raleway(
                        fontSize: responsive.textSize(3),
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
