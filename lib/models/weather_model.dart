class Weather{
  final String cityName;
  final double temperature;
  final String mainCondition;

  // ignore: use_function_type_syntax_for_parameters
  Weather({
    required this.cityName,
    required this.mainCondition,
    required this.temperature});


  factory Weather.fromJson(Map<String, dynamic>json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
    );
  }
}