import 'dart:core';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation{
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? rideRequestId;
  String? userName;
  String? userPhone;
  String? vehicleType;
  String? userId;
  int? requestTimestamp;
  String? duration;
  String? distance;

  UserRideRequestInformation({
    this.originLatLng,
    this.destinationLatLng,
    this.originAddress,
    this.destinationAddress,
    this.rideRequestId,
    this.userName,
    this.userPhone,
    this.vehicleType,
    this.userId,
    this.requestTimestamp,
    this.duration,
    this.distance,
  });
}
