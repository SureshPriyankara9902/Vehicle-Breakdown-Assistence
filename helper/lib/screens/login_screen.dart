import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:helper/screens/register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helper/screens/vehicle_info_screen.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import 'forgot_password_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final _googleSignIn = GoogleSignIn();
  bool _passwordVisible = false;

  //declare global key
  final _formKey = GlobalKey<FormState>();
  Future<void> signInWithGoogle() async {
    try {
      // Force sign out from Google first to ensure account picker shows up
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential authResult = await firebaseAuth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("helpers");
          final snapshot = await userRef.child(user.uid).get();

          if (snapshot.exists) {
            currentUser = user;
            await Fluttertoast.showToast(msg: "Login Successfully");
            Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
          } else {
            // New user, save basic info
            await userRef.child(user.uid).set({
              "email": user.email,
              "name": user.displayName,
              "id": user.uid,
              "created_at": DateTime.now().toString(),
            });
            
            currentUser = user;
            await Fluttertoast.showToast(msg: "Please complete your profile");
            Navigator.push(context, MaterialPageRoute(builder: (c) => VehicleInfoScreen()));
          }
        }
      }
    } catch (e) {
      await Fluttertoast.showToast(msg: "Error signing in with Google: ${e.toString()}");
    }
  }

  void _submit() async {
    if(_formKey.currentState!.validate()){
      await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {

        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("helpers");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
          final snap = value.snapshot;
          if(snap.value != null){
            currentUser = auth.user;
            await Fluttertoast.showToast(msg: "Login Successfully");
            Navigator.push(context,MaterialPageRoute(builder: (c) => MainScreen()));
          }

          else{
            await Fluttertoast.showToast(msg: "No Record Exist With This Email");
            // Sign out from both Google and Firebase
            if (await _googleSignIn.isSignedIn()) {
              await _googleSignIn.disconnect();  // This will force Google to show account picker next time
              await _googleSignIn.signOut();
            }
            await firebaseAuth.signOut();
            Navigator.push(context,MaterialPageRoute(builder: (c) => SplashScreen()));
          }
        });


      }). catchError((errorMessage){
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");

      });
    }
    else{
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
                        darkTheme ? 'images/image1_dark.jpg' : 'images/image1.jpg',
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
                            "Sign in to Helper",
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

                SizedBox(height: 50),
                // Login Form
                Container(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),

                          child: TextFormField(

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
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                            onChanged: (text) => setState(() {
                              emailTextEditingController.text = text;
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
                                color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
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
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        SizedBox(height: 8),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => ForgotPasswordScreen()));
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Login Button
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
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkTheme ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Or Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Google Sign In Button
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: darkTheme ? Colors.black12 : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
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
                            onPressed: signInWithGoogle,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png',
                                  height: 20,
                                ),
                                SizedBox(width: 10),
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
                        SizedBox(height: 16),

                        // Register Link
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
                                Navigator.push(context, MaterialPageRoute(builder: (c) => RegisterScreen()));
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
