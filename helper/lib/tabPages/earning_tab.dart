// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// //
// // import '../global/global.dart';
// // import '../infoHandler/app_info.dart';
// // import '../screens/trips_history_screen.dart';
// //
// // class EarningsTabPage extends StatefulWidget {
// //   const EarningsTabPage({super.key});
// //
// //   @override
// //   State<EarningsTabPage> createState() => _EarningsTabPageState();
// // }
// //
// // class _EarningsTabPageState extends State<EarningsTabPage> {
// //   @override
// //   Widget build(BuildContext context) {
// //
// //     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
// //     return Container(
// //       color: darkTheme ? Colors.amberAccent : Colors.lightBlueAccent,
// //       child: Column(
// //         children: [
// //           //earnings
// //           Container(
// //             color: darkTheme ? Colors.black : Colors.lightBlue,
// //             width: double.infinity,
// //             child: Padding(
// //               padding: EdgeInsets.symmetric(vertical: 80),
// //               child: Column(
// //                 children: [
// //                   Text(
// //                     "Your Earnings ",
// //                     style: TextStyle(
// //                       color: darkTheme ? Colors.amber.shade400 : Colors.white,
// //                       fontSize: 20,
// //                     ),
// //                   ),
// //
// //                   const SizedBox(height: 10,),
// //
// //                   Text(
// //                     "\Rs: " + Provider.of<AppInfo>(context, listen:false).helperTotalEarnings,
// //                     style: TextStyle(
// //                       color: darkTheme ? Colors.amber.shade400 : Colors.white,
// //                       fontSize: 60,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   )
// //                 ],
// //               ),
// //             ),
// //
// //           ),
// //
// //           //total number of trips
// //           ElevatedButton(
// //             onPressed: (){
// //               Navigator.push(context, MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
// //
// //             },
// //
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: Colors.white54,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.zero, // Removes the rounded corners
// //               ),
// //
// //
// //             ),
// //
// //             child: Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
// //               child: Row(
// //                 children: [
// //                   Image.asset(
// //                     onlineHelperData.vehicle_type == "truck" ? "images/truck.png"
// //                         :onlineHelperData.vehicle_type == "car" ? "images/car.png"
// //                         :"images/bike.png",
// //                     scale: 8,
// //                   ),
// //
// //                   SizedBox(width: 40,),
// //
// //                   Text(
// //                     "Trips Completed",
// //                     style: TextStyle(
// //                       color: Colors.black54,
// //                       fontSize: 18,
// //                     ),
// //                   ),
// //
// //                   Expanded(
// //                     child: Container(
// //                       child: Text(
// //                         Provider.of<AppInfo>(context, listen:false).allTripsHistoryInformationList.length.toString(),
// //                         textAlign: TextAlign.end,
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color:Colors.black,
// //                         ),
// //                       ),
// //                     ),
// //                   )
// //                 ],
// //               ),
// //             ),
// //           )
// //
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// //
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:firebase_database/firebase_database.dart'; // Add this import
// // import '../global/global.dart';
// // import '../infoHandler/app_info.dart';
// // import '../screens/trips_history_screen.dart';
// //
// // class EarningsTabPage extends StatefulWidget {
// //   const EarningsTabPage({super.key});
// //
// //   @override
// //   State<EarningsTabPage> createState() => _EarningsTabPageState();
// // }
// //
// // class _EarningsTabPageState extends State<EarningsTabPage> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Fetch earnings data when the page is loaded
// //     fetchEarningsData();
// //   }
// //
// //   // Fetch earnings data from the database
// //   void fetchEarningsData() async {
// //     // Fetch the helper's total earnings from the database
// //     DatabaseReference earningsRef = FirebaseDatabase.instance
// //         .ref()
// //         .child("helpers")
// //         .child(firebaseAuth.currentUser!.uid)
// //         .child("earning");
// //
// //     print("Fetching earnings data from database...");
// //
// //     earningsRef.once().then((DatabaseEvent snapshot) {
// //       if (snapshot.snapshot.value != null) {
// //         String earnings = snapshot.snapshot.value.toString();
// //         print("Fetched earnings: $earnings");
// //
// //         // Update the AppInfo provider with the fetched earnings
// //         Provider.of<AppInfo>(context, listen: false).updateHelperTotalEarnings(earnings);
// //       } else {
// //         print("No earnings data found in the database.");
// //         // If no earnings data is found, set it to "0"
// //         Provider.of<AppInfo>(context, listen: false).updateHelperTotalEarnings("0");
// //       }
// //     }).catchError((error) {
// //       print("Error fetching earnings: $error");
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
// //
// //     return Container(
// //       color: darkTheme ? Colors.amberAccent : Colors.lightBlueAccent,
// //       child: Column(
// //         children: [
// //           // Earnings Display
// //           Container(
// //             color: darkTheme ? Colors.black : Colors.orange,
// //             width: double.infinity,
// //             child: Padding(
// //               padding: EdgeInsets.symmetric(vertical: 80),
// //               child: Column(
// //                 children: [
// //                   Text(
// //                     "Your Earning ",
// //                     style: TextStyle(
// //                       color: darkTheme ? Colors.amber.shade400 : Colors.white,
// //                       fontSize: 20,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Consumer<AppInfo>(
// //                     builder: (context, appInfo, child) {
// //                       print("Current earnings in UI: ${appInfo.helperTotalEarnings}");
// //                       return Text(
// //                         "\Rs: ${appInfo.helperTotalEarnings}",
// //                         style: TextStyle(
// //                           color: darkTheme ? Colors.amber.shade400 : Colors.white,
// //                           fontSize: 60,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //
// //           // Total Number of Trips
// //           ElevatedButton(
// //             onPressed: () {
// //               Navigator.push(
// //                 context,
// //                 MaterialPageRoute(builder: (c) => TripsHistoryScreen()),
// //               );
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: Colors.white54,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.zero, // Removes the rounded corners
// //               ),
// //             ),
// //             child: Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
// //               child: Row(
// //                 children: [
// //                   Image.asset(
// //                     onlineHelperData.vehicle_type == "truck"
// //                         ? "images/truck.png"
// //                         : onlineHelperData.vehicle_type == "car"
// //                         ? "images/car.png"
// //                         : "images/bike.png",
// //                     scale: 8,
// //                   ),
// //                   SizedBox(width: 40),
// //                   Text(
// //                     "Trips Completed",
// //                     style: TextStyle(
// //                       color: Colors.black54,
// //                       fontSize: 18,
// //                     ),
// //                   ),
// //                   Expanded(
// //                     child: Container(
// //                       child: Consumer<AppInfo>(
// //                         builder: (context, appInfo, child) {
// //                           return Text(
// //                             appInfo.allTripsHistoryInformationList.length.toString(),
// //                             textAlign: TextAlign.end,
// //                             style: TextStyle(
// //                               fontSize: 20,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black,
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_database/firebase_database.dart'; // Add this import
// import '../global/global.dart';
// import '../infoHandler/app_info.dart';
// import '../screens/trips_history_screen.dart';
//
// class EarningsTabPage extends StatefulWidget {
//   const EarningsTabPage({super.key});
//
//   @override
//   State<EarningsTabPage> createState() => _EarningsTabPageState();
// }
//
// class _EarningsTabPageState extends State<EarningsTabPage> {
//   String? vehicleType; // To store the fetched vehicle type
//
//   @override
//   void initState() {
//     super.initState();
//     // Fetch earnings data and vehicle type when the page is loaded
//     fetchEarningsData();
//     fetchVehicleType();
//   }
//
//   // Fetch earnings data from the database
//   void fetchEarningsData() async {
//     // Fetch the helper's total earnings from the database
//     DatabaseReference earningsRef = FirebaseDatabase.instance
//         .ref()
//         .child("helpers")
//         .child(firebaseAuth.currentUser!.uid)
//         .child("earning");
//
//     print("Fetching earnings data from database...");
//
//     earningsRef.once().then((DatabaseEvent snapshot) {
//       if (snapshot.snapshot.value != null) {
//         String earnings = snapshot.snapshot.value.toString();
//         print("Fetched earnings: $earnings");
//
//         // Update the AppInfo provider with the fetched earnings
//         Provider.of<AppInfo>(context, listen: false).updateHelperTotalEarnings(earnings);
//       } else {
//         print("No earnings data found in the database.");
//         // If no earnings data is found, set it to "0"
//         Provider.of<AppInfo>(context, listen: false).updateHelperTotalEarnings("0");
//       }
//     }).catchError((error) {
//       print("Error fetching earnings: $error");
//     });
//   }
//
//   // Fetch the helper's vehicle type from the database
//   void fetchVehicleType() async {
//     DatabaseReference helperRef = FirebaseDatabase.instance
//         .ref()
//         .child("helpers")
//         .child(firebaseAuth.currentUser!.uid)
//         .child("vehicle_details");
//
//     print("Fetching vehicle type from database...");
//
//     helperRef.once().then((DatabaseEvent snapshot) {
//       if (snapshot.snapshot.value != null) {
//         Map<dynamic, dynamic> vehicleDetails = snapshot.snapshot.value as Map<dynamic, dynamic>;
//         setState(() {
//           vehicleType = vehicleDetails["vehicle_type"]; // Update the vehicle type
//         });
//         print("Fetched vehicle type: $vehicleType");
//       } else {
//         print("No vehicle type found in the database.");
//       }
//     }).catchError((error) {
//       print("Error fetching vehicle type: $error");
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
//
//     return Container(
//       color: darkTheme ? Colors.amberAccent : Colors.indigo,
//       child: Column(
//         children: [
//           // Earnings Display
//           Container(
//             color: darkTheme ? Colors.black : Colors.blueGrey,
//             width: double.infinity,
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 80),
//               child: Column(
//                 children: [
//                   Text(
//                     "Your Earning ",
//                     style: TextStyle(
//                       color: darkTheme ? Colors.amber.shade400 : Colors.white,
//                       fontSize: 20,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Consumer<AppInfo>(
//                     builder: (context, appInfo, child) {
//                       print("Current earnings in UI: ${appInfo.helperTotalEarnings}");
//                       return Text(
//                         "\Rs: ${appInfo.helperTotalEarnings}",
//                         style: TextStyle(
//                           color: darkTheme ? Colors.amber.shade400 : Colors.white,
//                           fontSize: 60,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Total Number of Trips
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (c) => TripsHistoryScreen()),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white54,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.zero, // Removes the rounded corners
//               ),
//             ),
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//               child: Row(
//                 children: [
//                   // Display the correct vehicle image based on the fetched vehicle type
//                   Image.asset(
//                     vehicleType == "Flatbed Truck"
//                         ? "images/Flatbed Truck.png"
//                         : vehicleType == "Wheel-Lift Truck"
//                         ? "images/Wheel-Lift Truck.png"
//                         : "images/Heavy Wrecker.png", // Default to bike if vehicle type is not set or invalid
//                     scale: 8,
//                   ),
//                   SizedBox(width: 40),
//                   Text(
//                     "Trips Completed",
//                     style: TextStyle(
//                       color: Colors.black54,
//                       fontSize: 18,
//                     ),
//                   ),
//                   Expanded(
//                     child: Container(
//                       child: Consumer<AppInfo>(
//                         builder: (context, appInfo, child) {
//                           return Text(
//                             appInfo.allTripsHistoryInformationList.length.toString(),
//                             textAlign: TextAlign.end,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';
import '../screens/trips_history_screen.dart';

