class Weather {
  final String cityName;
  final double temperature;
  final String weatherCondition;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.weatherCondition,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['current']['temp'],
      weatherCondition: json['current']['weather'][0]['main'],
      hourlyForecast: List<HourlyForecast>.from(
        json['hourly'].map(
              (hourlyJson) => HourlyForecast.fromJson(hourlyJson),
        ),
      ),
      dailyForecast: List<DailyForecast>.from(
        json['daily'].map(
              (dailyJson) => DailyForecast.fromJson(dailyJson),
        ),
      ),
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;

  HourlyForecast({
    required this.time,
    required this.temperature,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['temp'],
    );
  }
}

class DailyForecast {
  final String day;
  final double temperature;

  DailyForecast({
    required this.day,
    required this.temperature,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      day: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000)
          .toString()
          .split(' ')[0],
      temperature: json['temp']['day'],
    );
  }
}