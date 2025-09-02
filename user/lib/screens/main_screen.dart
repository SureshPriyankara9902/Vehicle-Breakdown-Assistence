
import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/Assistants/assistant_methods.dart';
import 'package:user/Assistants/geofire_assistant.dart';
import 'package:user/global/global.dart';
import 'package:user/global/map_key.dart';
import 'package:user/models/active_nearby_available_helpers.dart';
import 'package:user/screens/drawer_screen.dart';
import 'package:user/screens/precise_pickup_location.dart';
import 'package:user/screens/rate_helper_screen.dart';
import 'package:user/screens/search_places_screen.dart';
import 'package:user/splashScreen/splash_screen.dart';
import '../infoHandler/app_info.dart';
import '../models/directions.dart';
import '../widgets/pay_fare_amount_dialog.dart';
import '../widgets/progress_dialog.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';
import 'package:user/splashScreen/splash_screen.dart' as splash;



Future<void> _makePhoneCall(String phoneNumber) async {
  if (await canLaunch(phoneNumber)) {
    await launch(phoneNumber);
  } else {
    Fluttertoast.showToast(msg: "Could not launch phone call.");
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key:key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<ActiveNearByAvailableHelpers> activeHelpersList = []; // List of active helpers

  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(7.8731, 80.7718),
    zoom: 14.4746,
  );


  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();


  double searchLocationContainerHeight = 220;
  double waitingResponseFromHelperContainerHeight = 0;
  double assignedHelperInfoContainerHeight = 0;
  double suggestedRidesContainerHeight = 0;
  double searchingForHelpersContainerHeight = 0;

  Position? userCurrentPosition;
  Timer? _searchTimeoutTimer;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  int _countdownSeconds = 60; // 1 minute = 60 seconds
  String userName = "";
  String userEmail ="";

  String currentTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

  bool openNavigationDrawer = true;

  bool activeNearbyHelpersKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;

  String _formatTime(int durationInSeconds) {
    int hours = durationInSeconds ~/ 3600; // Convert seconds to hours
    int minutes = (durationInSeconds % 3600) ~/ 60; // Remaining seconds to minutes

    // Format hours and minutes to always show two digits (e.g., 01:05 instead of 1:5)
    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr";
  }

  //String selectedVehicleType ="";


  String helperRideStatus = "Helper is Coming :";
  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubscription;

  List<ActiveNearByAvailableHelpers> onlineNearByAvailableHelpersList = [];


  String userRideRequestStatus = "";
  bool requestPositionInfo = true;


  // 1. Add these variables to your state class
  BitmapDescriptor? serviceStationIcon;
  List<Map<String, dynamic>> serviceStationsList = [];
  bool isLoadingStations = false;
  String? stationFetchError;

// 2. Create the service station icon
  Future<void> createServiceStationIconMarker() async {
    if (serviceStationIcon != null) return;

    try {
      // Use simpler method without resizing first
      serviceStationIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)),
          'images/service station.png'
      );
    } catch (e) {
      print("Error creating service station icon: $e");
      // Fallback
      serviceStationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

// 3. fetch service station details
  Future<void> fetchServiceStations() async {
    if (isLoadingStations) return;

    setState(() {
      isLoadingStations = true;
      stationFetchError = null;
    });

    try {
      DatabaseReference serviceStationsRef = FirebaseDatabase.instance.ref().child("serviceStations");

      final snapshot = await serviceStationsRef.get();
      print("Fetched service stations snapshot: ${snapshot.value}");

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        serviceStationsList.clear();

        data.forEach((key, value) {
          if (value != null) {
            try {
              final stationData = Map<String, dynamic>.from(value as Map);
              print("Processing station: $key - $stationData");

              serviceStationsList.add({
                "id": stationData["id"] ?? key,
                "name": stationData["name"] ?? "Service Station",
                "latitude": _parseDouble(stationData["latitude"]),
                "longitude": _parseDouble(stationData["longitude"]),
                "address": stationData["address"] ?? "",
                "phone": stationData["phone"]?.toString() ?? "",
                "serviceDetails": stationData["serviceDetails"] ?? "",
                //"services": stationData["services"] is Map ? stationData["services"] : {},
              });
            } catch (e) {
              print("Error processing station $key: $e");
            }
          }
        });

        print("Successfully loaded ${serviceStationsList.length} stations");
        displayServiceStationsOnMap();
      } else {
        print("No service stations found in database");
        setState(() {
          stationFetchError = "No service stations available";
        });
      }
    } catch (e) {
      print("Error fetching service stations: $e");
      setState(() {
        stationFetchError = "Failed to load service stations";
      });
    } finally {
      setState(() {
        isLoadingStations = false;
      });
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Set<Marker> serviceStationMarkersSet = {};



  void displayServiceStationsOnMap() async {
    if (!mounted) return;

    // Load custom marker icon
    final BitmapDescriptor customServiceStationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(60, 85)),
      'images/servicest.png',
    );

    // Clear only service station markers
    serviceStationMarkersSet.clear();

    for (var station in serviceStationsList) {
      try {
        LatLng stationPosition = LatLng(
          _parseDouble(station["latitude"]),
          _parseDouble(station["longitude"]),
        );

        Marker stationMarker = Marker(
          markerId: MarkerId("serviceStation_${station["id"] ?? DateTime.now().microsecondsSinceEpoch}"),
          position: stationPosition,
          icon: customServiceStationIcon,
          infoWindow: InfoWindow(
            title: station["name"]?.toString() ?? "Service Station",
            snippet: station["serviceDetails"]?.toString() ?? "Service Station",
          ),
          onTap: () {
            _showServiceStationDetails(station);
          },
          zIndex: 3, // Higher than other markers
        );

        serviceStationMarkersSet.add(stationMarker);
      } catch (e) {
        print("Error creating marker for station: $e");
      }
    }

    if (mounted) {
      setState(() {
        // Remove old service station markers and add new ones
        markersSet.removeWhere((marker) => marker.markerId.value.startsWith('serviceStation_'));
        markersSet.addAll(serviceStationMarkersSet);
      });
    }
  }
  //
  // void _showServiceStationDetails(Map<String, dynamic> station) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       final bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
  //       final Color primaryColor = darkTheme ? Colors.amber.shade400 : Colors.blue;
  //       final Color? bgColor = darkTheme ? Colors.grey[900] : Colors.white;
  //       final Color textColor = darkTheme ? Colors.white : Colors.black87;
  //       final Color secondaryTextColor = darkTheme ? Colors.grey[400]! : Colors.grey[600]!;
  //
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         elevation: 4,
  //         backgroundColor: bgColor,
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               // Header with centered name and service station text
  //               Column(
  //                 children: [
  //                   Text(
  //                     station["name"]?.toString() ?? "Service Station",
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                       color: primaryColor,
  //                       fontSize: 22,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //
  //
  //             const SizedBox(height: 4),
  //                   Text(
  //                     "SERVICE STATION",
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                       color: secondaryTextColor,
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w500,
  //                       letterSpacing: 1.5,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //
  //               const SizedBox(height: 20),
  //
  //               // Details container
  //               Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(12),
  //                   color: darkTheme ? Colors.grey[850] : Colors.grey[50],
  //                 ),
  //                 padding: const EdgeInsets.all(16),
  //                 child: Column(
  //                   children: [
  //                     // Address
  //                     _buildDetailRow(
  //                       icon: Icons.location_on,
  //                       title: "ADDRESS",
  //                       content: station["address"]?.toString() ?? "Not available",
  //                       darkTheme: darkTheme,
  //                       primaryColor: primaryColor,
  //                     ),
  //
  //                     const Padding(
  //                       padding: EdgeInsets.symmetric(vertical: 12),
  //                       child: Divider(height: 1),
  //                     ),
  //
  //                     // Phone
  //                     _buildDetailRow(
  //                       icon: Icons.phone,
  //                       title: "PHONE",
  //                       content: station["phone"]?.toString() ?? "Not available",
  //                       darkTheme: darkTheme,
  //                       primaryColor: primaryColor,
  //                       isClickable: station["phone"]?.isNotEmpty == true,
  //                       onTap: station["phone"]?.isNotEmpty == true
  //                           ? () => _makePhoneCall("tel:${station["phone"]}")
  //                           : null,
  //                     ),
  //
  //                     // Services
  //                     if (station["services"] != null &&
  //                         (station["services"] is Map) &&
  //                         (station["services"] as Map).isNotEmpty) ...[
  //                       const Padding(
  //                         padding: EdgeInsets.symmetric(vertical: 12),
  //                         child: Divider(height: 1),
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             "SERVICES",
  //                             style: TextStyle(
  //                               color: secondaryTextColor,
  //                               fontSize: 12,
  //                               fontWeight: FontWeight.w500,
  //                               letterSpacing: 1.5,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 8),
  //                           ...(station["services"] as Map).entries.map((entry) =>
  //                               Padding(
  //                                 padding: const EdgeInsets.only(bottom: 8),
  //                                 child: Row(
  //                                   children: [
  //                                     Icon(
  //                                       Icons.check_circle,
  //                                       size: 18,
  //                                       color: primaryColor,
  //                                     ),
  //                                     const SizedBox(width: 8),
  //                                     Text(
  //                                       entry.key.toString(),
  //                                       style: TextStyle(
  //                                         color: textColor,
  //                                         fontSize: 14,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               )
  //                           ).toList(),
  //                         ],
  //                       ),
  //                     ],
  //                   ],
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 20),
  //
  //               // Close button
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: primaryColor,
  //                     padding: const EdgeInsets.symmetric(vertical: 14),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   onPressed: () => Navigator.pop(context),
  //                   child: const Text(
  //                     "CLOSE",
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       letterSpacing: 1,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }


  void _showServiceStationDetails(Map<String, dynamic> station) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
        final Color primaryColor = darkTheme ? Colors.amber.shade400 : Colors.blue;
        final Color? bgColor = darkTheme ? Colors.grey[900] : Colors.white;
        final Color textColor = darkTheme ? Colors.white : Colors.black87;
        final Color secondaryTextColor = darkTheme ? Colors.grey[400]! : Colors.grey[600]!;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          backgroundColor: bgColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with centered name and service station text
                Column(
                  children: [
                    Text(
                      station["name"]?.toString() ?? "Service Station",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business, // Building icon
                          size: 16,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "SERVICE STATION",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Details container
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: darkTheme ? Colors.grey[850] : Colors.grey[50],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Address
                      _buildDetailRow(
                        icon: Icons.location_on,
                        title: "ADDRESS",
                        content: station["address"]?.toString() ?? "Not available",
                        darkTheme: darkTheme,
                        primaryColor: primaryColor,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),

                      // Phone
                      _buildDetailRow(
                        icon: Icons.phone,
                        title: "PHONE",
                        content: station["phone"]?.toString() ?? "Not available",
                        darkTheme: darkTheme,
                        primaryColor: primaryColor,
                        isClickable: station["phone"]?.isNotEmpty == true,
                        onTap: station["phone"]?.isNotEmpty == true
                            ? () => _makePhoneCall("tel:${station["phone"]}")
                            : null,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),

                      _buildDetailRow(
                        icon: Icons.location_on,
                        title: "SERVICES",
                        content: station["serviceDetails"]?.toString() ?? "Not available",
                        darkTheme: darkTheme,
                        primaryColor: primaryColor,
                      ),

                      // Services
                      // if (station["services"] != null &&
                      //     (station["services"] is Map) &&
                      //     (station["services"] as Map).isNotEmpty) ...[
                      //   const Padding(
                      //     padding: EdgeInsets.symmetric(vertical: 12),
                      //     child: Divider(height: 1),
                      //   ),
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         "SERVICES",
                      //         style: TextStyle(
                      //           color: secondaryTextColor,
                      //           fontSize: 12,
                      //           fontWeight: FontWeight.w500,
                      //           letterSpacing: 1.5,
                      //         ),
                      //       ),
                      //       const SizedBox(height: 8),
                      //       ...(station["services"] as Map).entries.map((entry) =>
                      //           Padding(
                      //             padding: const EdgeInsets.only(bottom: 8),
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.check_circle,
                      //                   size: 18,
                      //                   color: primaryColor,
                      //                 ),
                      //                 const SizedBox(width: 8),
                      //                 Text(
                      //                   entry.key.toString(),
                      //                   style: TextStyle(
                      //                     color: textColor,
                      //                     fontSize: 14,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           )
                      //       ).toList(),
                      //     ],
                      //   ),
                      // ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "CLOSE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
    required bool darkTheme,
    required Color primaryColor,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: darkTheme ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: TextStyle(

                    fontSize: 15,
                    fontWeight: isClickable ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }






  void locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userCurrentPosition = cPosition;
    });
    print("User Location: ${userCurrentPosition!.latitude}, ${userCurrentPosition!.longitude}");


    LatLng latLngPositions = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPositions, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String humanReadableAddress = await AssistantsMethods.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
    // print("This is our address = " + humanReadableAddress);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeoFireListener();
    AssistantsMethods.readTripsKeysForOnlineUser(context);
  }

  void initializeGeoFireListener() {
    Geofire.initialize("activeHelpers");

    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!  // around 10km
        .listen((map) {
      print("Geofire Map Data: $map");

      if (map != null) {
        var callBack = map["callBack"];

        switch (callBack) {
          case Geofire.onKeyEntered:
            print("Helper Entered: ${map["key"]}"); // Add logging
            GeoFireAssistant.activeNearByAvailableHelpersList.clear();
            ActiveNearByAvailableHelpers activeNearByAvailableHelpers = ActiveNearByAvailableHelpers();
            activeNearByAvailableHelpers.locationLatitude = map["latitude"];
            activeNearByAvailableHelpers.locationLongitude = map["longitude"];
            activeNearByAvailableHelpers.helperId = map["key"];
            GeoFireAssistant.activeNearByAvailableHelpersList.add(activeNearByAvailableHelpers);
            if (activeNearbyHelpersKeysLoaded == true) {
              displayActiveHelpersOnUsersMap();
            }
            break;

          case Geofire.onKeyExited:
            print("Helper Exited: ${map["key"]}"); // Add logging
            GeoFireAssistant.deleteOfflineHelperFromList(map["key"]);
            displayActiveHelpersOnUsersMap();
            break;

          case Geofire.onKeyMoved:
            print("Helper Moved: ${map["key"]}"); // Add logging
            ActiveNearByAvailableHelpers activeNearByAvailableHelpers = ActiveNearByAvailableHelpers();
            activeNearByAvailableHelpers.locationLatitude = map["latitude"];
            activeNearByAvailableHelpers.locationLongitude = map["longitude"];
            activeNearByAvailableHelpers.helperId = map["key"];
            GeoFireAssistant.updateActiveNearByAvailableHelperLocation(activeNearByAvailableHelpers);
            displayActiveHelpersOnUsersMap();
            break;

          case Geofire.onGeoQueryReady:
            print("GeoQuery Ready"); // Add logging
            activeNearbyHelpersKeysLoaded = true;
            displayActiveHelpersOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }





  // displayActiveHelpersOnUsersMap(){
  //
  //   setState(() {
  //     markersSet.clear();
  //     circlesSet.clear();
  //
  //     Set<Marker> helpersMarkerSet = Set<Marker>();
  //
  //     for(ActiveNearByAvailableHelpers eachHelper in GeoFireAssistant.activeNearByAvailableHelpersList){
  //       LatLng eachHelperActivePosition = LatLng(eachHelper.locationLatitude!, eachHelper.locationLongitude!);
  //
  //       Marker marker = Marker(
  //         markerId: MarkerId(eachHelper.helperId!),
  //         position:eachHelperActivePosition,
  //         icon: activeNearbyIcon!,
  //         rotation: 360,
  //       );
  //
  //       helpersMarkerSet.add(marker);
  //     }
  //
  //     setState(() {
  //       markersSet = helpersMarkerSet;
  //     });
  //
  //   });
  // }
  void displayActiveHelpersOnUsersMap() {
    setState(() {
      // Remove only helper markers, keeping service station markers
      markersSet.removeWhere((marker) => !marker.markerId.value.startsWith('serviceStation_'));
      circlesSet.clear();

      Set<Marker> helpersMarkerSet = Set<Marker>();

      for (ActiveNearByAvailableHelpers eachHelper in GeoFireAssistant.activeNearByAvailableHelpersList) {
        LatLng eachHelperActivePosition = LatLng(eachHelper.locationLatitude!, eachHelper.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId(eachHelper.helperId!),
          position: eachHelperActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
          onTap: () {
            _showHelperDetailsDialog(context, eachHelper.helperId!);
          },
        );

        helpersMarkerSet.add(marker);
      }

      setState(() {
        markersSet.addAll(helpersMarkerSet);
      });
    });
  }


  void _showHelperDetailsDialog(BuildContext context, String helperId) async {
    try {
      print("Fetching helper details for ID: $helperId"); // Debug

      DatabaseReference helperRef = FirebaseDatabase.instance.ref().child("helpers").child(helperId);
      DataSnapshot snapshot = await helperRef.get();

      if (!snapshot.exists) {
        print("No data found at path: helpers/$helperId"); // Debug
        Fluttertoast.showToast(msg: "Helper details not found");
        return;
      }

      // More flexible data handling
      dynamic helperData = snapshot.value;
      if (helperData == null || helperData is! Map) {
        print("Invalid helper data format"); // Debug
        Fluttertoast.showToast(msg: "Invalid helper data");
        return;
      }

      // Safely extract values with defaults
      Map<String, dynamic> data = Map<String, dynamic>.from(helperData);
      String name = data["name"]?.toString() ?? "Not available";
      String email = data["email"]?.toString() ?? "Not available";
      String address = data["address"]?.toString() ?? "Not available";
      String phone = data["phone"]?.toString() ?? "Not available";

      print("Helper data loaded: $data"); // Debug

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.green, size: 30),
                      SizedBox(width: 10),
                      Text(
                        "Helper Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey, thickness: 1, height: 20),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        _buildIconDetailRow(Icons.person_outline, name),
                        SizedBox(height: 5),
                        _buildIconDetailRow(Icons.email_outlined, email),
                        SizedBox(height: 5),
                        _buildIconDetailRow(Icons.location_on_outlined, address),
                        SizedBox(height: 5),
                        _buildIconDetailRow(Icons.phone, phone),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print("Error loading helper details: $e"); // Debug
      Fluttertoast.showToast(msg: "Error loading helper details");
    }
  }

// Helper method to build a detail row with icon and value (no label)
  Widget _buildIconDetailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: 24,
        ),
        SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  //
  void createActiveNearByHelperIconMarker() async {
    if (activeNearbyIcon == null) {
      // Load the image from assets
      final ByteData byteData = await rootBundle.load("images/location_535137.png");
      final Uint8List imageData = byteData.buffer.asUint8List();

      // Decode the image
      final ui.Codec codec = await ui.instantiateImageCodec(imageData, targetWidth: 80);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Convert the image to a byte array
      final ByteData? resizedByteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List resizedImageData = resizedByteData!.buffer.asUint8List();

      // Create the BitmapDescriptor from the resized image
      activeNearbyIcon = BitmapDescriptor.fromBytes(resizedImageData);
    }
  }

  //
  // Future<void> createActiveNearByHelperIconMarker() async {
  //   if (activeNearbyIcon == null) {
  //     try {
  //       // Create a picture recorder and canvas to draw the icon
  //       final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //       final Canvas canvas = Canvas(pictureRecorder);
  //
  //       // Define the size of the icon
  //       const double iconSize = 120.0; // Adjust the size as needed
  //
  //       // Draw the Flutter icon on the canvas
  //       final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  //       textPainter.text = TextSpan(
  //         text: String.fromCharCode(Icons.directions_car.codePoint), // Use a Flutter icon
  //         style: TextStyle(
  //           fontSize: iconSize,
  //           fontFamily: Icons.directions_car.fontFamily,
  //           color: Colors.red, // Set the icon color
  //         ),
  //       );
  //       textPainter.layout();
  //       textPainter.paint(canvas, Offset.zero);
  //
  //       // Convert the canvas to an image
  //       final ui.Image image = await pictureRecorder.endRecording().toImage(
  //         iconSize.toInt(),
  //         iconSize.toInt(),
  //       );
  //
  //       // Convert the image to a byte array
  //       final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //       if (byteData != null) {
  //         final Uint8List imageData = byteData.buffer.asUint8List();
  //
  //         // Create the BitmapDescriptor from the byte array
  //         activeNearbyIcon = BitmapDescriptor.fromBytes(imageData);
  //       } else {
  //         throw Exception("Failed to convert icon to byte data.");
  //       }
  //     } catch (e) {
  //       print("Error creating active nearby helper icon marker: $e");
  //     }
  //   }
  // }


  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async {
    // Clear only if we're drawing a new route
    setState(() {
      polylineSet.clear();
      markersSet.removeWhere((marker) => marker.markerId.value != "helper");
      circlesSet.clear();
    });

    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);


    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
    );

    var directionDetailsInfo = await AssistantsMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;

    });

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoOrdinatesList.clear();
    if(decodePolyLinePointsResultList.isNotEmpty){
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng){
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude,pointLatLng.longitude));

      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color:darkTheme? Colors.amberAccent: Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width:5,

      );

      polylineSet.add(polyline);

    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if (originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude,destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }

    else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude,originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else{
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng,65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      infoWindow: InfoWindow(title:originPosition. locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      zIndex: 10,
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(title:destinationPosition. locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      zIndex: 10,
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius:12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center:originLatLng,

    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.red,
      radius:12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center:destinationLatLng,

    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  void showSearchingForHelpersContainer(){
    setState(() {
      searchingForHelpersContainerHeight = 200;
    });
  }



  void showSuggestedRidesContainer(){
    setState(() {
      suggestedRidesContainerHeight = 400;
      bottomPaddingOfMap = 400;
    });
  }





  getAddressFromLatLng() async {
    try{
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude: pickLocation!. longitude ,
          googleMapApiKey:mapKey
      );
      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = pickLocation!.latitude;
        userPickUpAddress.locationLongitude = pickLocation!.longitude;
        userPickUpAddress.locationName = data.address;

        Provider.of <AppInfo>(context,listen:false).updatePickUpLocationAddress(userPickUpAddress);



        // _address = data.address;
      });
    }
    catch (e){
      print(e);
    }
  }



  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  saveRideRequestInformation(String selectedVehicleType) {
    // First set up UI for searching
    setState(() {
      searchingForHelpersContainerHeight = 200;
      suggestedRidesContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });

    //1. save the rideRequest information
    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      //"key:value"
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //"key:value"
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    // Get the current time in a specific format (e.g., "yyyy-MM-dd HH:mm:ss")
    String currentTime = DateTime.now().toString(); // ISO 8601 format
    // Alternatively, you can format it using a package like `intl` for more control over the format.

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": currentTime, // Add the formatted time here
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "helperId": "waiting",
      "vehicleType": selectedVehicleType,
    };

    referenceRideRequest!.set(userInformationMap);

    tripRidesRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }

      if ((eventSnap.snapshot.value as Map)["vehicle_details"] != null) {
        setState(() {
          helperVehicleDetails = (eventSnap.snapshot.value as Map)["vehicle_details"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["helperPhone"] != null) {
        setState(() {
          helperPhone = (eventSnap.snapshot.value as Map)["helperPhone"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["helperName"] != null) {
        setState(() {
          helperName = (eventSnap.snapshot.value as Map)["helperName"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["ratings"] != null) {
        setState(() {
          helperRatings = (eventSnap.snapshot.value as Map)["ratings"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["status"] != null) {
        setState(() {
          userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["helperLocation"] != null) {
        double helperCurrentPositionLat = double.parse((eventSnap.snapshot.value as Map)["helperLocation"]["latitude"].toString());
        double helperCurrentPositionLng = double.parse((eventSnap.snapshot.value as Map)["helperLocation"]["longitude"].toString());

        LatLng helperCurrentPositionLatLng = LatLng(helperCurrentPositionLat, helperCurrentPositionLng);

        // Only update helper marker position if status is "accepted"
        if (userRideRequestStatus == "accepted") {
          // Update only helper marker position without redrawing route
          // Only draw route if it hasn't been drawn yet or if helper's position has changed significantly
          var userPickUpLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
          if (userPickUpLocation != null) {
            LatLng userLatLng = LatLng(
              userPickUpLocation.locationLatitude!,
              userPickUpLocation.locationLongitude!
            );
            
            // Get and draw route
            AssistantsMethods.obtainOriginToDestinationDirectionDetails(
              helperCurrentPositionLatLng,
              userLatLng
            ).then((directionDetails) {
              if (directionDetails != null) {
                PolylinePoints pPoints = PolylinePoints();
                List<PointLatLng> decodedPoints = pPoints.decodePolyline(directionDetails.e_points!);
                pLineCoOrdinatesList.clear();
                
                if (decodedPoints.isNotEmpty) {
                  pLineCoOrdinatesList = decodedPoints
                      .map((point) => LatLng(point.latitude, point.longitude))
                      .toList();
                }

                setState(() {
                  Polyline polyline = Polyline(
                    color: Colors.blue,
                    polylineId: const PolylineId("HelperToUserRoute"),
                    jointType: JointType.round,
                    points: pLineCoOrdinatesList,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                    geodesic: true,
                    width: 5,
                  );

                  polylineSet.add(polyline);
                  
                  // Add markers
                  markersSet.add(
                    Marker(
                      markerId: const MarkerId("helper"),
                      position: helperCurrentPositionLatLng,
                      icon: activeNearbyIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                      infoWindow: const InfoWindow(title: "Helper Location")
                    )
                  );
                  
                  markersSet.add(
                    Marker(
                      markerId: const MarkerId("user"),
                      position: userLatLng,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                      infoWindow: InfoWindow(title: userPickUpLocation.locationName ?? "Your Location")
                    )
                  );
                });

                // Adjust map view to show both positions
                LatLngBounds bounds = LatLngBounds(
                  southwest: LatLng(
                    min(helperCurrentPositionLatLng.latitude, userLatLng.latitude),
                    min(helperCurrentPositionLatLng.longitude, userLatLng.longitude)
                  ),
                  northeast: LatLng(
                    max(helperCurrentPositionLatLng.latitude, userLatLng.latitude),
                    max(helperCurrentPositionLatLng.longitude, userLatLng.longitude)
                  )
                );

                newGoogleMapController?.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 70)
                );
              }
            });
          }
          
          updateArrivalTimeToUserPickupLocation(helperCurrentPositionLatLng);
        }

        //status = arrived
        if (userRideRequestStatus == "arrived") {
          setState(() {
            helperRideStatus = "Helper has arrived";
            polylineSet.clear();
            markersSet.clear();
            circlesSet.clear();
          });
        }

        //status = ontrip
        if (userRideRequestStatus == "ontrip") {
          if (polylineSet.isEmpty) {  // Only draw route if it hasn't been drawn yet
            bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
            drawPolyLineFromOriginToDestination(darkTheme).then((_) {
              // Add helper marker after route is drawn
              markersSet.add(
                Marker(
                  markerId: const MarkerId("helper"),
                  position: helperCurrentPositionLatLng,
                  icon: activeNearbyIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  infoWindow: const InfoWindow(title: "Helper Location")
                )
              );
              updateArrivalTimeToUserDropOffLocation(helperCurrentPositionLatLng);
            });
          } else {
            // Just update helper marker position
            markersSet.removeWhere((marker) => marker.markerId.value == "helper");
            markersSet.add(
              Marker(
                markerId: const MarkerId("helper"),
                position: helperCurrentPositionLatLng,
                icon: activeNearbyIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: "Helper Location")
              )
            );
            updateArrivalTimeToUserDropOffLocation(helperCurrentPositionLatLng);
          }
        }

        // if (userRideRequestStatus == "ended") {
        //   if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
        //     double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());
        //
        //     var response = await showDialog(
        //       context: context,
        //       builder: (BuildContext context) => PayFareAmountDialog(
        //         fareAmount: fareAmount,
        //       ),
        //     );
        //
        //     // if (response == "Cash Paid") {
        //     //   // Check if helperId exists before navigating
        //     //   if ((eventSnap.snapshot.value as Map)["helperId"] != null) {
        //     //     String assignedHelperId = (eventSnap.snapshot.value as Map)["helperId"].toString();
        //     //
        //     //     Future.delayed(Duration(seconds: 3), () {
        //     //       Navigator.push(
        //     //         context,
        //     //         MaterialPageRoute(
        //     //           builder: (c) => RateHelperScreen(
        //     //             assignedHelperId: assignedHelperId,
        //     //           ),
        //     //         ),
        //     //       );
        //     //     });
        //     //
        //     //   }
        //     // }
        //
        //     if (response == "Cash Paid") {
        //       if ((eventSnap.snapshot.value as Map)["helperId"] != null) {
        //
        //         String assignedHelperId = (eventSnap.snapshot.value as Map)["helperId"].toString();
        //
        //         Navigator.pushReplacement(
        //           context,
        //           MaterialPageRoute(
        //             builder: (c) => RateHelperScreen(
        //               assignedHelperId: assignedHelperId,
        //             ),
        //           ),
        //         );
        //       }
        //     }
        //
        //   }
        // }

        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(
              context: context,
              builder: (BuildContext context) => PayFareAmountDialog(
                fareAmount: fareAmount,
              ),
            );

            if (response == "Cash Paid") {
              if ((eventSnap.snapshot.value as Map)["helperId"] != null) {
                // Cancel the subscription before navigating
                tripRidesRequestInfoStreamSubscription?.cancel();

                String assignedHelperId = (eventSnap.snapshot.value as Map)["helperId"].toString();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (c) => RateHelperScreen(
                      assignedHelperId: assignedHelperId,

                    ),
                  ),
                      (route) => false, // This removes all previous routes
                );
              }
            }
          }
        }
      }
    });

    onlineNearByAvailableHelpersList = GeoFireAssistant.activeNearByAvailableHelpersList;
    searchNearestOnlineHelpers(selectedVehicleType);
  }

  searchNearestOnlineHelpers(String selectedVehicleType) async {
    // Start the 1-minute timeout timer
    // Initialize countdown
    setState(() => _countdownSeconds = 60);

    // Start the 1-minute timeout timer
    _searchTimeoutTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          timer.cancel();
          if (userRideRequestStatus.isEmpty || userRideRequestStatus == "waiting") {
            referenceRideRequest!.remove();
            setState(() {
              searchingForHelpersContainerHeight = 0;
              suggestedRidesContainerHeight = 0;
            });
            Fluttertoast.showToast(msg: "No helpers found within 1 minute. Please try again.");
          }
        }
      });
    });

    if(onlineNearByAvailableHelpersList.length == 0) {
      _searchTimeoutTimer?.cancel(); // Cancel timer if no helpers available
      referenceRideRequest!.remove();
      setState(() {
        polylineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoOrdinatesList.clear();
      });

      Fluttertoast.showToast(msg: "No Online Nearest Helpers Available");
      Fluttertoast.showToast(msg: "Search Again. \n Restart App");

      Future.delayed(Duration(milliseconds: 4000), (){
        referenceRideRequest!.remove();
        Navigator.push(context,MaterialPageRoute(builder: (c) => SplashScreen()));
      });
      return;
    }

    await retrieveOnlineHelpersInformation(onlineNearByAvailableHelpersList);
    print("Helper List: " + helpersList.toString());

    for(int i = 0;i<helpersList.length; i++){
      if(helpersList[i]["vehicle_details"]["type"] == selectedVehicleType){
        AssistantsMethods.sendNotificationToHelperNow(helpersList[i]["token"], referenceRideRequest!.key!,context);
      }
    }

    Fluttertoast.showToast(msg: "Notification sent successfully");

    showSearchingForHelpersContainer();

    await FirebaseDatabase.instance.ref().child("All Ride Requests").child(referenceRideRequest!.key!).child("helperId").onValue.listen((eventRideRequestSnapshot){
      print("EventSnapshot: ${eventRideRequestSnapshot.snapshot.value}");
      if(eventRideRequestSnapshot.snapshot.value != null){
        if(eventRideRequestSnapshot.snapshot.value != "waiting"){
          _searchTimeoutTimer?.cancel(); // Cancel timer if helper is found
          showUIForAssignedHelperInfo();
        }
      }
    });
  }

  updateArrivalTimeToUserPickupLocation(helperCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var userPickUpLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;

      if (userPickUpLocation == null) {
        return;
      }

      LatLng userPickUpPosition = LatLng(userPickUpLocation.locationLatitude!, userPickUpLocation.locationLongitude!);

      var directionDetailsInfo = await AssistantsMethods.obtainOriginToDestinationDirectionDetails(
        helperCurrentPositionLatLng, userPickUpPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        helperRideStatus = "Helper is coming: ${directionDetailsInfo.duration_text.toString()} "
            "(Distance: ${directionDetailsInfo.distance_text.toString()})";
      });

      requestPositionInfo = true;
    }
  }

  updateArrivalTimeToUserDropOffLocation(helperCurrentPositionLatLng) async{
    if(requestPositionInfo == true){
      requestPositionInfo = false;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
        dropOffLocation!.locationLatitude!,
        dropOffLocation.locationLongitude!,
      );

      var directionDetailsInfo = await AssistantsMethods.obtainOriginToDestinationDirectionDetails(
          helperCurrentPositionLatLng,
          userDestinationPosition
      );

      if(directionDetailsInfo == null){
        return;
      }
      // setState(() {
      //   helperRideStatus = "Going Towards Destination: " + directionDetailsInfo.duration_text.toString();
      //
      // });
      setState(() {
        helperRideStatus = "Full Journey: ${directionDetailsInfo.duration_text} ${directionDetailsInfo.distance_text}";
      });

      requestPositionInfo =true;
    }
  }


  retrieveOnlineHelpersInformation(List onlineNearestHelpersList) async {
    helpersList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("helpers");

    for(int i = 0;i< onlineNearestHelpersList.length; i++){
      await ref.child(onlineNearestHelpersList[i].helperId.toString()).once().then((dataSnapshot){
        var helperKeyInfo = dataSnapshot.snapshot.value;

        helpersList.add(helperKeyInfo);
        print("helper key information = " + helpersList.toString());
      });
    }
  }


  showUIForAssignedHelperInfo(){
    setState(() {
      waitingResponseFromHelperContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedHelperInfoContainerHeight = 200;
      suggestedRidesContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Clear the state when the app restarts
    Provider.of<AppInfo>(context, listen: false).clearState();

    checkIfLocationPermissionAllowed();
    fetchServiceStations();

  }




  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    createActiveNearByHelperIconMarker();

    final duration = tripDirectionDetailsInfo?.duration_value ?? 0;
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;


    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },


      child: Scaffold(
        key:_scaffoldState,
        drawer:DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding:EdgeInsets.only(top:50, bottom:bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markersSet,
              circles: circlesSet,

              onMapCreated: (GoogleMapController controller){
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap = 350;

                });

                locateUserPosition();
              },

              onCameraMove: (CameraPosition position){
                if(pickLocation != position.target){
                  setState(() {
                    pickLocation = position.target;
                  });
                }
              },

              onCameraIdle: (){
                getAddressFromLatLng();
              },

            ),

            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding:EdgeInsets.only(bottom: bottomPaddingOfMap),
            //     child: Image.asset("images/pick.png",height:45, width:45,),
            //   ),
            // ),

            Positioned(
              top: 150,
              right: 8,
              child: IconButton(
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                  child: isLoadingStations
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                      : Icon(
                    Icons.refresh,
                    key: ValueKey('refresh_icon'),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () {
                  if (!isLoadingStations) {
                    fetchServiceStations();
                  }
                },
                splashRadius: 20, // Controls splash effect size
              ),
            ),

            // 7. Add error display (optional)
            if (stationFetchError != null)
              Positioned(
                top: 200,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    stationFetchError!,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),


            //custom hamberger button for drawer

            Positioned(
              top: 50,
              left: 20,
              child: Container(
                child: GestureDetector(
                  onTap: (){
                    _scaffoldState.currentState!.openDrawer();
                  },
                  child: CircleAvatar(
                    backgroundColor: darkTheme ? Colors.amber.shade400: Colors.white,
                    child: Icon(
                      Icons.menu,
                      color: darkTheme ? Colors.black : Colors.black,
                    ),
                  ),
                ),

              ),
            ),


            //ui for searching location
            // Positioned(
            //   bottom:0,
            //   left: 0,
            //   right: 0,
            //   child: Padding(
            //     padding:EdgeInsets.fromLTRB(10,50,10,10),
            //     child:Column(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children:[
            //         Container(
            //             padding:EdgeInsets.all(10),
            //             decoration: BoxDecoration(
            //                 color: darkTheme? Colors.black : Colors.transparent,
            //                 borderRadius: BorderRadius.circular(5)
            //             ),
            //
            //             child: Column(
            //               children: [
            //                 Container(
            //                   decoration: BoxDecoration(
            //                     color: darkTheme ? Colors.grey.shade900 : Colors.grey.shade100,
            //                     borderRadius: BorderRadius.circular(5),
            //
            //                   ),
            //
            //                   child: Column(
            //                     children: [
            //                       Padding(
            //                         padding:EdgeInsets.all(5),
            //                         child: Row(
            //                             children:[
            //                               Icon(Icons.location_on_outlined, color: darkTheme? Colors.amber.shade400 : Colors.green,),
            //                               SizedBox(width:10,),
            //                               Column(
            //                                 crossAxisAlignment: CrossAxisAlignment.start,
            //                                 children: [
            //                                   Text("From",
            //                                     style:TextStyle(
            //                                       color:darkTheme ? Colors.amber.shade400 : Colors.green,
            //                                       fontSize: 12,
            //                                       fontWeight: FontWeight.bold,
            //                                     ),
            //                                   ),
            //
            //                                   Text(
            //                                     Provider.of<AppInfo>(context).userPickUpLocation !=null
            //                                         ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName!
            //                                         : "Not Getting Address",
            //                                     style:TextStyle(color: Colors.grey, fontSize:14),
            //
            //                                   )
            //                                 ],
            //                               )
            //                             ]
            //                         ),
            //
            //                       ),
            //
            //                       SizedBox(height: 8,),
            //
            //                       Divider(
            //                         height: 1,
            //                         thickness:1,
            //                         color:darkTheme? Colors.amber.shade400: Colors.grey,
            //                       ),
            //
            //                       SizedBox(height: 8,),
            //
            //                       Padding (
            //                           padding:EdgeInsets.all(5),
            //                           child:GestureDetector(
            //                             onTap: () async{
            //
            //                               //goto search places screen
            //                               var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c) => SearchPlacesScreen()));
            //                               if(responseFromSearchScreen =="obtainedDropoff"){
            //                                 setState(() {
            //                                   openNavigationDrawer = false;
            //
            //                                 });
            //                               }
            //
            //                               await drawPolyLineFromOriginToDestination(darkTheme);
            //
            //
            //                             },
            //
            //                             child: Row(
            //                                 children:[
            //                                   Icon(Icons.location_on_outlined, color: darkTheme? Colors.amber.shade400 : Colors.red,),
            //                                   SizedBox(width:10,),
            //                                   Column(
            //                                     crossAxisAlignment: CrossAxisAlignment.start,
            //                                     children: [
            //                                       Text("To",
            //                                         style:TextStyle(
            //                                           color:darkTheme ? Colors.amber.shade400 : Colors.red,
            //                                           fontSize: 12,
            //                                           fontWeight: FontWeight.bold,
            //                                         ),
            //                                       ),
            //
            //                                       Text(
            //                                         Provider.of<AppInfo>(context).userDropOffLocation !=null
            //                                             ?Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
            //                                             : "where to go",
            //                                         style:TextStyle(color: Colors.grey, fontSize:14),
            //
            //                                       )
            //                                     ],
            //                                   )
            //                                 ]
            //                             ),
            //                           )
            //                       )
            //
            //                     ],
            //                   ),
            //                 ),
            //
            //                 SizedBox(height: 5,),
            //
            //                 Row(
            //                   mainAxisAlignment:MainAxisAlignment.center ,
            //                   children: [
            //                     ElevatedButton(
            //                       onPressed: (){
            //                         Navigator.push(context,MaterialPageRoute(builder: (c) => PrecisePickUpScreen()));
            //
            //                       },
            //                       child: Text(
            //                         "Change Pick Up",
            //                         style:TextStyle(
            //                           color:darkTheme ? Colors.black: Colors.white,
            //
            //
            //                         ),
            //                       ),
            //                       style: ElevatedButton.styleFrom(
            //                           backgroundColor:darkTheme? Colors.amber.shade400 : Colors.green,
            //                           textStyle: TextStyle(
            //                             fontWeight: FontWeight.bold,
            //                             fontSize: 16,
            //                           )
            //                       ),
            //                     ),
            //
            //                     SizedBox(width: 10,),
            //
            //                     ElevatedButton(
            //                       onPressed: (){
            //                         if(Provider.of<AppInfo>(context,listen: false).userDropOffLocation != null){
            //                           showSuggestedRidesContainer();
            //
            //                         }
            //
            //                         else{
            //                           Fluttertoast.showToast(msg: "Please select Your Destination Location");
            //
            //                         }
            //                       },
            //                       child: Text(
            //                         "Request Vehicle",
            //                         style:TextStyle(
            //                           color:darkTheme ? Colors.black: Colors.white,
            //
            //
            //                         ),
            //                       ),
            //                       style: ElevatedButton.styleFrom(
            //                           backgroundColor:darkTheme? Colors.amber.shade400 : Colors.black,
            //                           textStyle: TextStyle(
            //                             fontWeight: FontWeight.bold,
            //                             fontSize: 16,
            //
            //                           )
            //                       ),
            //                     ),
            //
            //
            //
            //
            //
            //                   ],
            //                 )
            //
            //
            //               ],
            //             )
            //
            //         )
            //       ],
            //     ),
            //   ),
            // ),


            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Main Container
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.grey.shade900 : Colors.blueGrey[900],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Pickup Location Card
                          Container(
                            decoration: BoxDecoration(
                              color: darkTheme ? Colors.grey.shade800 : Colors.blueGrey[900],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  // Pickup Location Row
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: darkTheme ? Colors.amber.shade400 : Colors.green,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "From",
                                              style: TextStyle(
                                                color: darkTheme ? Colors.amber.shade400 : Colors.green,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<AppInfo>(context).userPickUpLocation != null
                                                  ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName!
                                                  : "Click 'Pickup Me' and Select Your Location",
                                              style: TextStyle(
                                                color: darkTheme ? Colors.white : Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Divider(
                                    height: 2,
                                    thickness: 1,
                                    color: darkTheme ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                  SizedBox(height: 10),
                                  // Dropoff Location Row
                                  GestureDetector(
                                    onTap: () async {
                                      // Go to search places screen
                                      var responseFromSearchScreen = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (c) => SearchPlacesScreen()),
                                      );
                                      if (responseFromSearchScreen == "obtainedDropoff") {
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }
                                      await drawPolyLineFromOriginToDestination(darkTheme);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: darkTheme ? Colors.amber.shade400 : Colors.red,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "To",
                                                style: TextStyle(
                                                  color: darkTheme ? Colors.amber.shade400 : Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                Provider.of<AppInfo>(context).userDropOffLocation != null
                                                    ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                                    : "Where to go? Click this Field ",
                                                style: TextStyle(
                                                  color: darkTheme ? Colors.white : Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          // Buttons Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Change Pickup Button
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (c) => PrecisePickUpScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.black.withOpacity(0.3),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_location,
                                      color: darkTheme ? Colors.black : Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Pickup Me",
                                      style: TextStyle(
                                        color: darkTheme ? Colors.black : Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              // Request Vehicle Button
                              ElevatedButton(
                                onPressed: () {
                                  if (Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null) {
                                    showSuggestedRidesContainer();
                                  } else {
                                    Fluttertoast.showToast(msg: "Please select Your Destination Location");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue[700],
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                  shadowColor: Colors.grey.withOpacity(0.3),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      color: darkTheme ? Colors.black : Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Request Vehicle",
                                      style: TextStyle(
                                        color: darkTheme ? Colors.black : Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),






            //ui for suggested rides
            Positioned(
              left: 2,
              right: 2,
              bottom: 3,
              child: Container(
                height: suggestedRidesContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.blueGrey[900],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  // padding: EdgeInsets.all(15),
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tripDirectionDetailsInfo != null)

                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: darkTheme ? Colors.amber.shade400 : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                Provider.of<AppInfo>(context).userPickUpLocation != null
                                    ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName!
                                    : "Your Current Location",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkTheme ? Colors.amber.shade400 : Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              Provider.of<AppInfo>(context).userDropOffLocation != null
                                  ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                  : "Where to go?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkTheme ? Colors.amber.shade400 : Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.directions,
                            color: (darkTheme ?? false) ? Colors.amber.shade400 : Colors.blue,
                          ),
                          SizedBox(width: 18),


                          Text(
                            "Distance: ${((tripDirectionDetailsInfo?.distance_value ?? 0) / 1000).toStringAsFixed(1)} km    "
                                " $hours h $minutes min",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (darkTheme ?? false) ? Colors.amber.shade400 : Colors.white,
                              fontSize: 18,
                            ),
                          ),


                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "SUGGESTED VEHICLES",
                        style: TextStyle(
                          color: darkTheme ? Colors.amber.shade400 : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              selectedVehicleType = "Flatbed Truck";
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Flatbed Truck"
                                    ? (darkTheme ? Colors.amber.shade400 : Colors.greenAccent)
                                    : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Image.asset("images/Flatbed Truck.png", scale: 8),
                                    SizedBox(height: 8),
                                    Text(
                                      "Flatbed T",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "Flatbed Truck"
                                            ? (darkTheme ? Colors.black : Colors.white)
                                            : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    if (tripDirectionDetailsInfo != null)
                                      Text(
                                        "Rs. ${(AssistantsMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)*1).toStringAsFixed(1)}",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    else
                                      Text("null", style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                          GestureDetector(
                            onTap: () {
                              selectedVehicleType = "Wheel-Lift Truck";
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Wheel-Lift Truck"
                                    ? (darkTheme ? Colors.amber.shade400 : Colors.yellow)
                                    : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Image.asset("images/Wheel-Lift Truck.png", scale: 8),
                                    SizedBox(height: 8),
                                    Text(
                                      "Wheel-Lift T",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "Wheel-Lift Truck"
                                            ? (darkTheme ? Colors.black : Colors.white)
                                            : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    if (tripDirectionDetailsInfo != null)
                                      Text(
                                        "Rs. ${(AssistantsMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)*2).toStringAsFixed(1)}",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    else
                                      Text("null", style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                          GestureDetector(
                            onTap: () {
                              selectedVehicleType = "Heavy Wrecker";
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Heavy Wrecker"
                                    ? (darkTheme ? Colors.amber.shade400 : Colors.yellow)
                                    : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Image.asset("images/Heavy Wrecker.png", scale: 8),
                                    SizedBox(height: 8),
                                    Text(
                                      "Heavy Wrecker",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "Heavy Wrecker"
                                            ? (darkTheme ? Colors.black : Colors.white)
                                            : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    if (tripDirectionDetailsInfo != null)
                                      Text(
                                        "Rs. ${(AssistantsMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)*3).toStringAsFixed(1)}",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    else
                                      Text("null", style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (selectedVehicleType != "") {
                              saveRideRequestInformation(selectedVehicleType);
                            } else {
                              Fluttertoast.showToast(msg: "Please Select Vehicle");
                            }
                          },
                          child: Center(
                            child: Container(
                              width: 200, // Set your desired width
                              height: 60, // Set your desired height
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: darkTheme ? Colors.amber.shade400 : Colors.white54,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Center the icon and text
                                children: [
                                  Icon(
                                    Icons.directions_car, // Use your desired icon
                                    color: darkTheme ? Colors.black : Colors.black, // Change icon color based on theme
                                  ),
                                  SizedBox(width: 8), // Add spacing between the icon and text
                                  Text(
                                    "Request Ride",
                                    style: TextStyle(
                                      color: darkTheme ? Colors.black : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            //  Request Ride
            Positioned(
              bottom: 1,
              left: 2,
              right: 2,
              child: Container(
                height: searchingForHelpersContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.grey[900] : Colors.blueGrey[900],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Countdown and progress indicator
                      Column(
                        children: [
                          Text(
                            "Searching for available helpers",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkTheme ? Colors.white : Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "$_countdownSeconds seconds remaining",
                            style: TextStyle(
                              fontSize: 15,
                              color: darkTheme ? Colors.amber : Colors.grey,
                            ),
                          ),
                          SizedBox(height: 15),
                          LinearProgressIndicator(
                            backgroundColor: darkTheme ? Colors.grey[800] : Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              darkTheme ? Colors.amber : Colors.green,
                            ),
                            minHeight: 6,
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _searchTimeoutTimer?.cancel();
                            referenceRideRequest!.remove();
                            setState(() {
                              searchingForHelpersContainerHeight = 0;
                              suggestedRidesContainerHeight = 0;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTheme ? Colors.red[800] : Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "Cancel Search",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),



            if (userRideRequestStatus == "accepted" || userRideRequestStatus == "arrived" || userRideRequestStatus == "ontrip")
              Positioned(
                bottom: 300, // Adjust position as needed
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    if (referenceRideRequest != null &&
                        userModelCurrentInfo != null &&
                        helperId != null &&
                        helperName != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            rideRequestId: referenceRideRequest!.key!,
                            userId: userModelCurrentInfo!.id!,
                            userName: userModelCurrentInfo!.name!,
                            helperId: helperId!,
                            helperName: helperName!,
                          ),
                        ),
                      );
                    } else {
                      // Handle null case (e.g., show a snackbar or log an error)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Unable to open chat. Missing required data.")),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chat,
                      color: darkTheme ? Colors.black : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),



            //ui for displaying assigned helpers information
            Positioned(
              bottom: 8,
              left: 3,
              right: 3,
              child: Container(
                height: assignedHelperInfoContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.grey[900] : Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 0,
                      spreadRadius: 0,
                      offset: Offset(0, 14),
                    ),
                  ],
                  border: Border.all(
                    color: darkTheme ? Colors.grey[800]! : Colors.blueGrey[900]!,
                    width: 1,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            helperRideStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Divider(
                          thickness: 1,
                          color: Colors.white.withOpacity(0.2),
                          height: 1,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: darkTheme ? Colors.amber[400] : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person,
                                color: darkTheme ? Colors.black : Colors.blueGrey[800],
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    helperName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        helperRatings,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset(
                                selectedVehicleType == "Flatbed Truck"
                                    ? "images/Flatbed Truck.png"
                                    : selectedVehicleType == "Wheel-Lift Truck"
                                    ? "images/Wheel-Lift Truck.png"
                                    : "images/Heavy Wrecker.png",
                                width: 45,
                                height: 45,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Divider(
                          thickness: 1,
                          color: Colors.white.withOpacity(0.2),
                          height: 1,
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _makePhoneCall("tel:$helperPhone");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkTheme ? Colors.amber[400] : Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            icon: Icon(
                              Icons.phone,
                              color: darkTheme ? Colors.black : Colors.blueGrey[800],
                              size: 20,
                            ),
                            label: Text(
                              "CALL HELPER",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: darkTheme ? Colors.black : Colors.blueGrey[800],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),


          ],

        ),
      ),
    );
  }
}
