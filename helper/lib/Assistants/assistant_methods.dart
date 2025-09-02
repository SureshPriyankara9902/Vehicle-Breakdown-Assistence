import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helper/Assistants/request_assistant.dart';
import 'package:helper/models/trips_history_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import '../models/user_model.dart';

StreamSubscription<Position>? streamSubscriptionPosition;

class AssistantsMethods{

  static void readCurrantOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(currentUser!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value != null){
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }
  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async {
  //String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&Key=$mapKey";
  String apiUrl = "https://maps.gomaps.pro/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
  String humanReadableAddress = "";

  var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
  if(requestResponse != "Error occured.Failed No Response."){
    humanReadableAddress = requestResponse["result"][0]["formatted_address"];

    Directions userPickUpAddress = Directions();
    userPickUpAddress.locationLatitude = position.latitude;
    userPickUpAddress.locationLongitude = position.longitude;
    userPickUpAddress.locationName = humanReadableAddress;

    Provider.of <AppInfo>(context,listen:false).updatePickUpLocationAddress(userPickUpAddress);
  }

  return humanReadableAddress;
  }

 static Future<DirectionDetailsInfo>obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{
    //String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    String urlOriginToDestinationDirectionDetails = "https://maps.gomaps.pro/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);


     // if(responseDirectionApi == "Error Occure. Failed. No Response"){
     //   return null;
     // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];

    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
    return directionDetailsInfo;
 }

 static Future<void> pauseLiveLocationUpdates() async {
    streamSubscriptionPosition?.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }



  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo,String? vehicleType) {
    // Convert meters to kilometers and calculate fare based on distance only
    double distanceInKilometers = directionDetailsInfo.distance_value! / 1000;

    // Base fare rate per kilometer in Sri Lankan Rupees (LKR)
    double baseFarePerKilometer = 300; // Rs. 300 per kilometer (adjust as needed)

    // Total base fare (only distance-based)
    double totalFareAmount = distanceInKilometers * baseFarePerKilometer;

    // Apply vehicle-specific multiplier
    if (vehicleType == "Flatbed Truck") {
      totalFareAmount *= 1; // Flatbed Truck multiplier
    } else if (vehicleType == "Wheel-Lift Truck") {
      totalFareAmount *= 2; // Wheel-Lift Truck multiplier
    } else if (vehicleType == "Heavy Wrecker") {
      totalFareAmount *= 3; // Heavy Wrecker multiplier
    }

    // Round to 2 decimal places
    return double.parse(totalFareAmount.toStringAsFixed(2));
  }

  //retrive the trips keys for online user
//trip key = ride request key

  static void readTripsKeysForOnlineHelper(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("helperId").equalTo(firebaseAuth.currentUser!.uid).once().then((snap){
      if(snap.snapshot.value != null){
        Map KeysTripsId = snap.snapshot.value as Map;

        //count total number trips and share is with provider
        int overAllTripsCounter = KeysTripsId.length;
        Provider.of<AppInfo> (context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);


        //share trips keys with provider
        List<String> tripsKeysList = [];
        KeysTripsId.forEach((key,value){
          tripsKeysList.add(key);
        });

        Provider.of<AppInfo>(context,listen:false).updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        readTripsHistoryInformation(context);

      }
    });
  }

  // static void readTripsHistoryInformation(context){
  //   var tripsAllKeys = Provider.of<AppInfo>(context,listen:false).historyTripsKeysList;
  //
  //   for(String eachKey in tripsAllKeys){
  //     FirebaseDatabase.instance.ref().child("All Ride Requests").child(eachKey).once().then((snap){
  //       var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);
  //
  //       if((snap.snapshot.value as Map)["status"] == "ended"){
  //         Provider.of<AppInfo>(context,listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
  //
  //       }
  //     });
  //   }
  // }


  static void readTripsHistoryInformation(context) {
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for (String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(eachKey).once().then((snap) {
        if (snap.snapshot.value != null) {
          // Convert the snapshot value (Map) to TripsHistoryModel
          var eachTripHistory = TripsHistoryModel.fromMap(snap.snapshot.value as Map<dynamic, dynamic>);

          if ((snap.snapshot.value as Map)["status"] == "ended") {
            Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
          }
        }
      });
    }
  }

  //readHelperEarning

static void readHelperEarnings(context){
    FirebaseDatabase.instance.ref().child("helpers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
      if(snap.snapshot.value != null){
        String helperEarnings = snap.snapshot.value.toString();
        //String helperEarnings = double.parse(snap.snapshot.value.toString());
        Provider.of<AppInfo>(context, listen: false).updateHelperTotalEarnings(helperEarnings);

      }
    });
    readTripsKeysForOnlineHelper(context);
}

  static void readHelperRatings(context){
    FirebaseDatabase.instance.ref().child("helpers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
      if(snap.snapshot.value != null){
        String helperRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateHelperAverageRatings(helperRatings);

      }
    });


  }
}