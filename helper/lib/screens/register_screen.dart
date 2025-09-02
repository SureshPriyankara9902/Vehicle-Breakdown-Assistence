// import 'package:email_validator/email_validator.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:helper/screens/vehicle_info_screen.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
//
//
// import '../global/global.dart';
// import 'forgot_password_screen.dart';
// import 'login_screen.dart';
// import 'main_screen.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//
//   final nameTextEditingController = TextEditingController();
//   final emailTextEditingController = TextEditingController();
//   final phoneTextEditingController = TextEditingController();
//   final addressTextEditingController = TextEditingController();
//   final passwordTextEditingController = TextEditingController();
//   final confirmTextEditingController = TextEditingController();
//
//   bool _passwordVisible = false;
//
//   //declare global key
//   final _formKey = GlobalKey<FormState>();
//
//   void _submit() async {
//     if(_formKey.currentState!.validate()){
//       await firebaseAuth.createUserWithEmailAndPassword(
//           email: emailTextEditingController.text.trim(),
//           password: passwordTextEditingController.text.trim()
//       ).then((auth) async {
//         currentUser = auth.user;
//
//         if(currentUser != null) {
//           Map userMap = {
//             "id": currentUser!.uid,
//             "name": nameTextEditingController.text.trim(),
//             "email": emailTextEditingController.text.trim(),
//             "address": addressTextEditingController.text.trim(),
//             "phone": phoneTextEditingController.text.trim(),
//
//           };
//
//           DatabaseReference userRef = FirebaseDatabase.instance.ref().child("helpers");
//           userRef.child(currentUser!.uid).set(userMap);
//         }
//
//           await Fluttertoast.showToast(msg: "Register Successfully");
//           Navigator.push(context,MaterialPageRoute(builder: (c) => VehicleInfoScreen()));
//
//     }). catchError((errorMessage){
//       Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
//
//       });
//     }
//     else{
//       Fluttertoast.showToast(msg: "Not all fields are valid");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
//     final primaryColor = darkTheme ? Colors.amber.shade400 : Colors.blue;
//     final backgroundColor = darkTheme ? Colors.black87 : Colors.white;
//     final cardColor = darkTheme ? Colors.black54 : Colors.grey.shade50;
//     final textColor = darkTheme ? Colors.white : Colors.black87;
//
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         backgroundColor: backgroundColor,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Top Image with Overlay
//                 Stack(
//                   alignment: Alignment.bottomCenter,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(30),
//                         bottomRight: Radius.circular(30),
//                       ),
//                       child: Image.asset(
//                         darkTheme ? 'images/image3_dark.jpg' : 'images/image3.jpg',
//                         height: 200,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(30),
//                           bottomRight: Radius.circular(30),
//                         ),
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             backgroundColor.withOpacity(0.7),
//                             backgroundColor,
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 20,
//                       child: Column(
//                         children: [
//                           Text(
//                             "Create Account",
//                             style: TextStyle(
//                               color: Colors.blueGrey,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               shadows: [
//                                 Shadow(
//                                   color: Colors.black26,
//                                   offset: Offset(0, 2),
//                                   blurRadius: 4,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             "Register as a helper",
//                             style: TextStyle(
//                               color: Colors.blueGrey,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 // Registration Form
//                 Container(
//                   padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // Name Field
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                             style: TextStyle(color: textColor),
//                             inputFormatters: [LengthLimitingTextInputFormatter(50)],
//                             decoration: InputDecoration(
//                               hintText: "Enter your name",
//                               labelText: "Full Name",
//                               labelStyle: TextStyle(color: primaryColor),
//                               filled: true,
//                               fillColor: cardColor,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: Icon(Icons.person_outline, color: primaryColor),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             ),
//                             autovalidateMode: AutovalidateMode.onUserInteraction,
//                             validator: (text) {
//                               if (text == null || text.isEmpty) {
//                                 return 'Name cannot be empty';
//                               }
//                               if (text.length < 4) {
//                                 return 'Name must be at least 4 characters';
//                               }
//                               if (text.length > 49) {
//                                 return "Name cannot be more than 50 characters";
//                               }
//                               return null;
//                             },
//                             onChanged: (text) => setState(() {
//                               nameTextEditingController.text = text;
//                             }),
//                           ),
//                         ),
//                         SizedBox(height: 16),
//
//                         // Email Field
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                             style: TextStyle(color: textColor),
//                             keyboardType: TextInputType.emailAddress,
//                             inputFormatters: [LengthLimitingTextInputFormatter(50)],
//                             decoration: InputDecoration(
//                               hintText: "Enter your email",
//                               labelText: "Email Address",
//                               labelStyle: TextStyle(color: primaryColor),
//                               filled: true,
//                               fillColor: cardColor,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             ),
//                             autovalidateMode: AutovalidateMode.onUserInteraction,
//                             validator: (text) {
//                               if (text == null || text.isEmpty) {
//                                 return 'Email cannot be empty';
//                               }
//                               if (!EmailValidator.validate(text)) {
//                                 return 'Please enter a valid email';
//                               }
//                               return null;
//                             },
//                             onChanged: (text) => setState(() {
//                               emailTextEditingController.text = text;
//                             }),
//                           ),
//                         ),
//                         SizedBox(height: 16),
//
//                         // Phone Number Field
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: IntlPhoneField(
//                             style: TextStyle(color: textColor),
//                             showCountryFlag: false,
//                             dropdownIcon: Icon(
//                               Icons.arrow_drop_down,
//                               color: primaryColor,
//                             ),
//                             decoration: InputDecoration(
//                               hintText: "Enter phone number",
//                               labelText: "Phone Number",
//                               labelStyle: TextStyle(color: primaryColor),
//                               filled: true,
//                               fillColor: cardColor,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             ),
//                             initialCountryCode: '94',
//                             onChanged: (phone) => setState(() {
//                               phoneTextEditingController.text = phone.completeNumber;
//                             }),
//                           ),
//                         ),
//                         SizedBox(height: 16),
//
//                         // Address Field
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                             style: TextStyle(color: textColor),
//                             inputFormatters: [LengthLimitingTextInputFormatter(50)],
//                             decoration: InputDecoration(
//                               hintText: "Enter your address",
//                               labelText: "Address",
//                               labelStyle: TextStyle(color: primaryColor),
//                               filled: true,
//                               fillColor: cardColor,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: Icon(Icons.location_on_outlined, color: primaryColor),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             ),
//                             autovalidateMode: AutovalidateMode.onUserInteraction,
//                             validator: (text) {
//                               if (text == null || text.isEmpty) {
//                                 return 'Address cannot be empty';
//                               }
//                               if (text.length < 4) {
//                                 return 'Please enter a valid address';
//                               }
//                               return null;
//                             },
//                             onChanged: (text) => setState(() {
//                               addressTextEditingController.text = text;
//                             }),
//                           ),
//                         ),
//                         SizedBox(height: 16),
//
//                         // Password Field
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                             obscureText: !_passwordVisible,
//                             style: TextStyle(color: textColor),
//                             inputFormatters: [LengthLimitingTextInputFormatter(50)],
//                             decoration: InputDecoration(
//                               hintText: "Enter your password",
//                               labelText: "Password",
//                               labelStyle: TextStyle(color: primaryColor),
//                               filled: true,
//                               fillColor: cardColor,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
//                                   color: primaryColor,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _passwordVisible = !_passwordVisible;
//                                   });
//                                 },
//                               ),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             ),
//                             autovalidateMode: AutovalidateMode.onUserInteraction,
//                             validator: (text) {
//                               if (text == null || text.isEmpty) {
//                                 return 'Password cannot be empty';
//                               }
//                               if (text.length < 6) {
//                                 return 'Password must be at least 6 characters';
//                               }
//                               if (text.length > 20) {
//                                 return "Password cannot be more than 20 characters";
//                               }
//                               return null;
//                             },
//                             onChanged: (text) => setState(() {
//                               passwordTextEditingController.text = text;
//                             }),
//                           ),
//                         ),
//                         SizedBox(height: 16),
//
//                         // Confirm Password Field
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                             obscureText: !_passwordVisible,
//                             style: TextStyle(color: textColor),
//                             inputFormatters: [LengthLimitingTextInputFormatter(50)],
//                             decoration: InputDecoration(
//                               hintText: "Confirm your password",
//                               labelText: "Confirm Password",
//                               labelStyle: TextStyle(color: primaryColor),
//                               filled: true,
//                               fillColor: cardColor,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
//                                   color: primaryColor,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _passwordVisible = !_passwordVisible;
//                                   });
//                                 },
//                               ),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             ),
//                             autovalidateMode: AutovalidateMode.onUserInteraction,
//                             validator: (text) {
//                               if (text == null || text.isEmpty) {
//                                 return 'Please confirm your password';
//                               }
//                               if (text != passwordTextEditingController.text) {
//                                 return "Passwords do not match";
//                               }
//                               return null;
//                             },
//                             onChanged: (text) => setState(() {
//                               confirmTextEditingController.text = text;
//                             }),
//                           ),
//                         ),
//                         SizedBox(height: 24),
//
//                         // Register Button
//                         Container(
//                           height: 48,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             gradient: LinearGradient(
//                               colors: [
//                                 primaryColor,
//                                 primaryColor.withOpacity(0.8),
//                               ],
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: primaryColor.withOpacity(0.3),
//                                 blurRadius: 8,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               shadowColor: Colors.transparent,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: _submit,
//                             child: Text(
//                               'Create Account',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: darkTheme ? Colors.black : Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 16),
//
//                         // Login Link
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Already have an account? ",
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
//                               },
//                               child: Text(
//                                 'Sign In',
//                                 style: TextStyle(
//                                   color: primaryColor,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:helper/screens/vehicle_info_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../global/global.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';

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
      await firebaseAuth
          .createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      )
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
          FirebaseDatabase.instance.ref().child("helpers");
          userRef.child(currentUser!.uid).set(userMap);
        }

        await Fluttertoast.showToast(msg: "Register Successfully");
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => VehicleInfoScreen()));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final primaryColor = darkTheme ? Colors.amber.shade400 : Colors.blue;
    final backgroundColor = darkTheme ? Colors.black87 : Colors.white;
    final cardColor = darkTheme ? Colors.black54 : Colors.grey.shade50;

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
                // Top Image with Overlay
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: Image.asset(
                        darkTheme ? 'images/image3_dark.jpg' : 'images/image3.jpg',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            backgroundColor.withOpacity(0.7),
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
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Register as a helper",
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

                // Registration Form
                Container(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme
                                    ? Colors.black12
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            style: TextStyle(color: Colors.grey[800]),
                            inputFormatters: [LengthLimitingTextInputFormatter(50)],
                            decoration: InputDecoration(
                              hintText: "Enter your name",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              labelText: "Full Name",
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.person_outline,
                                  color: Colors.grey[600]),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Name cannot be empty';
                              }
                              if (text.length < 4) {
                                return 'Name must be at least 4 characters';
                              }
                              if (text.length > 49) {
                                return "Name cannot be more than 50 characters";
                              }
                              return null;
                            },
                            onChanged: (text) => setState(() {
                              nameTextEditingController.text = text;
                            }),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Email Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme
                                    ? Colors.black12
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            style: TextStyle(color: Colors.grey[800]),
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [LengthLimitingTextInputFormatter(50)],
                            decoration: InputDecoration(
                              hintText: "Enter your email",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              labelText: "Email Address",
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                              Icon(Icons.email_outlined, color: Colors.grey[600]),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Email cannot be empty';
                              }
                              if (!EmailValidator.validate(text)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            onChanged: (text) => setState(() {
                              emailTextEditingController.text = text;
                            }),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Phone Number Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme
                                    ? Colors.black12
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IntlPhoneField(
                            style: TextStyle(color: Colors.grey[800]),
                            showCountryFlag: false,
                            dropdownIcon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey[600],
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter phone number",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              labelText: "Phone Number",
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            initialCountryCode: '94',
                            onChanged: (phone) => setState(() {
                              phoneTextEditingController.text = phone.completeNumber;
                            }),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Address Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme
                                    ? Colors.black12
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            style: TextStyle(color: Colors.grey[800]),
                            inputFormatters: [LengthLimitingTextInputFormatter(50)],
                            decoration: InputDecoration(
                              hintText: "Enter your address",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              labelText: "Address",
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.location_on_outlined,
                                  color: Colors.grey[600]),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Address cannot be empty';
                              }
                              if (text.length < 4) {
                                return 'Please enter a valid address';
                              }
                              return null;
                            },
                            onChanged: (text) => setState(() {
                              addressTextEditingController.text = text;
                            }),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme
                                    ? Colors.black12
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            obscureText: !_passwordVisible,
                            style: TextStyle(color: Colors.grey[800]),
                            inputFormatters: [LengthLimitingTextInputFormatter(50)],
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                              Icon(Icons.lock_outline, color: Colors.grey[600]),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Password cannot be empty';
                              }
                              if (text.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              if (text.length > 20) {
                                return "Password cannot be more than 20 characters";
                              }
                              return null;
                            },
                            onChanged: (text) => setState(() {
                              passwordTextEditingController.text = text;
                            }),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Confirm Password Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme
                                    ? Colors.black12
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            obscureText: !_passwordVisible,
                            style: TextStyle(color: Colors.grey[800]),
                            inputFormatters: [LengthLimitingTextInputFormatter(50)],
                            decoration: InputDecoration(
                              hintText: "Confirm your password",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              labelText: "Confirm Password",
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                              Icon(Icons.lock_outline, color: Colors.grey[600]),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (text != passwordTextEditingController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                            onChanged: (text) => setState(() {
                              confirmTextEditingController.text = text;
                            }),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Register Button
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _submit,
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkTheme ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (c) => LoginScreen()));
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
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
}