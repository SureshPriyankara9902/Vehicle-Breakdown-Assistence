import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user/Assistants/request_assistant.dart';
import 'package:user/global/global.dart';
import 'package:user/global/map_key.dart';
import 'package:user/models/directions.dart';
import 'package:user/models/trips_history_model.dart';
import 'package:user/models/user_model.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import 'package:http/http.dart' as http;

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
    final apiUrl = "https://maps.gomaps.pro/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    try {
      final response = await RequestAssistant.receiveRequest(apiUrl);

      // Check if response is an error message first
      if (response is String && response == "Error occurred. Failed No Response.") {
        return "Unable to fetch address";
      }

      // Ensure response is a Map and contains results
      if (response is! Map || !response.containsKey("results")) {
        return "Invalid address data";
      }

      // Check if results array is empty
      if (response["results"] == null || response["results"].isEmpty) {
        return "Address not found";
      }

      // Safely access the formatted address
      final humanReadableAddress = response["results"][0]["formatted_address"] ?? "Address unavailable";

      final userPickUpAddress = Directions()
        ..locationLatitude = position.latitude
        ..locationLongitude = position.longitude
        ..locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);

      return humanReadableAddress;
    } catch (e) {
      print("Error in searchAddressForGeographicCoordinates: $e");
      return "Error fetching address";
    }
  }

 static Future<DirectionDetailsInfo>obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{
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

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo) {
    // Convert meters to kilometers and calculate fare based on distance only
    double distanceInKilometers = directionDetailsInfo.distance_value! / 1000;

    // Base fare rate per kilometer in Sri Lankan Rupees (LKR)
    double baseFarePerKilometer = 300; // Rs. 300 per kilometer (adjust as needed)

    // Total base fare (only distance-based)
    fareAmount = distanceInKilometers * baseFarePerKilometer;



    // Round to 2 decimal places
    return double.parse(fareAmount.toStringAsFixed(2));
  }


 static sendNotificationToHelperNow(String deviceRegistrationToken, String userRideRequestId, context) async{
    String destinationAddress = userDropOffAddress;

    Map<String,String> headerNotification = {
      'content-Type':'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification = {
      "body":"Destination Address: \n$destinationAddress.",
      "title":"New Trip Request"

    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status":"done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotificationFormat = {
      "notification":bodyNotification,
      "data":dataMap,
      "priority":"high",
      "to":deviceRegistrationToken,
    };

    var responseNotification = http.post(
      //Uri.parse("https://fcm.googleapis.com/fcm/send"),
      Uri.parse("https://fcm.googleapis.com/v1/projects/careride-bd2be/messages:send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
 }
  //retrive the trips keys for online user
  //trip key = ride request key

  static void readTripsKeysForOnlineUser(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("userName").equalTo(userModelCurrentInfo!.name).once().then((snap){
      if(snap.snapshot.value != null){
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number of trips and share it with provider

        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo> (context, listen:false).updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value){
          tripsKeysList.add(key);
        });

        Provider.of<AppInfo> (context, listen: false).updateOverAllTripsKeys(tripsKeysList);

        //get trip keys data - read trips complete info
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context){
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys){
      FirebaseDatabase.instance.ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap)
      {

            var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

            if((snap.snapshot.value as Map)["status"] == "ended"){

              //update or add each history to overalltrips history data list

              Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);



            }

      });
    }
  }



}