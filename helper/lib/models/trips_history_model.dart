// import 'package:firebase_database/firebase_database.dart';
//
// class TripsHistoryModel{
//   String? time;
//   String? originAddress;
//   String? destinationAddress;
//   String? status;
//   String? fareAmount;
//   String? userName;
//   String? userPhone;
//
//   TripsHistoryModel({
//     this.time,
//     this.originAddress,
//     this.destinationAddress,
//     this.status,
//     this.fareAmount,
//     this.userName,
//     this.userPhone,
// });
//
//
//   TripsHistoryModel.fromSnapshot(DataSnapshot dataSnapshot){
//     time = (dataSnapshot.value as Map)["time"];
//     originAddress =(dataSnapshot.value as Map)["originAddress"];
//     destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
//     status = (dataSnapshot.value as Map)["status"];
//     fareAmount = (dataSnapshot.value as Map)["fareAmount"];
//     userName = (dataSnapshot.value as Map)["userName"];
//     userPhone = (dataSnapshot.value as Map)["userPhone"];
//   }
//
// }
//
//
//
// class TripsHistoryModel {
//   String? time;
//   String? originAddress;
//   String? destinationAddress;
//   String? status;
//   String? fareAmount;
//   String? userName;
//   String? userPhone;
//
//   TripsHistoryModel({
//     this.time,
//     this.originAddress,
//     this.destinationAddress,
//     this.status,
//     this.fareAmount,
//     this.userName,
//     this.userPhone,
//   });
//
//   // Factory constructor to create TripsHistoryModel from a Map
//   factory TripsHistoryModel.fromMap(Map<dynamic, dynamic> map) {
//     return TripsHistoryModel(
//       time: map["time"],
//       originAddress: map["originAddress"],
//       destinationAddress: map["destinationAddress"],
//       status: map["status"],
//       fareAmount: map["fareAmount"],
//       userName: map["userName"],
//       userPhone: map["userPhone"],
//     );
//   }
//
//   // Override == operator to compare trips
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is TripsHistoryModel &&
//         other.time == time &&
//         other.originAddress == originAddress &&
//         other.destinationAddress == destinationAddress &&
//         other.status == status &&
//         other.fareAmount == fareAmount &&
//         other.userName == userName &&
//         other.userPhone == userPhone;
//   }
//
//   // Override hashCode to generate a unique hash code
//   @override
//   int get hashCode {
//     return time.hashCode ^
//     originAddress.hashCode ^
//     destinationAddress.hashCode ^
//     status.hashCode ^
//     fareAmount.hashCode ^
//     userName.hashCode ^
//     userPhone.hashCode;
//   }

import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel {
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? userName;
  String? userPhone;
  double? ratings;  // Add rating field as a double

  TripsHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.userName,
    this.userPhone,
    this.ratings,  // Include rating in the constructor
  });

  // Factory constructor to create TripsHistoryModel from a Map
  factory TripsHistoryModel.fromMap(Map<dynamic, dynamic> map) {
    return TripsHistoryModel(
      time: map["time"],
      originAddress: map["originAddress"],
      destinationAddress: map["destinationAddress"],
      status: map["status"],
      fareAmount: map["fareAmount"],
      userName: map["userName"],
      userPhone: map["userPhone"],
      ratings: map["ratings"] != null ? map["ratings"].toDouble() : null,  // Parse rating if available
    );
  }

  // Convert TripsHistoryModel to Map (for saving back to Firebase)
  Map<String, dynamic> toMap() {
    return {
      "time": time,
      "originAddress": originAddress,
      "destinationAddress": destinationAddress,
      "status": status,
      "fareAmount": fareAmount,
      "userName": userName,
      "userPhone": userPhone,
      "ratings": ratings,  // Add rating to the map
    };
  }

  // Override == operator to compare trips
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TripsHistoryModel &&
        other.time == time &&
        other.originAddress == originAddress &&
        other.destinationAddress == destinationAddress &&
        other.status == status &&
        other.fareAmount == fareAmount &&
        other.userName == userName &&
        other.userPhone == userPhone &&
        other.ratings == ratings;  // Compare rating as well
  }

  // Override hashCode to generate a unique hash code
  @override
  int get hashCode {
    return time.hashCode ^
    originAddress.hashCode ^
    destinationAddress.hashCode ^
    status.hashCode ^
    fareAmount.hashCode ^
    userName.hashCode ^
    userPhone.hashCode ^
    ratings.hashCode;  // Include rating in hash code calculation
  }
}
