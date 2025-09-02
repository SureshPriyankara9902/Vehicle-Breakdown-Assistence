import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:user/global/global.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/main_screen.dart';

import 'forgot_password_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();

  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth.createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim())
          .then((auth) async {
        currentUser = auth.user;

        if (currentUser != null) {
          Map userMap = {
            "id": currentUser!.uid,
            "name": nameTextEditingController.text.trim(),
            "email": emailTextEditingController.text.trim(),
            "address": addressTextEditingController.text.trim(),
            "phone": phoneTextEditingController.text.trim(),
          };

          DatabaseReference userRef =
              FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap);
        }

        await Fluttertoast.showToast(msg: "Register Successfully");
        Navigator.push(context,
            MaterialPageRoute(builder: (c) => const MainScreen()));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final primaryColor = darkTheme ? Colors.amber.shade400 : Colors.blue;
    final backgroundColor = darkTheme ? Colors.black87 : Colors.white;
    final cardColor = darkTheme ? Colors.black54 : Colors.grey.shade50;
    final textColor = darkTheme ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: Image.asset(
                        darkTheme ? 'images/image2_dark.webp' : 'images/image2.webp',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            backgroundColor.withOpacity(0.2),
                            backgroundColor,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      child: Column(
                        children: [
                          Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.blueGrey[900],
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Sign up to get started",
                            style: TextStyle(
                              color: Colors.blueGrey[900],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 1, 20, 5),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildInputField(
                          controller: nameTextEditingController,
                          hintText: "Name",
                          icon: Icons.person,
                          darkTheme: darkTheme,
                          textColor: textColor,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Name can\'t be empty';
                            }
                            if (text.length < 4) {
                              return 'Please enter a valid name';
                            }
                            if (text.length > 49) {
                              return "Name can't be more than 50 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        buildInputField(
                          controller: emailTextEditingController,
                          hintText: "Email",
                          icon: Icons.email,
                          darkTheme: darkTheme,
                          textColor: textColor,
                          keyboardType: TextInputType.emailAddress,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Email can\'t be empty';
                            }
                            if (!EmailValidator.validate(text)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IntlPhoneField(
                            controller: phoneTextEditingController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Phone Number",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            dropdownIcon: Icon(
                              Icons.arrow_drop_down,
                              color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                            ),
                            showCountryFlag: false,
                            disableLengthCheck: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildInputField(
                          controller: addressTextEditingController,
                          hintText: "Address",
                          icon: Icons.location_on,
                          darkTheme: darkTheme,
                          textColor: textColor,
                          maxLines: 1,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Address can\'t be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        buildPasswordField(
                          controller: passwordTextEditingController,
                          hintText: "Password",
                          darkTheme: darkTheme,
                          textColor: textColor,
                          visible: _passwordVisible,
                          onVisibilityChanged: (value) {
                            setState(() {
                              _passwordVisible = value;
                            });
                          },
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Password can\'t be empty';
                            }
                            if (text.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        buildPasswordField(
                          controller: confirmTextEditingController,
                          hintText: "Confirm Password",
                          darkTheme: darkTheme,
                          textColor: textColor,
                          visible: _passwordVisible,
                          onVisibilityChanged: (value) {
                            setState(() {
                              _passwordVisible = value;
                            });
                          },
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (text != passwordTextEditingController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (c) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool darkTheme,
    required Color textColor,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: textColor),
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(
            icon,
            color: darkTheme ? Colors.amber.shade400 : Colors.grey,
          ),
          filled: true,
          fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool darkTheme,
    required Color textColor,
    required bool visible,
    required Function(bool) onVisibilityChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: textColor),
        obscureText: !visible,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(
            Icons.lock,
            color: darkTheme ? Colors.amber.shade400 : Colors.grey,
          ),
          suffixIcon: IconButton(
            onPressed: () => onVisibilityChanged(!visible),
            icon: Icon(
              visible ? Icons.visibility_off : Icons.visibility,
              color: darkTheme ? Colors.amber.shade400 : Colors.grey,
            ),
          ),
          filled: true,
          fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