class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({super.key});

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
  String? vehicleType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      fetchEarningsData(),
      fetchVehicleType(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> fetchEarningsData() async {
    try {
      DatabaseReference earningsRef = FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(firebaseAuth.currentUser!.uid)
          .child("earning");

      final snapshot = await earningsRef.once();
      String earnings = snapshot.snapshot.value?.toString() ?? "0";
      Provider.of<AppInfo>(context, listen: false).updateHelperTotalEarnings(earnings);
    } catch (error) {
      print("Error fetching earnings: $error");
    }
  }

  Future<void> fetchVehicleType() async {
    try {
      DatabaseReference helperRef = FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(firebaseAuth.currentUser!.uid)
          .child("vehicle_details");

      final snapshot = await helperRef.once();
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> vehicleDetails = snapshot.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          vehicleType = vehicleDetails["vehicle_type"];
        });
      }
    } catch (error) {
      print("Error fetching vehicle type: $error");
    }
  }

  Future<void> clearEarningsData() async {
    try {
      DatabaseReference earningsRef = FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(firebaseAuth.currentUser!.uid)
          .child("earning");

      await earningsRef.remove();
      Provider.of<AppInfo>(context, listen: false).updateHelperTotalEarnings("0");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Earnings cleared successfully.")),
      );

      await fetchData();
    } catch (error) {
      print("Error clearing earnings: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear earnings.")),
      );
    }
  }

  void showClearEarningsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Clear Earnings"),
        content: Text("Are you sure you want to clear your earnings?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.delete),
            label: Text("Clear"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              clearEarningsData();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkTheme ? Colors.grey[900] : Colors.blueGrey[900],
        title: Text(
          "Earnings Dashboard",
          style: TextStyle(
            color: darkTheme ? Colors.amber : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: darkTheme ? Colors.amber : Colors.white),
            onPressed: fetchData,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.white),
            onPressed: showClearEarningsDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: darkTheme
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.indigo[50]!, Colors.indigo[100]!],
            ),
          ),
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                darkTheme ? Colors.amber : Colors.blueGrey[700]!,
              ),
            ),
          )
              : SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Earnings Card
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: darkTheme
                            ? [Colors.blueGrey[800]!, Colors.blueGrey[900]!]
                            : [Colors.blueGrey[700]!, Colors.blueGrey[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: darkTheme ? Colors.amber : Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Your Earnings",
                                style: TextStyle(
                                  color: darkTheme ? Colors.amber : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Consumer<AppInfo>(
                            builder: (context, appInfo, child) {
                              double earnings =
                                  double.tryParse(appInfo.helperTotalEarnings) ?? 0.0;
                              return Text(
                                "Rs : ${earnings.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: darkTheme ? Colors.amber : Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          Text(
                            "As of ${DateTime.now().toString().substring(0, 10)}",
                            style: TextStyle(
                              color: darkTheme ? Colors.amber[200] : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Trips Summary Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => TripsHistoryScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blueGrey[100],
                              child: Image.asset(
                                vehicleType == "Flatbed Truck"
                                    ? "images/Flatbed Truck.png"
                                    : vehicleType == "Wheel-Lift Truck"
                                    ? "images/Wheel-Lift Truck.png"
                                    : "images/Heavy Wrecker.png",
                                scale: 8,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Trips Completed",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: darkTheme ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Consumer<AppInfo>(
                                    builder: (context, appInfo, child) => Text(
                                      appInfo.allTripsHistoryInformationList.length.toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: darkTheme ? Colors.white : Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Additional Stats
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard("Vehicle Type", vehicleType ?? "Not Set", darkTheme),
                      _buildStatCard("Active Since", "June 2025", darkTheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, bool darkTheme) {
    return Expanded(
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: darkTheme ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: darkTheme ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
