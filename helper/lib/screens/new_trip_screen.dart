import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helper/Assistants/assistant_methods.dart';
import 'package:helper/global/global.dart';
import 'package:helper/models/user_ride_request_information.dart';
import 'package:helper/splashScreen/splash_screen.dart';
import 'package:helper/widgets/fare_amount_collection_dialog.dart';
import 'package:url_launcher/url_launcher.dart'; // For phone call functionality
import '../widgets/progress_dialog.dart';
import 'chat_screen.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom:10.4746,
  );

  double earning = 0.0;
  String buttonTitle = "Arrived";
  Color buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polylinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  BitmapDescriptor? helperIcon;
  BitmapDescriptor? pickupIcon;
  BitmapDescriptor? destinationIcon;
  var geoLocator = Geolocator();
  Position? onlineHelperCurrentPosition;

  String rideRequestStatus = "accepted";
  String distanceFromOriginToDestinations = "";
  String durationFromOriginToDestinations = "";
  bool isRequestDirectionDetails = false;
  DateTime? _lastDurationUpdate;
  String statusMessage = "";
  String helperAction = "";

  Timer? _locationUpdateTimer;

  Future<void> _loadMarkerIcons() async {
    helperIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(2, 2)),
      "images/pick.png",
    );
    pickupIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(2, 2)),
      "images/origin.png",
    );
    destinationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(2, 2)),
      "images/destination.png",
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    saveAssignedHelperDetailsToUserRideRequest();

    // Draw initial route to pickup location when screen loads
    Future.delayed(Duration(milliseconds: 500), () async {
      if (mounted && widget.userRideRequestDetails != null) {
        // Get helper's current position for origin
        Position currentPos = await Geolocator.getCurrentPosition();
        LatLng helperLatLng = LatLng(currentPos.latitude, currentPos.longitude);

        // Draw route from helper's location to pickup point
        await drawPolylineFromOriginToDestination(
          helperLatLng,
          widget.userRideRequestDetails!.originLatLng!,
          Theme.of(context).brightness == Brightness.dark,
          showLoadingDialog: false
        );
      }
    });

    // Start periodic location updates
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      getHelperLocationUpdatesAtRealTime();
      updateDurationAndDistanceAtRealTime();
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  // Function to sanitize phone number
  String sanitizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  // Function to make a phone call
  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      Fluttertoast.showToast(msg: "Phone number not available");
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: sanitizePhoneNumber(phoneNumber));

    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      Fluttertoast.showToast(msg: "Could not launch phone dialer");
    }
  }
  Future<void> drawPolylineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng, bool darkTheme, {bool showLoadingDialog = true}) async {
    var directionDetailsInfo;

    if (showLoadingDialog) {
      showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please Wait..."),
      );
    }

    try {
      directionDetailsInfo = await AssistantsMethods.obtainOriginToDestinationDirectionDetails(
          originLatLng, destinationLatLng);
    } finally {
      if (showLoadingDialog && mounted) {
        Navigator.pop(context);
      }
    }

    if (directionDetailsInfo == null) {
      Fluttertoast.showToast(msg: "Failed to fetch directions.");
      return;
    }

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polylinePositionCoordinates.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        polylinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
        polylineId: PolylineId("polylineID"),
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 6,
      );

      setOfPolyline.add(polyline);
    });

    // Update distance and duration info
    setState(() {
      distanceFromOriginToDestinations = directionDetailsInfo.distance_text ?? "Calculating...";
      durationFromOriginToDestinations = directionDetailsInfo.duration_text ?? "Calculating...";
    });

    // Create markers with custom icons based on the current phase
    await updateMarkersBasedOnPhase(originLatLng, destinationLatLng);

    // Fit map bounds to show the entire route
    LatLngBounds bounds = createLatLngBounds(originLatLng, destinationLatLng);
    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 65));
  }

  Future<void> updateMarkersBasedOnPhase(LatLng originLatLng, LatLng destinationLatLng) async {
    setOfMarkers.clear();

    // Helper's current location marker
    Marker helperMarker = Marker(
      markerId: MarkerId("helperID"),
      position: originLatLng,
      icon: helperIcon!,
      infoWindow: InfoWindow(
        title: "Helper's Location",
        snippet: "Your current location"
      ),
    );

    // Second marker (either pickup or destination based on phase)
    Marker secondMarker = Marker(
      markerId: MarkerId("secondID"),
      position: destinationLatLng,
      icon: rideRequestStatus == "accepted" ? pickupIcon! : destinationIcon!,
      infoWindow: InfoWindow(
        title: rideRequestStatus == "accepted" ? "Pickup Location" : "Drop-off Location",
        snippet: rideRequestStatus == "accepted" ? "Pick up user here" : "Final destination"
      ),
    );

    setState(() {
      setOfMarkers.add(helperMarker);
      setOfMarkers.add(secondMarker);

      // If we're in the second phase (after pickup), also show the final destination marker
      if (rideRequestStatus == "picked") {
        Marker finalDestMarker = Marker(
          markerId: MarkerId("finalDestID"),
          position: widget.userRideRequestDetails!.destinationLatLng!,
          icon: destinationIcon!,
          infoWindow: InfoWindow(
            title: "Final Destination",
            snippet: "Drop-off location"
          ),
        );
        setOfMarkers.add(finalDestMarker);
      }
    });
  }

  LatLngBounds createLatLngBounds(LatLng point1, LatLng point2) {
    if (point1.latitude > point2.latitude && point1.longitude > point2.longitude) {
      return LatLngBounds(southwest: point2, northeast: point1);
    } else if (point1.longitude > point2.longitude) {
      return LatLngBounds(
        southwest: LatLng(point2.latitude, point1.longitude),
        northeast: LatLng(point1.latitude, point2.longitude),
      );
    } else {
      return LatLngBounds(southwest: point1, northeast: point2);
    }
  }

  void getHelperLocationUpdatesAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);

    streamSubscriptionHelperLivePosition = Geolocator.getPositionStream().listen((Position position) {
      helperCurrentPosition = position;
      onlineHelperCurrentPosition = position;

      LatLng latLngLiveHelperPosition =
      LatLng(onlineHelperCurrentPosition!.latitude, onlineHelperCurrentPosition!.longitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("AnimatedMarker"),
        position: latLngLiveHelperPosition,
        icon: iconAnimatedMarker!,
        infoWindow: InfoWindow(title: "This is your position"),
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveHelperPosition, zoom: 17);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveHelperPosition;

      // Update duration in real-time
      updateDurationAndDistanceAtRealTime();

      // Update helper location at real time in database
      Map helperLatLngDataMap = {
        "latitude": onlineHelperCurrentPosition!.latitude.toString(),
        "longitude": onlineHelperCurrentPosition!.longitude.toString(),
      };
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("helperLocation")
          .set(helperLatLngDataMap);
    });
  }

  void updateDurationAndDistanceAtRealTime() async {
    // Only update every 10 seconds to avoid too frequent updates
    if (_lastDurationUpdate != null &&
        DateTime.now().difference(_lastDurationUpdate!) < Duration(seconds: 10)) {
      return;
    }

    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (onlineHelperCurrentPosition == null) {
        return;
      }

      var currentHelperPosition = LatLng(
        onlineHelperCurrentPosition!.latitude,
        onlineHelperCurrentPosition!.longitude
      );

      LatLng? destinationPosition;

      if (rideRequestStatus == "accepted") {
        destinationPosition = widget.userRideRequestDetails!.originLatLng; // Pickup location
      } else {
        destinationPosition = widget.userRideRequestDetails!.destinationLatLng; // Drop-off location
      }

      if (destinationPosition != null) {
        var directionInfo = await AssistantsMethods.obtainOriginToDestinationDirectionDetails(
          currentHelperPosition,
          destinationPosition
        );

        if (directionInfo != null) {
          _lastDurationUpdate = DateTime.now();

          setState(() {
            durationFromOriginToDestinations = directionInfo.duration_text ?? "Calculating...";
            distanceFromOriginToDestinations = directionInfo.distance_text ?? "Calculating...";
          });

          // Update the polyline with new route
          await drawPolylineFromOriginToDestination(
            currentHelperPosition,
            destinationPosition,
            Theme.of(context).brightness == Brightness.dark,
            showLoadingDialog: false
          );
        }
      }

      isRequestDirectionDetails = false;
    }
  }

  // Update route based on trip status
  Future<void> updateRouteBasedOnStatus() async {
    if (!mounted) return;

    setOfPolyline.clear();
    Position currentPos = await Geolocator.getCurrentPosition();
    LatLng helperLatLng = LatLng(currentPos.latitude, currentPos.longitude);

    if (rideRequestStatus == "accepted") {
      // Show route to pickup location
      await drawPolylineFromOriginToDestination(
        helperLatLng,
        widget.userRideRequestDetails!.originLatLng!,
        Theme.of(context).brightness == Brightness.dark,
        showLoadingDialog: false
      );
    } else if (rideRequestStatus == "arrived" || rideRequestStatus == "ontrip") {
      // Show route to destination
      await drawPolylineFromOriginToDestination(
        widget.userRideRequestDetails!.originLatLng!,
        widget.userRideRequestDetails!.destinationLatLng!,
        Theme.of(context).brightness == Brightness.dark,
        showLoadingDialog: false
      );
    }
  }

  void createHelperIconMarker({Size size = const Size(4, 4)}) {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context, size: size);
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/location_535137.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  void saveAssignedHelperDetailsToUserRideRequest() async {
    try {
      DatabaseReference databaseReference = FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!);

      Map helperLocationDataMap = {
        "latitude": helperCurrentPosition!.latitude.toString(),
        "longitude": helperCurrentPosition!.longitude.toString(),
      };

      if (mounted) {
        await databaseReference.child("helperId").once().then((snap) async {
          if (snap.snapshot.value != "waiting") {
            await databaseReference.child("helperLocation").set(helperLocationDataMap);
            await databaseReference.child("status").set("accepted");
            await databaseReference.child("helperId").set(onlineHelperData.id);
            await databaseReference.child("helperName").set(onlineHelperData.name);
            await databaseReference.child("helperPhone").set(onlineHelperData.phone);
            await databaseReference.child("ratings").set(onlineHelperData.ratings);
            await databaseReference.child("vehicle_details").set(
                "${onlineHelperData.vehicle_model} ${onlineHelperData.vehicle_number} (${onlineHelperData.vehicle_color})");
          } else {
            Fluttertoast.showToast(msg: "This ride request is already accepted by another helper.");
            Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
          }
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  void saveRideRequestIdToHelperHistory(double fareAmount) {
    DatabaseReference tripHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("helpers")
        .child(firebaseAuth.currentUser!.uid)
        .child("tripsHistory");

    Map<String, dynamic> tripDetailsMap = {
      "time": DateTime.now().toString(),
      "originAddress": widget.userRideRequestDetails!.originAddress,
      "destinationAddress": widget.userRideRequestDetails!.destinationAddress,
      "status": "ended",
      "fareAmount": fareAmount.toString(), // Save the fare amount for this trip
      "userName": widget.userRideRequestDetails!.userName,
      "userPhone": widget.userRideRequestDetails!.userPhone,
    };

    tripHistoryRef.child(widget.userRideRequestDetails!.rideRequestId!).set(tripDetailsMap);
  }


  void endTripNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(message: "Please Wait..."),
    );

    var tripDirectionDetails;
    try {
      // Get the tripDirectionDetails = distance between origin and destination
      var originLatLng = widget.userRideRequestDetails!.originLatLng!;
      var destinationLatLng = widget.userRideRequestDetails!.destinationLatLng!;

      tripDirectionDetails = await AssistantsMethods.obtainOriginToDestinationDirectionDetails(
          originLatLng, destinationLatLng);
    } finally {
      if (mounted) {
        Navigator.pop(context); // Pop the ProgressDialog
      }
    }

    if (tripDirectionDetails == null) {
      Fluttertoast.showToast(msg: "Failed to get trip details. Please try again.");
      return; // Exit if we couldn't get details
    }

    String? vehicleType = widget.userRideRequestDetails?.vehicleType;

    // Fare amount
    double totalFareAmount = AssistantsMethods.calculateFareAmountFromOriginToDestination(
        tripDirectionDetails, vehicleType);

    // Update the fare amount in the database
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("fareAmount")
        .set(totalFareAmount.toString());

    // Update the ride status to "ended"
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("status")
        .set("ended");

    // Display fare amount in dialog box
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => FareAmountCollectionDialog(
          totalFareAmount: totalFareAmount,
        ),
      );
    }

    // Save fare amount to helper total earning
    saveFareAmountToHelperEarning(totalFareAmount);

    // Save trip details to history with the fare amount for this trip
    saveRideRequestIdToHelperHistory(totalFareAmount); // Pass the fare amount
  }

  void saveFareAmountToHelperEarning(double totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("helpers")
        .child(firebaseAuth.currentUser!.uid)
        .child("earning")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double helperTotalEarnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance
            .ref()
            .child("helpers")
            .child(firebaseAuth.currentUser!.uid)
            .child("earning")
            .set(helperTotalEarnings.toString());
      } else {
        FirebaseDatabase.instance
            .ref()
            .child("helpers")
            .child(firebaseAuth.currentUser!.uid)
            .child("earning")
            .set(totalFareAmount.toString());
      }
    });
  }  void onButtonPressed() async {
    if (buttonTitle == "Arrived") {
      setState(() {
        buttonTitle = "Let's Go";
        rideRequestStatus = "arrived";
      });
    }
    else if (buttonTitle == "Let's Go") {
      setState(() {
        buttonTitle = "End Trip";
        rideRequestStatus = "picked";
      });

      // Draw new route from pickup to destination
      if (onlineHelperCurrentPosition != null && widget.userRideRequestDetails != null) {
        LatLng currentLocation = LatLng(
          onlineHelperCurrentPosition!.latitude,
          onlineHelperCurrentPosition!.longitude
        );

        await drawPolylineFromOriginToDestination(
          currentLocation,
          widget.userRideRequestDetails!.destinationLatLng!,
          Theme.of(context).brightness == Brightness.dark,
        );
      }
    }
    else if (buttonTitle == "End Trip") {
      endTripNow();
    }

    // Update status in Firebase
    if (widget.userRideRequestDetails?.rideRequestId != null) {
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("status")
          .set(rideRequestStatus);
    }
  }

  Widget buildButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  distanceFromOriginToDestinations,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  durationFromOriginToDestinations,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                buttonTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildStatusCard() {
  //   return Positioned(
  //     bottom: 0,
  //     left: 0,
  //     right: 0,
  //     child: Container(
  //       height: 100,
  //       decoration: BoxDecoration(
  //         color: Theme.of(context).cardColor,
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(15),
  //           topRight: Radius.circular(15),
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black26,
  //             blurRadius: 15.0,
  //             spreadRadius: 0.5,
  //             offset: Offset(0.7, 0.7),
  //           ),
  //         ],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               rideRequestStatus == "accepted" ? "Distance to pickup" : "Distance to destination",
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 5),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   distanceFromOriginToDestinations,
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //                 Text(
  //                   durationFromOriginToDestinations,
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    createHelperIconMarker();

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkTheme ? Colors.black : Colors.blueGrey,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: darkTheme ? Colors.white : Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Ride Details",
          style: TextStyle(

            color: darkTheme ? Colors.white : Colors.white,

          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              var helperCurrentLatLng = LatLng(
                helperCurrentPosition!.latitude,
                helperCurrentPosition!.longitude,
              );

              var userPickupLatLng = widget.userRideRequestDetails!.originLatLng;

              updateRouteBasedOnStatus();
            },
          ),

          // Floating Chat Icon
          if (rideRequestStatus == "accepted" || rideRequestStatus == "arrived" || rideRequestStatus == "ontrip")
            Positioned(
              bottom: 300, // Adjust position as needed
              right: 2,
              child: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(12), // Add padding for a larger clickable area
                  decoration: BoxDecoration(
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue, // Background color
                    borderRadius: BorderRadius.circular(30), // Circular shape
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Subtle shadow
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chat,
                    color: darkTheme ? Colors.black : Colors.white, // Icon color
                    size: 20, // Slightly larger icon size
                  ),
                ),
                onPressed: () {
                  // Navigate to the chat screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        rideRequestId: widget.userRideRequestDetails!.rideRequestId!,
                        userName: widget.userRideRequestDetails!.userName!,
                        helperName: onlineHelperData.name!,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Bottom UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 18,
                      spreadRadius: 0.5,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Distance and Duration Info
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.black87 : Colors.blueGrey[800],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                size: 16, // decreased size
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Distance",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    distanceFromOriginToDestinations,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                size: 16, // decreased size
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Duration",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    durationFromOriginToDestinations,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(
                      thickness: 1,
                      color: darkTheme ? Colors.amber.shade400 : Colors.white,
                    ),
                    SizedBox(width: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User Icon
                        CircleAvatar(
                          backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white70,
                          child: Icon(
                            Icons.person,
                            color: darkTheme ? Colors.black : Colors.black, // Adjust icon color based on theme
                          ),
                        ),
                        SizedBox(width: 20), // Add some spacing between the icon and the text
                        // User Name
                        Expanded(
                          child: Text(
                            widget.userRideRequestDetails!.userName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: darkTheme ? Colors.amber.shade400 : Colors.white,
                            ),
                          ),
                        ),
                        // Phone Icon Button
                        IconButton(
                          onPressed: () {
                            _makePhoneCall(widget.userRideRequestDetails!.userPhone);
                          },
                          icon: Icon(
                            Icons.phone,
                            color: darkTheme ? Colors.amber.shade400 : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Image.asset(
                          "images/origin.png",
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.userRideRequestDetails!.originAddress!,
                            style: TextStyle(
                              fontSize: 16,
                              color: darkTheme ? Colors.amberAccent : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Image.asset(
                          "images/destination.png",
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.userRideRequestDetails!.destinationAddress!,
                            style: TextStyle(
                              fontSize: 16,
                              color: darkTheme ? Colors.amberAccent : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Divider(
                      thickness: 1,
                      color: darkTheme ? Colors.amber.shade400 : Colors.white,
                    ),
                    SizedBox(height: 1),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // [helper has arrived at user pickup Location] - Arrived Button
                        if (rideRequestStatus == "accepted") {
                          rideRequestStatus = "arrived";

                          FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(widget.userRideRequestDetails!.rideRequestId!)
                              .child("status")
                              .set(rideRequestStatus);

                          setState(() {
                            buttonTitle = "Let's Go";
                            buttonColor = Colors.lightGreen;
                          });

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) => ProgressDialog(
                              message: "Loading...",
                            ),
                          );

                          // Update route to show path to destination
                          await updateRouteBasedOnStatus();

                          Navigator.pop(context);
                        }
                        // [user has been picked from the users current location] - Lets Go button
                        else if (rideRequestStatus == "arrived") {
                          rideRequestStatus = "ontrip";

                          FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(widget.userRideRequestDetails!.rideRequestId!)
                              .child("status")
                              .set(rideRequestStatus);

                          setState(() {
                            buttonTitle = "End Trip";
                            buttonColor = Colors.red;
                          });
                        }
                        // [user/helper  has reached the drop-off location] - End trip button
                        else if (rideRequestStatus == "ontrip") {
                          endTripNow();
                        }
                      },
                      icon: Icon(
                        Icons.directions_car,
                        color: darkTheme ? Colors.black : Colors.indigo,
                        size: 25,
                      ),
                      label: Text(
                        buttonTitle!,
                        style: TextStyle(
                          color: darkTheme ? Colors.black : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // _buildStatusCard(),
        ],
      ),
    );
  }

  void updateUIWithCurrentLocation() async {
    if (onlineHelperCurrentPosition != null) {
      LatLng currentLocation = LatLng(
        onlineHelperCurrentPosition!.latitude,
        onlineHelperCurrentPosition!.longitude
      );

      await drawPolylineFromOriginToDestination(
        currentLocation,
        widget.userRideRequestDetails!.destinationLatLng!,
        Theme.of(context).brightness == Brightness.dark,
      );
    }
  }
}