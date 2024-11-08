import 'package:flutter/material.dart';
import 'package:prm_project/constants.dart';
import 'package:prm_project/ui/root_page.dart';
import 'package:prm_project/ui/screens/forgot_password.dart';
import 'package:prm_project/ui/screens/signup_page.dart';
import 'package:prm_project/ui/screens/widgets/custom_textfield.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  // Google Sign-In method
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _showMessage('Google Sign-In cancelled.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Access token for backend
      final String? token = googleAuth.idToken;

      // Call the backend API with Google token
      if (token != null) {
        await _registerWithProvider(token);
      } else {
        _showMessage('Google sign-in failed.');
      }
    } catch (error) {
      _showMessage('Error during Google Sign-In.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerWithProvider(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://greenscapehub.com/api/user/register/$token'),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userData = responseData['data']['user'];
        final token = responseData['data']['token'];
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('userName', userData['name']);
        await prefs.setString('userEmail', userData['email']);
        await prefs.setString('userId', userData['_id']);
        await prefs.setString('userToken', token);

        // Navigate to RootPage
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: const RootPage(),
            type: PageTransitionType.bottomToTop,
          ),
        );
      } else {
        _showMessage(responseData['error'] ?? 'Google Sign-In failed.');
      }
    } catch (error) {
      _showMessage('An error occurred. Please try again later.');
    }
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Vui lòng nhập email và mật khẩu');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://greenscapehub.com/api/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {

        final userData = responseData['data']['user'];
        final token = responseData['data']['token'];
        final prefs = await SharedPreferences.getInstance();

        // Persist user data
        await prefs.setString('userName', userData['name']);
        await prefs.setString('userEmail', userData['email']);
        await prefs.setString('userId', userData['_id']);
        await prefs.setString('userToken', token);

        // Login successful, navigate to the RootPage
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: const RootPage(),
            type: PageTransitionType.bottomToTop,
          ),
        );
        _showMessage(responseData['message']);
      } else {
        // Display error message
        _showMessage(responseData['error'] ?? 'Đăng nhập thất bại');
      }
    } catch (error) {
      _showMessage('Có lỗi xảy ra. Vui lòng thử lại sau.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/signin.png'),
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),
              CustomTextfield(
                controller: _emailController,
                obscureText: false,
                hintText: 'Enter Email',
                icon: Icons.alternate_email,
              ),
              CustomTextfield(
                controller: _passwordController,
                obscureText: true,
                hintText: 'Enter Password',
                icon: Icons.lock,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _isLoading ? null : _login,
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey : Constants.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 20),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: const ForgotPassword(),
                          type: PageTransitionType.bottomToTop));
                },
                child: Center(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: 'Forgot Password? ',
                        style: TextStyle(
                          color: Constants.blackColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Reset Here',
                        style: TextStyle(
                          color: Constants.primaryColor,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _isLoading ? null : _signInWithGoogle,
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Constants.primaryColor),
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 30,
                        child: Image.asset('assets/images/google.png'),
                      ),
                      Text(
                        'Sign In with Google',
                        style: TextStyle(
                          color: Constants.blackColor,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: const SignUp(),
                          type: PageTransitionType.bottomToTop));
                },
                child: Center(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: 'New to Planty? ',
                        style: TextStyle(
                          color: Constants.blackColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Register',
                        style: TextStyle(
                          color: Constants.primaryColor,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
