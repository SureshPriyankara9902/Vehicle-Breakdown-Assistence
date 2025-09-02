import 'package:flutter/material.dart';
import 'package:user/Assistants/request_assistant.dart';
import 'package:user/global/map_key.dart';
import 'package:user/widgets/place_prediction_tile.dart';
import '../models/predicted_places.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];
  TextEditingController searchController = TextEditingController();

  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.gomaps.pro/maps/api/place/queryautocomplete/json?input=$inputText&key=$mapKey&components=country:LK";
      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch == "Error Occurred. Failed. No Response.") {
        return;
      }

      if (responseAutoCompleteSearch != null && responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        if (placePredictions != null && placePredictions is List) {
          var placePredictionList = placePredictions
              .map((jsonData) => PredictedPlaces.fromJson(jsonData))
              .toList();

          setState(() {
            placesPredictedList = placePredictionList;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blueGrey[900],
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context, "obtainedDropoff");
            },
            child: Icon(
              Icons.arrow_back,
              color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          title: Text(
            "Search & Set Dropoff location",
            style: TextStyle(color: darkTheme ? Colors.black : Colors.white),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: darkTheme ? Colors.amber.shade400 : Colors.blueGrey[900],
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: darkTheme ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(
                                      Icons.search,
                                      color: darkTheme ? Colors.white54 : Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      onChanged: (value) {
                                        findPlaceAutoCompleteSearch(value);
                                      },
                                      style: TextStyle(
                                        color: darkTheme ? Colors.white : Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Search location here...",
                                        hintStyle: TextStyle(
                                          color: darkTheme ? Colors.white54 : Colors.grey,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                  if (searchController.text.isNotEmpty)
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: darkTheme ? Colors.white54 : Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (searchController != null) {
                                            searchController.clear();
                                          }
                                          placesPredictedList.clear();
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Display place predictions result
            (placesPredictedList.isNotEmpty)
                ? Expanded(
              child: ListView.separated(
                itemCount: placesPredictedList.length,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return PlacePredictionTileDesign(
                    predictedPlaces: placesPredictedList[index],
                  );
                                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 4,
                    color: darkTheme ? Colors.amber.shade400 : Colors.transparent,
                    thickness: 1,
                  );
                },
              ),
            )
                : Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 150),
              child: Text(
                "No places found",
                style: TextStyle(
                  color: darkTheme ? Colors.white54 : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}