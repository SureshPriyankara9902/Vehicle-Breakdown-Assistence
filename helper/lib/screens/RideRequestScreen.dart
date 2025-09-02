// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class RideRequestScreen extends StatefulWidget {
//   @override
//   _RideRequestScreenState createState() => _RideRequestScreenState();
// }
//
// class _RideRequestScreenState extends State<RideRequestScreen> {
//   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   final DatabaseReference ref = FirebaseDatabase.instance.ref().child("All Ride Requests");
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Ride Requests"),
//         backgroundColor: Colors.blue,
//       ),
//       body: StreamBuilder(
//         stream: ref.onValue,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
//             Map data = snapshot.data!.snapshot.value as Map;
//             List rideRequests = data.entries.map((e) {
//               Map requestData = e.value;
//               return {
//                 "id": e.key,
//                 "originAddress": requestData["origin"]["originAddress"],
//                 "destinationAddress": requestData["destination"]["destinationAddress"],
//                 "userName": requestData["userName"],
//                 "userPhone": requestData["userPhone"],
//                 "helperId": requestData["helperId"],
//                 "time": requestData["origin"]["time"],
//               };
//             }).toList();
//
//             return ListView.builder(
//               itemCount: rideRequests.length,
//               itemBuilder: (context, index) {
//                 var rideRequest = rideRequests[index];
//                 return Card(
//                   child: ListTile(
//                     title: Text("From: ${rideRequest["originAddress"]}"),
//                     subtitle: Text("To: ${rideRequest["destinationAddress"]}\nRequested by: ${rideRequest["userName"]}"),
//                     trailing: Icon(Icons.directions_car),
//                     onTap: () {
//                       _showRideRequestDialog(rideRequest);
//                     },
//                   ),
//                 );
//               },
//             );
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error fetching data!"));
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
//
//   void _showRideRequestDialog(Map rideRequest) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Ride Request Details"),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Pickup: ${rideRequest["originAddress"]}"),
//               Text("Drop-off: ${rideRequest["destinationAddress"]}"),
//               Text("Rider: ${rideRequest["userName"]}"),
//               Text("Phone: ${rideRequest["userPhone"]}"),
//               Text("Time: ${rideRequest["time"]}"),
//               Text("Helper ID: ${rideRequest["helperId"]}"),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("Close"),
//             ),
//             TextButton(
//               onPressed: () {
//                 _acceptRideRequest(rideRequest["id"]);
//               },
//               child: Text("Accept Ride"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _acceptRideRequest(String requestId) {
//     ref.child(requestId).update({"helperId": firebaseAuth.currentUser!.uid}).then((_) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Ride Request Accepted!")),
//       );
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to accept request: $error")),
//       );
//     });
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class RideRequestScreen extends StatefulWidget {
//   @override
//   _RideRequestScreenState createState() => _RideRequestScreenState();
// }
//
// class _RideRequestScreenState extends State<RideRequestScreen> {
//   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   final DatabaseReference ref = FirebaseDatabase.instance.ref().child("All Ride Requests");
//   String helperVehicleType = ""; // Add this variable to store the helper's vehicle type
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchHelperVehicleType(); // Fetch the helper's vehicle type when the screen loads
//   }
//
//   void _fetchHelperVehicleType() async {
//     final currentUser = firebaseAuth.currentUser;
//     if (currentUser != null) {
//       final helperData = await FirebaseDatabase.instance
//           .ref()
//           .child("helpers")
//           .child(currentUser.uid)
//           .once();
//
//       if (helperData.snapshot.value != null) {
//         setState(() {
//           helperVehicleType = (helperData.snapshot.value as Map)["vehicle_details"]["vehicle_type"];
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Ride Requests"),
//         backgroundColor: Colors.blue,
//       ),
//       body: StreamBuilder(
//         stream: ref.onValue,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
//             Map data = snapshot.data!.snapshot.value as Map;
//             List rideRequests = data.entries.map((e) {
//               Map requestData = e.value;
//               return {
//                 "id": e.key,
//                 "originAddress": requestData["origin"]["originAddress"],
//                 "destinationAddress": requestData["destination"]["destinationAddress"],
//                 "userName": requestData["userName"],
//                 "userPhone": requestData["userPhone"],
//                 "helperId": requestData["helperId"],
//                 "time": requestData["origin"]["time"],
//                 "vehicleType": requestData["vehicleType"], // Add vehicleType to the ride request data
//               };
//             }).toList();
//
//             // Filter ride requests by vehicle type
//             List filteredRideRequests = rideRequests.where((rideRequest) {
//               return rideRequest["helperId"] == "waiting" && rideRequest["vehicleType"] == helperVehicleType;
//             }).toList();
//
//             if (filteredRideRequests.isNotEmpty) {
//               return ListView.builder(
//                 itemCount: filteredRideRequests.length,
//                 itemBuilder: (context, index) {
//                   var rideRequest = filteredRideRequests[index];
//                   return Card(
//                     child: ListTile(
//                       title: Text("From: ${rideRequest["originAddress"]}"),
//                       subtitle: Text("To: ${rideRequest["destinationAddress"]}\nRequested by: ${rideRequest["userName"]}"),
//                       trailing: Icon(Icons.directions_car),
//                       onTap: () {
//                         _showRideRequestDialog(rideRequest);
//                       },
//                     ),
//                   );
//                 },
//               );
//             } else {
//               return Center(
//                 child: Text("No active ride requests match your vehicle type."),
//               );
//             }
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error fetching data!"));
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
//
//   void _showRideRequestDialog(Map rideRequest) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Ride Request Details"),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Pickup: ${rideRequest["originAddress"]}"),
//               Text("Drop-off: ${rideRequest["destinationAddress"]}"),
//               Text("Rider: ${rideRequest["userName"]}"),
//               Text("Phone: ${rideRequest["userPhone"]}"),
//               Text("Time: ${rideRequest["time"]}"),
//               Text("Helper ID: ${rideRequest["helperId"]}"),
//               Text("Vehicle Type: ${rideRequest["vehicleType"]}"), // Display vehicle type
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("Close"),
//             ),
//             TextButton(
//               onPressed: () {
//                 _acceptRideRequest(rideRequest["id"]);
//               },
//               child: Text("Accept Ride"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _acceptRideRequest(String requestId) {
//     ref.child(requestId).update({"helperId": firebaseAuth.currentUser!.uid}).then((_) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Ride Request Accepted!")),
//       );
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to accept request: $error")),
//       );
//     });
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class RideRequestScreen extends StatefulWidget {
  @override
  _RideRequestScreenState createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestsRef = FirebaseDatabase.instance.ref().child("All Ride Requests");
  String _helperVehicleType = "";
  final Map<String, Timer> _activeTimers = {};

  @override
  void initState() {
    super.initState();
    _fetchHelperVehicleType();
  }

  @override
  void dispose() {
    _activeTimers.forEach((_, timer) => timer.cancel());
    super.dispose();
  }

  void _fetchHelperVehicleType() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final helperData = await FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(currentUser.uid)
          .once();

      if (helperData.snapshot.value != null) {
        final data = helperData.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _helperVehicleType = data["vehicle_details"]["vehicle_type"].toString();
        });
      }
    }
  }

  bool _isRequestExpired(int timestamp) {
    final requestTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(requestTime) > Duration(minutes: 3);
  }

  String _formatTimeRemaining(int timestamp) {
    final requestTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final timeRemaining = Duration(minutes: 3) - DateTime.now().difference(requestTime);

    if (timeRemaining.isNegative) return "Expired";
    return "${timeRemaining.inMinutes}m ${timeRemaining.inSeconds % 60}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ride Requests"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder(
        stream: _requestsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Map<String, dynamic>> rideRequests = data.entries.map((e) {
              Map<dynamic, dynamic> requestData = e.value as Map<dynamic, dynamic>;
              return {
                "id": e.key.toString(),
                "originAddress": requestData["origin"]["originAddress"].toString(),
                "destinationAddress": requestData["destination"]["destinationAddress"].toString(),
                "userName": requestData["userName"].toString(),
                "userPhone": requestData["userPhone"].toString(),
                "helperId": requestData["helperId"].toString(),
                "vehicleType": requestData["vehicleType"].toString(),
                "timestamp": int.parse(requestData["timestamp"].toString()),
              };
            }).toList();

            List<Map<String, dynamic>> filteredRideRequests = rideRequests.where((rideRequest) {
              return rideRequest["helperId"] == "waiting" &&
                  rideRequest["vehicleType"] == _helperVehicleType;
            }).toList();

            if (filteredRideRequests.isNotEmpty) {
              return ListView.builder(
                itemCount: filteredRideRequests.length,
                itemBuilder: (context, index) {
                  final rideRequest = filteredRideRequests[index];
                  final isExpired = _isRequestExpired(rideRequest["timestamp"] as int);

                  return GestureDetector(
                    onTap: isExpired ? null : () => _showRideRequestDialog(rideRequest),
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: isExpired ? Colors.grey[200] : null,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  rideRequest["userName"]!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isExpired ? Colors.grey : Colors.black,
                                  ),
                                ),
                                Text(
                                  rideRequest["userPhone"]!,
                                  style: TextStyle(
                                    color: isExpired ? Colors.grey : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(rideRequest["timestamp"] as int),
                              ),
                              style: TextStyle(
                                color: isExpired ? Colors.grey : Colors.black54,
                              ),
                            ),
                            Divider(height: 20),
                            Text(
                              rideRequest["originAddress"]!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isExpired ? Colors.grey : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              rideRequest["destinationAddress"]!,
                              style: TextStyle(
                                color: isExpired ? Colors.grey : Colors.black,
                              ),
                            ),
                            Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: isExpired ? Colors.red : Colors.blue,
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      isExpired ? "Expired" : _formatTimeRemaining(rideRequest["timestamp"] as int),
                                      style: TextStyle(
                                        color: isExpired ? Colors.red : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isExpired)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "EXPIRED",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text("No active ride requests available"),
              );
            }
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching data!"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _showRideRequestDialog(Map<String, dynamic> rideRequest) {
    final requestTime = DateTime.fromMillisecondsSinceEpoch(rideRequest["timestamp"] as int);
    final expireTime = requestTime.add(Duration(minutes: 3));
    final isExpired = DateTime.now().isAfter(expireTime);

    showDialog(
      context: context,
      builder: (context) => RideRequestDialog(
        rideRequest: rideRequest,
        onAccept: () => _acceptRideRequest(rideRequest["id"] as String),
        isExpired: isExpired,
      ),
    ).then((_) {
      if (isExpired) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("This ride request has expired")),
        );
      }
    });
  }

  void _acceptRideRequest(String requestId) {
    _requestsRef.child(requestId).update({
      "helperId": _auth.currentUser!.uid,
      "status": "accepted"
    }).then((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ride Request Accepted!")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to accept request: $error")),
      );
    });
  }
}

