// import 'package:flutter/cupertino.dart';
// import '../models/directions.dart';
// import '../models/trips_history_model.dart';
//
// class AppInfo extends ChangeNotifier{
//   Directions? userPickUpLocation, userDropOffLocation;
//   int countTotalTrips = 0;
//   String helperTotalEarnings = "0";
//   String helperAverageRatings = "0";
//   List<String> historyTripsKeysList = [];
//   List<TripsHistoryModel> allTripsHistoryInformationList = [];
//
//   void updatePickUpLocationAddress(Directions userPickUpAddress){
//     userPickUpLocation = userPickUpAddress;
//     notifyListeners();
//   }
//
//   void updateDropOffLocationAddress(Directions dropOffAddress){
//     userDropOffLocation = dropOffAddress;
//     notifyListeners();
//   }
//
//   updateOverAllTripsCounter(int overAllTripsCounter){
//     countTotalTrips = overAllTripsCounter;
//     notifyListeners();
//   }
//
//   updateOverAllTripsKeys(List<String> tripsKeysList){
//     historyTripsKeysList = tripsKeysList;
//     notifyListeners();
//   }
//
//   updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory){
//     allTripsHistoryInformationList.add(eachTripHistory);
//     notifyListeners();
//   }
//
//   updateHelperTotalEarnings(String helperEarnings){
//     helperTotalEarnings = helperEarnings;
//
//   }
//   updateHelperAverageRatings(String helperRatings){
//     helperAverageRatings = helperRatings;
//   }
//
//
//
// }


import 'package:flutter/cupertino.dart';
import '../models/directions.dart';
import '../models/trips_history_model.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  String helperTotalEarnings = "0";
  String helperAverageRatings = "0";
  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];

  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  void updateOverAllTripsCounter(int overAllTripsCounter) {
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  void updateOverAllTripsKeys(List<String> tripsKeysList) {
    historyTripsKeysList = tripsKeysList;
    notifyListeners();
  }

  // Add a single trip history item to the list
  void updateOverAllTripsHistoryInformation(TripsHistoryModel trip) {
    allTripsHistoryInformationList.add(trip);
    notifyListeners();
  }

  // Update the entire trips history list at once
  void updateAllTripsHistoryInformation(List<TripsHistoryModel> tripsHistoryList) {
    allTripsHistoryInformationList = tripsHistoryList;
    notifyListeners();
  }

  // Method to clear the trip history list
  void clearTripHistory() {
    allTripsHistoryInformationList.clear();
    notifyListeners();
  }

  void updateHelperTotalEarnings(String helperEarnings) {
    helperTotalEarnings = helperEarnings;
    notifyListeners(); // Add notifyListeners() here
  }




  void updateHelperAverageRatings(String helperRatings) {
    helperAverageRatings = helperRatings;
    notifyListeners(); // Add notifyListeners() here
  }
}