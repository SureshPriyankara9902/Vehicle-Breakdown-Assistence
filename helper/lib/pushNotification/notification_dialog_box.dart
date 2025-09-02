import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Assistants/assistant_methods.dart';
import 'package:helper/global/global.dart';
import 'package:helper/models/user_ride_request_information.dart';
import 'package:helper/screens/new_trip_screen.dart';
import 'package:intl/intl.dart';

class NotificationDialogBox extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;
  
  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  String formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  String getVehicleImage() {
    switch(widget.userRideRequestDetails?.vehicleType?.toLowerCase()) {
      case 'flatbed':
        return "images/Flatbed Truck.png";
      case 'wheel lift':
        return "images/Wheel-Lift Truck.png";
      case 'heavy wrecker':
        return "images/Heavy Wrecker.png";
      default:
        return "images/Flatbed Truck.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "New Ride Request",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Vehicle and User Info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // Vehicle Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        getVehicleImage(),
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // User Name
                  Text(
                    widget.userRideRequestDetails?.userName ?? "Unknown User",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Phone Number
                  Text(
                    widget.userRideRequestDetails?.userPhone ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),

                  // Request Time
                  Text(
                    formatTimestamp(widget.userRideRequestDetails?.requestTimestamp),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Origin and Destination
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.userRideRequestDetails?.originAddress ?? "",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.userRideRequestDetails?.destinationAddress ?? "",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (widget.userRideRequestDetails?.duration != null ||
                      widget.userRideRequestDetails?.distance != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.userRideRequestDetails?.duration != null) ...[
                            Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              widget.userRideRequestDetails?.duration ?? "",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                          if (widget.userRideRequestDetails?.duration != null &&
                              widget.userRideRequestDetails?.distance != null)
                            const SizedBox(width: 16),
                          if (widget.userRideRequestDetails?.distance != null) ...[
                            Icon(Icons.route, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              widget.userRideRequestDetails?.distance ?? "",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      acceptRideRequest(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Accept",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Future<void> acceptRideRequest(BuildContext context) async {
    try {
      if (widget.userRideRequestDetails?.rideRequestId == null) {
        Fluttertoast.showToast(msg: "Invalid ride request details");
        return;
      }

      // First check if the ride request still exists and is available
      final rideRequestRef = FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!);

      final DataSnapshot rideSnapshot = await rideRequestRef.get();
      
      if (!rideSnapshot.exists || rideSnapshot.value == null) {
        Fluttertoast.showToast(msg: "This ride request no longer exists");
        Navigator.pop(context);
        return;
      }

      // Check if the ride is already accepted by someone else
      final rideData = rideSnapshot.value as Map<dynamic, dynamic>;
      if (rideData['status'] == 'accepted') {
        Fluttertoast.showToast(msg: "This ride has already been accepted by another helper");
        Navigator.pop(context);
        return;
      }

      // Update helper's status
      await FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(firebaseAuth.currentUser!.uid)
          .update({
        "newRideStatus": "accepted",
        "currentRideRequestId": widget.userRideRequestDetails!.rideRequestId,
      });

      // Update ride request status
      await rideRequestRef.update({
        "status": "accepted",
        "helperId": firebaseAuth.currentUser!.uid,
      });

      AssistantsMethods.pauseLiveLocationUpdates();

      Fluttertoast.showToast(msg: "Ride request accepted successfully");

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (c) => NewTripScreen(
                    userRideRequestDetails: widget.userRideRequestDetails,
                  )));
    } catch (e) {
      print("Error accepting ride request: $e");
      Fluttertoast.showToast(msg: "Failed to accept ride request. Please try again.");
    }
  }
}