class RideRequestDialog extends StatefulWidget {
  final Map<String, dynamic> rideRequest;
  final VoidCallback onAccept;
  final bool isExpired;

  const RideRequestDialog({
    Key? key,
    required this.rideRequest,
    required this.onAccept,
    required this.isExpired,
  }) : super(key: key);

  @override
  _RideRequestDialogState createState() => _RideRequestDialogState();
}

class _RideRequestDialogState extends State<RideRequestDialog> {
  late DateTime requestTime;
  late DateTime expireTime;
  Timer? _timer;
  String timeRemaining = "";

  @override
  void initState() {
    super.initState();
    requestTime = DateTime.fromMillisecondsSinceEpoch(widget.rideRequest["timestamp"] as int);
    expireTime = requestTime.add(Duration(minutes: 3));
    if (!widget.isExpired) {
      _startTimer();
    } else {
      timeRemaining = "Expired";
    }
  }

  void _startTimer() {
    _updateTimeRemaining();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final remaining = expireTime.difference(now);

    if (remaining.isNegative) {
      setState(() {
        timeRemaining = "Expired";
      });
      _timer?.cancel();
      return;
    }

    setState(() {
      timeRemaining = "${remaining.inMinutes}m ${remaining.inSeconds % 60}s";
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = widget.isExpired || timeRemaining == "Expired";

    return AlertDialog(
      title: Text("New Ride Request"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.rideRequest["userName"]!, style: TextStyle(fontSize: 18)),
          Text(widget.rideRequest["userPhone"]!, style: TextStyle(color: Colors.blue)),
          Text(DateFormat('yyyy-MM-dd HH:mm').format(requestTime)),
          Divider(height: 20),
          Text(widget.rideRequest["originAddress"]!, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(widget.rideRequest["destinationAddress"]!),
          Divider(height: 20),
          Row(
            children: [
              Icon(Icons.timer, color: isExpired ? Colors.red : Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                isExpired ? "Expired" : timeRemaining,
                style: TextStyle(
                  color: isExpired ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isExpired ? null : () => Navigator.of(context).pop(),
          child: Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: isExpired ? null : () {
            widget.onAccept();
            Navigator.of(context).pop();
          },
          child: Text("Accept", style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}