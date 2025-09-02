import 'dart:async';

//import 'package:just_audio/just_audio.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/direction_details_info.dart';
import '../models/helper_data.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionHelperLivePosition;


//AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();



UserModel ? userModelCurrentInfo;

Position? helperCurrentPosition;
HelperData onlineHelperData = HelperData();
String? helperVehicleType ="";
String? titleStarsRating = "";
DirectionDetailsInfo? directionDetailsInfo;