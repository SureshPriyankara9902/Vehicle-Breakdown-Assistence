import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
   String? message;
   ProgressDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black54,
      child: Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            SizedBox(width:6,),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),

            SizedBox(width: 26.0,),

            Text(
              message!,
              style:TextStyle(
                color:Colors.white,
                fontSize: 12,

              ),

            )
          ],
        ),
      ),
    );
  }
}


