// ignore_for_file: camel_case_types, avoid_print

import 'package:flutter/material.dart';
import 'package:modernlogintute/models/weather_model.dart';
import 'package:modernlogintute/services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _weatherService = WeatherService('e5fefa5b0dd84e0efe91507bc6d11828');
  Weather? _weather;
  String? _backgroundImagePath;
  String? _weatherEmoji;

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
        _setBackgroundAndEmoji(weather.weatherCondition);
      });
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  void _setBackgroundAndEmoji(String weatherCondition) {
    switch (weatherCondition) {
      case 'Sunny':
        _backgroundImagePath = 'lib/images/sunny.jpg';
        _weatherEmoji = '☀️';
        break;
      case 'Cloudy':
        _backgroundImagePath = 'lib/images/cloudy.jpg';
        _weatherEmoji = '☁️';
        break;
      case 'Rainy':
        _backgroundImagePath = 'lib/images/rainy.jpg';
        _weatherEmoji = '🌧️';
        break;
    // Add more cases for different weather conditions
      default:
        _backgroundImagePath = 'lib/images/default.jpg';
        _weatherEmoji = '🌦️';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _weather == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Image.asset(
            _backgroundImagePath!,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weather!.cityName,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text(
                        '${_weather!.temperature.round()}°C',
                        style: const TextStyle(
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        _weatherEmoji!,
                        style: const TextStyle(fontSize: 48.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(_weather!.weatherCondition),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 100.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _weather!.hourlyForecast.length,
                      itemBuilder: (context, index) {
                        final forecast =
                        _weather!.hourlyForecast[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: [
                              Text(
                                '${forecast.time.hour}:00',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text('${forecast.temperature.round()}°C'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Weekly Forecast',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 100.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _weather!.dailyForecast.length,
                      itemBuilder: (context, index) {
                        final forecast = _weather!.dailyForecast[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: [
                              Text(
                                forecast.day,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                  '${forecast.temperature.round()}°C'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}