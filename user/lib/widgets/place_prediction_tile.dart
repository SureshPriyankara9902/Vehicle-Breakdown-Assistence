import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/Assistants/request_assistant.dart';
import 'package:user/global/map_key.dart';
import 'package:user/widgets/progress_dialog.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';
import '../models/directions.dart';
import '../models/predicted_places.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  const PlacePredictionTileDesign({super.key, this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Setting Up Drop-off. Please Wait..."),
    );

    String placeDirectionDetailsUrl =
        "https://maps.gomaps.pro/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context); // close progress dialog

    if (responseApi == "Error Occured.Failed. No Response.") return;

    if (responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final predictedPlace = widget.predictedPlaces;

    if (predictedPlace == null) return const SizedBox.shrink(); // fallback for safety

    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(predictedPlace.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: darkTheme ? Colors.grey[900] : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.place, size: 30, color: darkTheme ? Colors.amber.shade400 : Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    predictedPlace.main_text ?? "Unknown",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkTheme ? Colors.amber.shade400 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    predictedPlace.secondary_text ?? "No address details",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: darkTheme ? Colors.amber.shade200 : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: darkTheme ? Colors.amber.shade400 : Colors.orange),
          ],
        ),
      ),
    );
  }
}




//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:user/Assistants/request_assistant.dart';
// import 'package:user/global/map_key.dart';
// import 'package:user/widgets/progress_dialog.dart';
// import '../global/global.dart';
// import '../infoHandler/app_info.dart';
// import '../models/directions.dart';
// import '../models/predicted_places.dart';
//
// class PlacePredictionTileDesign extends StatefulWidget {
//   final PredictedPlaces? predictedPlaces;
//
//   PlacePredictionTileDesign({this.predictedPlaces});
//
//   @override
//   State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
// }
//
// class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
//   Future<void> getPlaceDirectionDetails(String? placeId, BuildContext context) async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => ProgressDialog(
//         message: "Setting Up Drop-off. Please Wait...",
//       ),
//     );
//
//     String placeDirectionDetailsUrl =
//         "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
//
//     var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);
//
//     Navigator.pop(context);
//
//     if (responseApi == "Error Occurred. Failed. No Response.") {
//       return;
//     }
//
//     if (responseApi["status"] == "OK") {
//       Directions directions = Directions();
//       directions.locationName = responseApi["result"]["name"];
//       directions.locationId = placeId;
//       directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
//       directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];
//
//       Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);
//
//       setState(() {
//         userDropOffAddress = directions.locationName!;
//       });
//
//       Navigator.pushNamed(context, "/mainScreen", arguments: {"dropoffDetails": directions});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
//
//     return ElevatedButton(
//       onPressed: () {
//         getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: darkTheme ? Colors.black : Colors.white,
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             Icon(
//               Icons.add_location,
//               color: darkTheme ? Colors.amber.shade400 : Colors.blue,
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.predictedPlaces!.main_text!,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: darkTheme ? Colors.amber.shade400 : Colors.blue,
//                     ),
//                   ),
//                   Text(
//                     widget.predictedPlaces!.secondary_text!,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: darkTheme ? Colors.amber.shade400 : Colors.blue,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
