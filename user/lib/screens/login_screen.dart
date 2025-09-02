// import 'package:email_validator/email_validator.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:user/screens/forgot_password_screen.dart';
// import 'package:user/screens/register_screen.dart';
// import 'package:user/splashScreen/splash_screen.dart';
//
// import '../global/global.dart';
// import 'main_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final emailTextEditingController = TextEditingController();
//   final passwordTextEditingController = TextEditingController();
//   final GoogleSignIn googleSignIn = GoogleSignIn();
//   bool _passwordVisible = false;
//   bool _isLoading = false;
//
//   //declare global key
//   final _formKey = GlobalKey<FormState>();
//
//   // Google Sign In Function
//   Future<void> _handleGoogleSignIn() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });
//
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//       if (googleUser == null) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       final UserCredential authResult = await firebaseAuth.signInWithCredential(credential);
//       final User? user = authResult.user;
//
//       if (user != null) {
//         DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
//
//         // Check if user exists
//         final snapshot = await userRef.child(user.uid).get();
//         if (!snapshot.exists) {
//           // Create new user entry if doesn't exist
//           Map userMap = {
//             "id": user.uid,
//             "name": user.displayName ?? "User",
//             "email": user.email,
//             "phone": user.phoneNumber ?? "",
//             "address": "",
//             "photoUrl": user.photoURL ?? "",
//           };
//           await userRef.child(user.uid).set(userMap);
//         }
//
//         await Fluttertoast.showToast(msg: "Login Successfully");
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen()));
//       }
//     } catch (error) {
//       await Fluttertoast.showToast(msg: "Error occurred: \n $error");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _submit() async {
//     if(_formKey.currentState!.validate()){
//       await firebaseAuth.signInWithEmailAndPassword(
//           email: emailTextEditingController.text.trim(),
//           password: passwordTextEditingController.text.trim()
//       ).then((auth) async {
//
//         DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
//         userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
//           final snap = value.snapshot;
//           if(snap.value != null){
//             currentUser = auth.user;
//             await Fluttertoast.showToast(msg: "Login Successfully");
//             Navigator.push(context,MaterialPageRoute(builder: (c) => MainScreen()));
//           }
//
//           else{
//             await Fluttertoast.showToast(msg: "No Record Exist With This Email");
//             firebaseAuth.signOut();
//             Navigator.push(context,MaterialPageRoute(builder: (c) => SplashScreen()));
//           }
//         });
//
//       }). catchError((errorMessage){
//         Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
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
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             ListView(
//               padding: EdgeInsets.all(0),
//               children: [
//                 Column(
//                   children: [
//                     Image.asset(darkTheme ? 'images/image1_dark.webp' : 'images/image1.webp'),
//                     SizedBox(height: 20),
//                     Text(
//                       "User Login",
//                       style: TextStyle(
//                         color: darkTheme ? Colors.amber.shade400 : Colors.blue,
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Form(
//                             key: _formKey,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 TextFormField(
//                                   inputFormatters: [
//                                     LengthLimitingTextInputFormatter(50)
//                                   ],
//
//                                   decoration: InputDecoration(
//                                     hintText: "Email",
//                                     hintStyle: TextStyle(
//                                         color: Colors.grey
//                                     ),
//                                     filled: true,
//                                     fillColor: darkTheme? Colors.black45 : Colors.grey.shade200,
//                                     border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(5),
//                                         borderSide: BorderSide(
//                                           width: 0,
//                                           style: BorderStyle.none,
//                                         )
//                                     ),
//                                     prefixIcon: Icon(Icons.email,color: darkTheme ? Colors.amber.shade400 :Colors.grey,),
//
//                                   ),
//                                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                                   validator: (text){
//                                     if(text == null || text.isEmpty){
//                                       return 'Email cant be empty';
//                                     }
//
//                                     if(EmailValidator.validate(text) == true){
//                                       return null;
//                                     }
//                                     if(text.length < 4){
//                                       return 'please enter a valid email';
//                                     }
//
//                                     if(text.length>49){
//                                       return "Email cant be more than 50";
//                                     }
//                                   },
//
//                                   onChanged: (text) => setState((){
//                                     emailTextEditingController.text = text;
//                                   }),
//                                 ),
//                                 SizedBox(height:10,),
//
//                                 TextFormField(
//                                   obscureText: !_passwordVisible,
//                                   inputFormatters: [
//                                     LengthLimitingTextInputFormatter(50)
//                                   ],
//
//                                   decoration: InputDecoration(
//                                       hintText: "Password",
//                                       hintStyle: TextStyle(
//                                           color: Colors.grey
//                                       ),
//                                       filled: true,
//                                       fillColor: darkTheme? Colors.black45 : Colors.grey.shade200,
//                                       border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(5),
//                                           borderSide: BorderSide(
//                                             width: 0,
//                                             style: BorderStyle.none,
//                                           )
//                                       ),
//                                       prefixIcon: Icon(Icons.lock_open,color: darkTheme ? Colors.amber.shade400 :Colors.grey,),
//                                       suffixIcon: IconButton(
//                                         icon:Icon(
//                                           _passwordVisible ? Icons.visibility : Icons.visibility_off,
//                                           color: darkTheme ? Colors.amber.shade400: Colors.grey,
//                                         ),
//                                         onPressed: (){
//                                           setState(() {
//                                             _passwordVisible = !_passwordVisible;
//
//                                           });
//                                         },
//                                       )
//
//                                   ),
//                                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                                   validator: (text){
//                                     if(text == null || text.isEmpty){
//                                       return 'Password cant be empty';
//                                     }
//
//                                     if(EmailValidator.validate(text) == true){
//                                       return null;
//                                     }
//                                     if(text.length <6){
//                                       return 'please enter a valid Password';
//                                     }
//
//                                     if(text.length>20){
//                                       return "Password cant be more than 20";
//                                     }
//
//                                     return null;
//                                   },
//
//                                   onChanged: (text) => setState((){
//                                     passwordTextEditingController.text = text;
//                                   }),
//                                 ),
//                                 SizedBox(height:10,),
//
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue, // Background color
//                                     foregroundColor: darkTheme ? Colors.black : Colors.white,         // Text/Icon color
//                                     elevation: 0,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(32),
//                                     ),
//                                     minimumSize: Size(double.infinity, 50),
//                                   ),
//                                   onPressed: () {
//                                     _submit();
//                                   },
//                                   child: Text(
//                                     'Login',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                     ),
//                                   ),
//                                 ),
//
//                                 SizedBox(height: 20),
//
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Divider(
//                                         color: darkTheme ? Colors.grey[600] : Colors.grey[400],
//                                         thickness: 1,
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                       child: Text(
//                                         "OR",
//                                         style: TextStyle(
//                                           color: darkTheme ? Colors.grey[400] : Colors.grey[600],
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Divider(
//                                         color: darkTheme ? Colors.grey[600] : Colors.grey[400],
//                                         thickness: 1,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 SizedBox(height: 20),
//
//                                 // Google Sign In Button
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.white,
//                                     foregroundColor: Colors.black,
//                                     elevation: 2,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(32),
//                                       side: BorderSide(color: Colors.grey.shade300),
//                                     ),
//                                     minimumSize: Size(double.infinity, 50),
//                                   ),
//                                   onPressed: _isLoading ? null : _handleGoogleSignIn,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Image.network(
//                                         'https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png',
//                                         height: 24,
//                                       ),
//                                       SizedBox(width: 12),
//                                       Text(
//                                         'Continue with Google',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//
//                                 SizedBox(height: 10,),
//
//                                 GestureDetector(
//                                   onTap: (){
//                                     Navigator.push(context,MaterialPageRoute(builder: (c) => ForgotPasswordScreen()));
//
//                                   },
//                                   child: Text(
//                                     'Forgot Password ?',
//                                     style:TextStyle(
//                                       color: darkTheme ? Colors.amber.shade400 : Colors.blue,
//                                     ),
//                                   ),
//                                 ),
//
//                                 SizedBox(height: 10,),
//
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children:[
//                                     Text(
//                                       "Doesn't have an account?",
//                                       style:TextStyle(
//                                         color:Colors.grey,
//                                         fontSize:15,
//
//                                       ),
//                                     ),
//                                     SizedBox(width: 5,),
//
//                                     GestureDetector(
//                                       onTap: (){
//                                         Navigator.push(context,MaterialPageRoute(builder: (c) => RegisterScreen()));
//
//                                       },
//
//                                       child: Text(
//                                           'Register',
//                                           style:TextStyle(
//                                             fontSize: 15,
//                                             color: darkTheme ? Colors.amber.shade400 :Colors.blue,
//                                           )
//
//                                       ),
//                                     )
//                                   ],
//                                 )
//
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             if (_isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.5),
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       darkTheme ? Colors.amber.shade400 : Colors.blue,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user/screens/forgot_password_screen.dart';
import 'package:user/screens/register_screen.dart';
import 'package:user/splashScreen/splash_screen.dart';

import '../global/global.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential authResult = await firebaseAuth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
          final snapshot = await userRef.child(user.uid).get();

          if (!snapshot.exists) {
            Map<String, dynamic> userMap = {
              "id": user.uid,
              "name": user.displayName ?? "User",
              "email": user.email,
              "phone": user.phoneNumber ?? "",
              "address": "",
              "photoUrl": user.photoURL ?? "",
            };
            await userRef.child(user.uid).set(userMap);
          }

          await Fluttertoast.showToast(msg: "Login Successfully");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainScreen()));
        }
      }
    } catch (error) {
      await Fluttertoast.showToast(msg: "Error occurred: \n $error");
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).then((auth) async {
          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
          final snap = (await userRef.child(firebaseAuth.currentUser!.uid).once()).snapshot;

          if (snap.value != null) {
            currentUser = auth.user;
            await Fluttertoast.showToast(msg: "Login Successfully");
            Navigator.push(context, MaterialPageRoute(builder: (c) => const MainScreen()));
          } else {
            await Fluttertoast.showToast(msg: "No Record Exists With This Email");
            await firebaseAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
          }
        });
      } catch (errorMessage) {
        Fluttertoast.showToast(msg: "Error occurred: \n $errorMessage");
      }
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
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                      ),
                      child: Image.asset(darkTheme ? 'images/image1_dark.webp' : 'images/image1.webp',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            backgroundColor.withOpacity(0.5),
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
                            "Welcome Back",
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
                            "Sign in to User",
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
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 5),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.01),
                                blurRadius: 8,
                                offset: const Offset(2,8),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: emailTextEditingController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: textColor),
                            inputFormatters: [LengthLimitingTextInputFormatter(50)],
                            decoration: InputDecoration(
                              hintText: "Enter your email",
                              labelText: "Email Address",
                              labelStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.email_outlined, color:Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Email cannot be empty';
                              }
                              if (!EmailValidator.validate(text)) {
                                return 'Please enter a valid email';
                              }
                              if (text.length > 49) {
                                return "Email cannot be more than 50 characters";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
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
                            controller: passwordTextEditingController,
                            obscureText: !_passwordVisible,
                            style: TextStyle(color: textColor),
                            inputFormatters: [LengthLimitingTextInputFormatter(50)],
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const ForgotPasswordScreen()));
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                offset: const Offset(0, 2),
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
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkTheme ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _handleGoogleSignIn,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png',
                                  height: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen()));
                              },
                              child: Text(
                                'Register',
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
