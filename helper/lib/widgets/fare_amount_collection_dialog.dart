import 'package:flutter/material.dart';
import 'package:helper/splashScreen/splash_screen.dart';

class FareAmountCollectionDialog extends StatefulWidget {
 double ? totalFareAmount;

 FareAmountCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.orange,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20,),

            Text(
              //Trip fare amount
              "FARE AMOUNT",
              style: TextStyle(fontWeight: FontWeight.bold,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
                fontSize: 25,
              ),
            ),
            Divider(
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
            ),

            Text(
              "Rs " + widget.totalFareAmount!.toStringAsFixed(2),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.white,
                fontSize: 35,
              ),
            ),
            SizedBox(height: 10,),

            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "This is the total trip amount.Please collect it from the user",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkTheme ? Colors.amber.shade400 : Colors.white,

                ),
              ),
            ),

            SizedBox(height: 10,),

            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white
                ),

                onPressed: (){
                  Future.delayed(Duration(milliseconds: 2000),(){
                    Navigator.push(context,MaterialPageRoute(builder:(c) => SplashScreen()));

                  });
                },

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Collect cash",
                      style: TextStyle(
                        fontSize:15,
                        color: darkTheme ? Colors.black : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),

                    ),

                Text(
                  "Rs " + widget.totalFareAmount!.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.amber.shade400 : Colors.black,
                    fontSize: 15,
                  ),
                ),


                  ],
                ),
              ),
            )

          ],
        ),



      ),
    );
  }
}
