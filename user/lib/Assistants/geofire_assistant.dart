import '../models/active_nearby_available_helpers.dart';

class GeoFireAssistant{
  static List <ActiveNearByAvailableHelpers> activeNearByAvailableHelpersList = [];

  static void deleteOfflineHelperFromList(String helperId){
    int indexNumber = activeNearByAvailableHelpersList.indexWhere((element) => element.helperId == helperId);
    activeNearByAvailableHelpersList.removeAt(indexNumber);
  }

  static void updateActiveNearByAvailableHelperLocation(ActiveNearByAvailableHelpers helperWhoMove){
    int indexNumber = activeNearByAvailableHelpersList.indexWhere((element) => element.helperId == helperWhoMove.helperId);

    activeNearByAvailableHelpersList[indexNumber].locationLatitude = helperWhoMove.locationLatitude;
    activeNearByAvailableHelpersList[indexNumber].locationLongitude = helperWhoMove.locationLongitude;

  }
}