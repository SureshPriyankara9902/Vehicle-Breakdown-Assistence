// class PredictedPlaces{
//   String? place_id;
//   String? main_text;
//   String? secondary_text;
//
//   PredictedPlaces({this.place_id, this.main_text, this.secondary_text});
//
//   PredictedPlaces.fromJson(Map<String, dynamic> jsonData){
//     place_id = jsonData["place_id"];
//     main_text = jsonData["structured_formatting"]?["main_text"];
//     secondary_text = jsonData["structured_formatting"]?["secondary_text"];
//   }
// }


class PredictedPlaces {
  String? place_id;
  String? main_text;
  String? secondary_text;

  // Constructor
  PredictedPlaces({this.place_id, this.main_text, this.secondary_text});

  // Factory constructor for creating an instance from a JSON object
  PredictedPlaces.fromJson(Map<String, dynamic> jsonData) {
    // Safely handle possible null values in the response
    place_id = jsonData["place_id"];
    main_text = jsonData["structured_formatting"]?["main_text"];
    secondary_text = jsonData["structured_formatting"]?["secondary_text"];
  }

  // Method to convert the object to JSON (if needed for API requests)
  Map<String, dynamic> toJson() {
    return {
      "place_id": place_id,
      "main_text": main_text,
      "secondary_text": secondary_text,
    };
  }
}
