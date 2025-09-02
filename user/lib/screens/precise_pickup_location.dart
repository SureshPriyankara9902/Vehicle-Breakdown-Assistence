// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:geocoder2/geocoder2.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as loc;
// import 'package:provider/provider.dart';
//
// import '../Assistants/assistant_methods.dart';
// import '../global/map_key.dart';
// import '../infoHandler/app_info.dart';
// import '../models/directions.dart';
//
// class PrecisePickUpScreen extends StatefulWidget {
//   const PrecisePickUpScreen({super.key});
//
//   @override
//   State<PrecisePickUpScreen> createState() => _PrecisePickUpScreenState();
// }
//
// class _PrecisePickUpScreenState extends State<PrecisePickUpScreen> {
//
//   LatLng? pickLocation;
//   loc.Location location = loc.Location();
//   String? _address;
//
//   final Completer<GoogleMapController> _controllerGoogleMap = Completer();
//   GoogleMapController? newGoogleMapController;
//
//   Position? userCurrentPosition;
//   double bottomPaddingOfMap = 0;
//
//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//
//
//   GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
//
//
//   locateUserPosition() async {
//     Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//
//     //Position cPosition = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
//
//     userCurrentPosition = cPosition;
//
//     LatLng latLngPositions = LatLng(userCurrentPosition!.latitude,userCurrentPosition!.longitude);
//     CameraPosition cameraPosition = CameraPosition(target:latLngPositions, zoom:10);
//
//     newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//
//     String humanReadableAddress = await AssistantsMethods.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
//
//   }
//
//   getAddressFromLatLng() async {
//     try{
//       GeoData data = await Geocoder2.getDataFromCoordinates(
//           latitude: pickLocation!.latitude,
//           longitude: pickLocation!. longitude ,
//           googleMapApiKey:mapKey
//       );
//       setState(() {
//         Directions userPickUpAddress = Directions();
//         userPickUpAddress.locationLatitude = pickLocation!.latitude;
//         userPickUpAddress.locationLongitude = pickLocation!.longitude;
//         userPickUpAddress.locationName = data.address;
//
//         Provider.of <AppInfo>(context,listen:false).updatePickUpLocationAddress(userPickUpAddress);
//
//
//
//         _address = data.address;
//       });
//     }
//     catch (e){
//       print(e);
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
//
//     return Scaffold(
//       body: Stack(
//         children:[
//           GoogleMap(
//             padding:EdgeInsets.only(top:30, bottom:bottomPaddingOfMap),
//             mapType: MapType.normal,
//             myLocationEnabled: true,
//             zoomGesturesEnabled: true,
//             zoomControlsEnabled: true,
//             initialCameraPosition: _kGooglePlex,
//
//
//             onMapCreated: (GoogleMapController controller){
//               _controllerGoogleMap.complete(controller);
//               newGoogleMapController = controller;
//
//               setState(() {
//                 bottomPaddingOfMap = 50;
//
//               });
//
//               locateUserPosition();
//             },
//
//             onCameraMove: (CameraPosition position){
//               if(pickLocation != position.target){
//                 setState(() {
//                   pickLocation = position.target;
//                 });
//               }
//             },
//
//             onCameraIdle: (){
//               getAddressFromLatLng();
//             },
//
//           ),
//
//           Align(
//             alignment: Alignment.center,
//             child: Padding(
//               padding:EdgeInsets.only(top:60,bottom: bottomPaddingOfMap),
//               child: Image.asset("images/pick.png",height:45, width:45,),
//             ),
//           ),
//
//           Positioned(
//             top: 40,
//             right: 20,
//             left: 20,
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.black),
//                 color:Colors.white,
//               ),
//
//               padding: EdgeInsets.all(20),
//               child: Text(
//                 Provider.of<AppInfo>(context).userPickUpLocation !=null ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName! + "..." : "Not Getting Address",
//               overflow: TextOverflow.visible, softWrap:true,
//               ),
//             ),
//           ),
//
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Padding(
//               padding:EdgeInsets.all(12),
//               child: ElevatedButton(
//                   onPressed: (){
//                     Navigator.pop(context);
//                   },
//
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: darkTheme ? Colors.amber.shade400 :Colors.white,
//                   textStyle: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     )
//
//                   ),
//
//                   child: Text("Set Current Location"),
//                 )
//               ),
//
//
//           ),
//
//
//         ]
//       ),
//     );
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';

import '../Assistants/assistant_methods.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/directions.dart';

class PrecisePickUpScreen extends StatefulWidget {
  const PrecisePickUpScreen({super.key});

  @override
  State<PrecisePickUpScreen> createState() => _PrecisePickUpScreenState();
}

class _PrecisePickUpScreenState extends State<PrecisePickUpScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPositions = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPositions, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress = await AssistantsMethods.searchAddressForGeographicCoordinates(userCurrentPosition!, context);

    setState(() {
      _address = humanReadableAddress;
    });
  }

  getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: pickLocation!.latitude,
        longitude: pickLocation!.longitude,
        googleMapApiKey: mapKey,
      );

      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = pickLocation!.latitude;
        userPickUpAddress.locationLongitude = pickLocation!.longitude;
        userPickUpAddress.locationName = data.address;

        Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
        _address = data.address;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkTheme ? Colors.white : Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          ' Pickup Location',
          style: TextStyle(
            color: darkTheme ? Colors.white : Colors.white,
          ),
        ),
        backgroundColor: darkTheme ? Colors.black : Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Stack(
        children: [
          /// Google Map
          GoogleMap(
            padding: EdgeInsets.only(top: 80, bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 60;
              });
              locateUserPosition();
            },
            onCameraMove: (CameraPosition position) {
              if (pickLocation != position.target) {
                setState(() {
                  pickLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              getAddressFromLatLng();
            },
          ),

          /// Location Marker
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              child: Image.asset(
                "images/pick.png",
                height: 65,
                width: 70,
                color: Colors.red, // Set the icon color to red
              ),
            ),
          ),

          /// Address Display Box
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _address ?? "Fetching location...",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// "Set Current Location" Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                // Update the pickLocation to the user's current position
                Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                setState(() {
                  pickLocation = LatLng(cPosition.latitude, cPosition.longitude);
                });

                // Fetch the address for the updated pickLocation
                await getAddressFromLatLng();

                // Optionally, move the camera to the updated location
                newGoogleMapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: pickLocation!,
                      zoom: 15,
                    ),
                  ),
                );

                // Navigate back with the updated location
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.green,
                foregroundColor: darkTheme ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                "Set Current Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Floating Action Button to Re-center
          // Positioned(
          //   bottom: 90,
          //   right: 20,
          //   child: FloatingActionButton(
          //     onPressed: locateUserPosition,
          //     backgroundColor: Colors.blueAccent,
          //     child: Icon(Icons.my_location, color: Colors.white),
          //   ),
          // ),
        ],
      ),
    );
  }


}
