import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:helper/splashScreen/splash_screen.dart';
import '../global/global.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreen();
}

class _VehicleInfoScreen extends State<VehicleInfoScreen> {
  final vehicleModelTextEditingController = TextEditingController();
  final vehicleNumberTextEditingController = TextEditingController();
  final vehicleColorTextEditingController = TextEditingController();

  List<String> vehicleTypes = ["Flatbed Truck","Wheel-Lift Truck","Heavy Wrecker"];
  String? selectedVehicleType;

  final _formKey = GlobalKey<FormState>();

  _submit() {
    if(_formKey.currentState!.validate()) {
      Map helperVehicleInfoMap = {
        "vehicle_model": vehicleModelTextEditingController.text.trim(),
        "vehicle_number": vehicleNumberTextEditingController.text.trim(),
        "vehicle_color": vehicleColorTextEditingController.text.trim(),
        "vehicle_type": selectedVehicleType,
      };

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("helpers");
      userRef.child(currentUser!.uid).child("vehicle_details").set(helperVehicleInfoMap);

      Fluttertoast.showToast(msg: "Vehicle Details Added Successfully");
      Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
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
                        darkTheme ? 'images/image2_dark.jpg' : 'images/image2.jpg',
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
                            "Vehicle Details",
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
                          SizedBox(height: 5),
                          Text(
                            "Add your vehicle information",
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

                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Vehicle Model Field
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
                            controller: vehicleModelTextEditingController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Enter vehicle model",
                              labelText: "Vehicle Model",
                              labelStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.directions_car_outlined, color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Vehicle model cannot be empty';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        // Vehicle Number Field
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
                            controller: vehicleNumberTextEditingController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Enter vehicle number",
                              labelText: "Vehicle Number",
                              labelStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.pin_outlined, color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Vehicle number cannot be empty';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        // Vehicle Color Field
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
                            controller: vehicleColorTextEditingController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Enter vehicle color",
                              labelText: "Vehicle Color",
                              labelStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.color_lens_outlined, color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Vehicle color cannot be empty';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        // Vehicle Type Dropdown
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
                          child: DropdownButtonFormField(
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Select vehicle type",
                              labelText: "Vehicle Type",
                              labelStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.category_outlined, color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            items: vehicleTypes.map((vehicle) {
                              return DropdownMenuItem(
                                value: vehicle,
                                child: Text(
                                  vehicle,
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedVehicleType = newValue.toString();
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a vehicle type';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24),

                        // Submit Button
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
                              'Save Vehicle Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkTheme ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
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
