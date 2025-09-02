import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user/global/global.dart';
import 'package:user/screens/profile_screen.dart';
import 'package:user/screens/trips_history_screen.dart';
import '../splashScreen/splash_screen.dart';
import 'HelpScreen.dart';
import 'package:user/screens/weather_screen.dart';
import 'contact_form_screen.dart';
import 'main_screen.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  Future<void> signOutUser(BuildContext context) async {
    try {
      // Save the current user's email before signing out
      String? email = firebaseAuth.currentUser?.email;
      if (email != null) {
        await saveLastUsedEmail(email);
      }

      // Sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      
      // Sign out from Firebase
      await firebaseAuth.signOut();
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => SplashScreen()),
        (route) => false,
      );
    } catch (error) {
      print("Error during sign out: $error");
      // Still try to navigate to splash screen even if there's an error
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.blueGrey[900],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          )
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 70, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userModelCurrentInfo?.name ?? "Guest",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => ProfileScreen()));
                              },
                              child: Text(
                                "Edit profile",
                                style: TextStyle(
                                  color: Colors.blue[300],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  
                  // Menu Items
                  _buildMenuItem(
                    context,
                    icon: Icons.home,
                    title: "Home",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
                    },
                  ),
                  SizedBox(height: 20),
                  
                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    title: "History",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
                    },
                  ),
                  SizedBox(height: 20),


                  ListTile(
                    leading: Icon(Icons.cloud, color: Colors.white),
                    title: Text(
                      "Weather",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => WeatherScreen()),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  ListTile(
                    leading: Icon(Icons.contact_page, color: Colors.white),
                    title: Text(
                      "Contact Dev",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => ContactFormScreen()),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  _buildMenuItem(
                    context,
                    icon: Icons.help,
                    title: "Help",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => HelpScreen()));
                    },
                  ),

                ],
              ),

              // Sign Out Button at the bottom
              _buildMenuItem(
                context,
                icon: Icons.logout,
                title: "Sign Out",
                onTap: () => signOutUser(context),
                color: Colors.red[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: color ?? Colors.white,
                size: 24,
              ),
              SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}