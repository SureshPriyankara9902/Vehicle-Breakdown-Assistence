// // import 'package:flutter/material.dart';
// // import 'package:user/splashScreen/splash_screen.dart';
// //
// // class PayFareAmountDialog extends StatefulWidget {
// //
// //   double? fareAmount;
// //
// //   PayFareAmountDialog({this.fareAmount});
// //
// //   @override
// //   State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
// // }
// //
// // class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
// //   @override
// //   Widget build(BuildContext context) {
// //
// //     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
// //     return Dialog(
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(15),
// //       ),
// //       backgroundColor: Colors.transparent,
// //       child: Container(
// //         margin: EdgeInsets.all(10),
// //         width: double.infinity,
// //         decoration: BoxDecoration(
// //           color: darkTheme ? Colors.black : Colors.white70,
// //           borderRadius:BorderRadius.circular(10),
// //         ),
// //
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //
// //             SizedBox(height: 20,),
// //
// //             Text("Fare Amount".toUpperCase(),
// //             style: TextStyle(
// //               fontWeight: FontWeight.bold,
// //               color: darkTheme? Colors.amber.shade400 : Colors.white,
// //               fontSize: 16,
// //
// //             ),
// //             ),
// //
// //             SizedBox(height: 20,),
// //
// //             Divider(
// //               thickness: 2,
// //               color: darkTheme ? Colors.amber.shade400 : Colors.white,
// //             ),
// //
// //             SizedBox(height: 10,),
// //
// //             Text(
// //               "Rs: "+widget.fareAmount.toString(),
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 color: darkTheme ? Colors.amber.shade400 : Colors.white,
// //                 fontSize: 50,
// //               ),
// //             ),
// //
// //             SizedBox(height: 20,),
// //
// //             Padding(
// //               padding: EdgeInsets.all(10),
// //               child: Text(
// //                 "This is the total fare amount.Please pay it to the helper",
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(
// //                   color: darkTheme ? Colors.amber.shade400 : Colors.white,
// //                 ),
// //               ),
// //             ),
// //
// //             SizedBox(height: 20,),
// //
// //             Padding(
// //               padding: EdgeInsets.all(20),
// //               child: ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white,
// //                 ),
// //
// //                 onPressed: (){
// //                   Future.delayed(Duration(milliseconds: 1000),(){
// //                     Navigator.pop(context, "Cash Paid");
// //                     Navigator.push(context,MaterialPageRoute(builder: (c) => SplashScreen()));
// //                   });
// //                 },
// //                   child: Row(
// //                     children: [
// //                       Text(
// //                         "Pay Cash",
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           color: darkTheme ? Colors.black : Colors.blue,
// //                           fontWeight: FontWeight.bold,
// //
// //                         ),
// //                       ),
// //                       SizedBox(width: 60,),
// //                       Text(
// //                         "Rs: "+widget.fareAmount.toString(),
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 20,
// //                           color: darkTheme ? Colors.black : Colors.blue,
// //
// //                         ),
// //                       )
// //                     ],
// //
// //
// //               )
// //               ),
// //
// //             )
// //
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//  import 'package:flutter/material.dart';
//  import 'package:user/splashScreen/splash_screen.dart';
//
// class PayFareAmountDialog extends StatefulWidget {
//   final double? fareAmount;
//
//   PayFareAmountDialog({this.fareAmount});
//
//   @override
//   State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
// }
//
// class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
//   @override
//   Widget build(BuildContext context) {
//     print("Building PayFareAmountDialog"); // Add logging
//
//     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
//
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       backgroundColor: Colors.transparent,
//       child: Container(
//         margin: EdgeInsets.all(6),
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: darkTheme ? Colors.black : Colors.orange,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(height: 20),
//             Text(
//               "Fare Amount".toUpperCase(),
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: darkTheme ? Colors.amber.shade400 : Colors.white,
//                 fontSize: 25,
//               ),
//             ),
//
//             Divider(
//               thickness: 2,
//               color: darkTheme ? Colors.amber.shade400 : Colors.white,
//             ),
//
//             Text(
//               "Rs: ${widget.fareAmount}",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: darkTheme ? Colors.amber.shade400 : Colors.white,
//                 fontSize: 40,
//               ),
//             ),
//             SizedBox(height: 10),
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: Text(
//                 "This is the total fare amount. Please pay it to the helper.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: darkTheme ? Colors.amber.shade400 : Colors.white,
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white,
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context, "Cash Paid");
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (c) => SplashScreen(),
//                     ),
//                   );
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Pay Cash",
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: darkTheme ? Colors.black : Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       "Rs: ${widget.fareAmount}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                         color: darkTheme ? Colors.black : Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:user/splashScreen/splash_screen.dart';

class PayFareAmountDialog extends StatefulWidget {
  final double? fareAmount;

  PayFareAmountDialog({this.fareAmount});

  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.orange,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text(
              "Fare Amount".toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.white,
                fontSize: 25,
              ),
            ),

            Divider(
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
            ),

            Text(
              "Rs: ${widget.fareAmount?.toStringAsFixed(2)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.white,
                fontSize: 35,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "This is the total fare amount. Please pay it to the helper.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkTheme ? Colors.amber.shade400 : Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context, "Cash Paid");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => SplashScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pay Cash",
                      style: TextStyle(
                        fontSize: 15,
                        color: darkTheme ? Colors.black : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Rs: ${widget.fareAmount?.toStringAsFixed(1)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: darkTheme ? Colors.black : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}