class WeatherModel {
  final String temperature;
  final String weatherDescription;
  final String humidity;
  final String windSpeed;
  final String location;
  final String weatherIcon;

  WeatherModel({
    required this.temperature,
    required this.weatherDescription,
    required this.humidity,
    required this.windSpeed,
    required this.location,
    required this.weatherIcon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['current']['temperature'].toString(),
      weatherDescription: json['current']['weather_descriptions'][0],
      humidity: json['current']['humidity'].toString(),
      windSpeed: json['current']['wind_speed'].toString(),
      location: json['location']['name'],
      weatherIcon: json['current']['weather_icons'][0],
    );
  }
}
