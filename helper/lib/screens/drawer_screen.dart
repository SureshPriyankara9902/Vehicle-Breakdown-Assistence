// import 'package:flutter/material.dart';
// import 'package:helper/screens/profile_screen.dart';
// import '../global/global.dart';
// import '../splashScreen/splash_screen.dart';
//
// class DrawerScreen  extends StatelessWidget {
//   const DrawerScreen ({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 220,
//       child: Drawer(
//         child: Padding(
//           padding:EdgeInsets.fromLTRB(30, 50, 0, 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding:EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.person,
//                       color: Colors.white,
//                     ),
//                   ),
//
//                   SizedBox(height: 20,),
//
//                   Text(
//                     userModelCurrentInfo?.name ?? "Guest",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                     ),
//
//                   ),
//
//                   SizedBox(height: 20,),
//
//                   GestureDetector(
//                     onTap: (){
//                       Navigator.push(context, MaterialPageRoute(builder: (c) =>  ProfileScreen()));
//                     },
//                       child:Text(
//                           "Edit profile",
//                           style:TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15,
//                             color:Colors.blue,
//                           ),
//                       ),
//                   ),
//
//                   SizedBox(height: 30,),
//
//                   Text("Your Travels", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
//                   SizedBox(height: 15,),
//
//                   Text("Payments", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
//                   SizedBox(height: 15,),
//
//                   Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
//                   SizedBox(height: 15,),
//
//                   Text("Promos", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
//                   SizedBox(height: 15,),
//
//                   Text("Help", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
//                   SizedBox(height: 15,),
//
//                   Text("Free Travels", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
//                   SizedBox(height: 15,),
//
//                 ],
//
//               ),
//
//               GestureDetector(
//                 onTap: (){
//                   firebaseAuth.signOut();
//                   Navigator.push(context, MaterialPageRoute(builder: (c) =>  SplashScreen()));
//
//                 },
//
//                 child: Text(
//                   "Logout",
//                   style:TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Colors.red,
//                   )
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
