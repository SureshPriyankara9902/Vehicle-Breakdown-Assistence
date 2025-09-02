// import 'package:flutter/material.dart';
// import 'package:user/models/trips_history_model.dart';
// import 'package:intl/intl.dart';
//
//
// class HistoryDesignUIWidget extends StatefulWidget {
//
//   TripsHistoryModel? tripsHistoryModel;
//   HistoryDesignUIWidget({this.tripsHistoryModel});
//
//
//   @override
//   State<HistoryDesignUIWidget> createState() => _HistoryDesignUIWidgetState();
// }
//
// class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget> {
//
//   String formatDateAndTime(String dateTimeFromDB){
//     DateTime dateTime = DateTime.parse(dateTimeFromDB);
//
//     //
//     String formattedDateTime = "${DateFormat.MMMd().format(dateTime)},${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
//     return formattedDateTime;
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(formatDateAndTime(widget.tripsHistoryModel!.time!),
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//
//         SizedBox(height: 10,),
//
//         Container(
//           decoration: BoxDecoration(
//             color: darkTheme ? Colors.black : Colors.white,
//             borderRadius: BorderRadius.circular(20),
//
//           ),
//           padding: EdgeInsets.all(15),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.lightBlue,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//
//                         child: Icon(Icons.person, color:Colors.white,),
//                       ),
//
//                       SizedBox(height: 15,),
//
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(widget.tripsHistoryModel!.helperName!,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//
//                             ),
//
//                           ),
//
//                           SizedBox(height: 8,),
//
//                           Row(
//                             children: [
//                               Icon(Icons.star, color:Colors.yellow,),
//                               SizedBox(width: 5,),
//
//                               Text("4.5",
//                               style:TextStyle(
//                                 color: Colors.grey,
//                               ))
//                             ],
//                           )
//                         ],
//                       )
//
//                     ],
//                   ),
//
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Final Cost",
//                         style: TextStyle(
//                           color: Colors.grey,
//                         ),
//                       ),
//
//                       SizedBox(height: 8,),
//
//                       Text(" ${widget.tripsHistoryModel!.fareAmount!}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//
//                       )
//                     ],
//                   ),
//
//
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("status",
//                         style: TextStyle(
//                           color: Colors.grey,
//                         ),
//                       ),
//
//                       SizedBox(height: 8,),
//
//                       Text(" ${widget.tripsHistoryModel!.status!}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//
//                       )
//                     ],
//                   ),
//
//
//                 ],
//               ),
//
//               SizedBox(height: 10,),
//
//               Divider(
//                 thickness: 2,
//                 color: Colors.grey[200],
//               ),
//
//               SizedBox(height: 10,),
//
//               Row(
//                 children: [
//                   Text("Trip",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                   )
//                 ],
//               ),
//
//               SizedBox(height: 10,),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                         child: Icon(Icons.location_on, color: Colors.green,),
//                       ),
//
//                       SizedBox(height: 15,),
//
//                       Text("${(widget.tripsHistoryModel!.originAddress!).substring(0,15)} ...",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//
//               SizedBox(height: 10,),
//
//
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                         child: Icon(Icons.location_on, color: Colors.red,),
//                       ),
//
//                       SizedBox(height: 15,),
//
//                       Text("${widget.tripsHistoryModel!.destinationAddress!}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//
//
//
//             ],
//           ),
//         )
//
//       ],
//
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trips_history_model.dart';

class HistoryDesignUIWidget extends StatefulWidget {
  final TripsHistoryModel? tripsHistoryModel;
  HistoryDesignUIWidget({this.tripsHistoryModel});


  @override
  State<HistoryDesignUIWidget> createState() => _HistoryDesignUIWidgetState();
}

class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget> {
  String formatDateAndTime(String dateTimeFromDB) {
    DateTime dateTime = DateTime.parse(dateTimeFromDB);
    String formattedDateTime =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDateAndTime(widget.tripsHistoryModel!.time!),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkTheme ? Colors.white : Colors.black,
          ),
        ),

        SizedBox(height: 5),

        Container(
          decoration: BoxDecoration(
            color: darkTheme ? Colors.grey[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // User Info and Final Cost
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User Info
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tripsHistoryModel!.helperName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: darkTheme ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          // Rating (if needed)
                          // Row(
                          //   children: [
                          //     Icon(Icons.star, color: Colors.yellow, size: 16),
                          //     SizedBox(width: 5),
                          //     Text(
                          //       "4.5",
                          //       style: TextStyle(
                          //         color: Colors.grey,
                          //         fontSize: 14,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  ),

                  // Final Cost
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Final Cost",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "LKR ${widget.tripsHistoryModel!.fareAmount!}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: darkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 5),

              // Divider
              Divider(
                thickness: 1,
                color: Colors.grey[300],
              ),

              SizedBox(height: 15),

              // Trip Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Trip",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: darkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),

                  // Origin Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.tripsHistoryModel!.originAddress!,
                          style: TextStyle(
                            fontSize: 14,
                            color: darkTheme ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5),

                  // Destination Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.tripsHistoryModel!.destinationAddress!,
                          style: TextStyle(
                            fontSize: 14,
                            color: darkTheme ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 5),

              // Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.tripsHistoryModel!.status == "ended"
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.tripsHistoryModel!.status!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.tripsHistoryModel!.status == "ended"
                            ? Colors.green[800]
                            : Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}



