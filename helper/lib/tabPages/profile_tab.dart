import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:helper/global/global.dart';
import 'package:helper/splashScreen/splash_screen.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();
  TextEditingController vehicleModelTextEditingController = TextEditingController();
  String? selectedVehicleType;

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("helpers");
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      if (firebaseAuth.currentUser != null) {
        DatabaseEvent event = await userRef.child(firebaseAuth.currentUser!.uid).once();
        if (event.snapshot.value != null) {
          setState(() {
            userData = Map<String, dynamic>.from(event.snapshot.value as Map);
            nameTextEditingController.text = userData['name'] ?? '';
            phoneTextEditingController.text = userData['phone'] ?? '';
            addressTextEditingController.text = userData['address'] ?? '';

            if (userData['vehicle_details'] != null) {
              vehicleColorTextEditingController.text = userData['vehicle_details']['vehicle_color'] ?? '';
              vehicleNumberTextEditingController.text = userData['vehicle_details']['vehicle_number'] ?? '';
              vehicleModelTextEditingController.text = userData['vehicle_details']['vehicle_model'] ?? '';
              selectedVehicleType = userData['vehicle_details']['vehicle_type'];
            }
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error loading user data: $e");
    }
  }

  Future<void> showHelperNameDialogAlert(BuildContext context, String name) {
    nameTextEditingController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await userRef.child(firebaseAuth.currentUser!.uid).update({
                      "name": nameTextEditingController.text.trim(),
                    });
                    await getUserData();
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: "Updated Successfully");
                  } catch (e) {
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: "Error Occurred: $e");
                  }
                },
                child: Text("Ok", style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        }
    );
  }

  Future<void> showHelperPhoneDialogAlert(BuildContext context, String phone) {
    phoneTextEditingController.text = phone;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.phone,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await userRef.child(firebaseAuth.currentUser!.uid).update({
                      "phone": phoneTextEditingController.text.trim(),
                    });
                    await getUserData();
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: "Updated Successfully");
                  } catch (e) {
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: "Error Occurred: $e");
                  }
                },
                child: Text("Ok", style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        }
    );
  }

  Future<void> showHelperAddressDialogAlert(BuildContext context, String address) {
    addressTextEditingController.text = address;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: addressTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await userRef.child(firebaseAuth.currentUser!.uid).update({
                      "address": addressTextEditingController.text.trim(),
                    });
                    await getUserData();
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: "Updated Successfully");
                  } catch (e) {
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: "Error Occurred: $e");
                  }
                },
                child: Text("Ok", style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        }
    );
  }

  Future<void> showVehicleInfoDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Vehicle Info"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: vehicleModelTextEditingController,
                  decoration: InputDecoration(
                      labelText: "Vehicle Model",
                      hintText: userData['vehicle_details']?['vehicle_model'] ?? 'Enter vehicle model'
                  ),
                ),
                TextField(
                  controller: vehicleNumberTextEditingController,
                  decoration: InputDecoration(
                      labelText: "Vehicle Number",
                      hintText: userData['vehicle_details']?['vehicle_number'] ?? 'Enter vehicle number'
                  ),
                ),
                TextField(
                  controller: vehicleColorTextEditingController,
                  decoration: InputDecoration(
                      labelText: "Vehicle Color",
                      hintText: userData['vehicle_details']?['vehicle_color'] ?? 'Enter vehicle color'
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: selectedVehicleType ?? "Flatbed Truck",
                  decoration: InputDecoration(labelText: "Vehicle Type"),
                  items: ["Flatbed Truck", "Wheel-Lift Truck", "Heavy Wrecker"].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedVehicleType = newValue;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await userRef.child(firebaseAuth.currentUser!.uid).update({
                    "vehicle_details": {
                      "vehicle_model": vehicleModelTextEditingController.text.trim(),
                      "vehicle_number": vehicleNumberTextEditingController.text.trim(),
                      "vehicle_color": vehicleColorTextEditingController.text.trim(),
                      "vehicle_type": selectedVehicleType,
                    }
                  });
                  await getUserData();
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "Vehicle Info Updated Successfully");
                } catch (e) {
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "Error Occurred: $e");
                }
              },
              child: Text("Update", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Account",
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await userRef.child(firebaseAuth.currentUser!.uid).remove();
                  await firebaseAuth.currentUser!.delete();
                  await firebaseAuth.signOut();

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (c) => SplashScreen()),
                          (route) => false
                  );

                  Fluttertoast.showToast(msg: "Account deleted successfully");
                } catch (e) {
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "Error deleting account: $e");
                }
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    Color primaryColor = darkTheme ? Colors.amber.shade400 : Colors.blueGrey[900]!;
    Color backgroundColor = darkTheme ? Colors.black87 : Colors.grey.shade100;
    Color cardColor = darkTheme ? Colors.black54 : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            "Profile",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: PopupMenuButton(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_forever, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete Account'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout),
                                    SizedBox(width: 8),
                                    Text('Sign Out'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteAccountDialog();
                              } else if (value == 'logout') {
                                firebaseAuth.signOut();
                                Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      userData['name'] ?? 'Helper Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      userData['email'] ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: cardColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        ListTile(
                          leading: Icon(Icons.person_outline, color: primaryColor),
                          title: Text("Name"),
                          subtitle: Text(userData['name'] ?? 'Not set'),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: primaryColor),
                            onPressed: () => showHelperNameDialogAlert(context, userData['name'] ?? ''),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.phone_outlined, color: primaryColor),
                          title: Text("Phone"),
                          subtitle: Text(userData['phone'] ?? 'Not set'),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: primaryColor),
                            onPressed: () => showHelperPhoneDialogAlert(context, userData['phone'] ?? ''),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.location_on_outlined, color: primaryColor),
                          title: Text("Address"),
                          subtitle: Text(userData['address'] ?? 'Not set'),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: primaryColor),
                            onPressed: () => showHelperAddressDialogAlert(context, userData['address'] ?? ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: cardColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Vehicle Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: primaryColor),
                              onPressed: () => showVehicleInfoDialog(context),
                            ),
                          ],
                        ),
                        if (userData['vehicle_details']?['vehicle_type'] != null)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 120,
                                    child: Image.asset(
                                      userData['vehicle_details']['vehicle_type'] == "Flatbed Truck"
                                          ? "images/Flatbed Truck.png"
                                          : userData['vehicle_details']['vehicle_type'] == "Wheel-Lift Truck"
                                          ? "images/Wheel-Lift Truck.png"
                                          : "images/Heavy Wrecker.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    userData['vehicle_details']['vehicle_type'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ListTile(
                          leading: Icon(Icons.directions_car_outlined, color: primaryColor),
                          title: Text("Vehicle Model"),
                          subtitle: Text(userData['vehicle_details']?['vehicle_model'] ?? 'Not set'),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.pin_outlined, color: primaryColor),
                          title: Text("Vehicle Number"),
                          subtitle: Text(userData['vehicle_details']?['vehicle_number'] ?? 'Not set'),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.color_lens_outlined, color: primaryColor),
                          title: Text("Vehicle Color"),
                          subtitle: Text(userData['vehicle_details']?['vehicle_color'] ?? 'Not set'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}