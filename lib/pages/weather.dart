// ignore_for_file: camel_case_types, avoid_print

import 'package:flutter/material.dart';
import 'package:modernlogintute/models/weather_model.dart';
import 'package:modernlogintute/services/weather_service.dart';
class weather extends StatefulWidget {
  const weather({super.key});

  @override
  State<weather> createState() => _weatherState();
}

class _weatherState extends State<weather> {
  //api key

  final _weatherService=  WeatherService('e5fefa5b0dd84e0efe91507bc6d11828');
  Weather? _weather;

  //fetch weather
  _fetchWeather() async{
    //get the current city
    String cityName = await _weatherService.getCurrentCity();

    //get weather city
    try{
      final weather = await _weatherService.getWeather(cityName);
      setState((){
        _weather = weather;
      });
    }
    //any error
    catch (e) {
      print('Error fetching weather: $e');
    }
  }
  //weather animations

  //init state
  @override
  void initState(){
    super.initState();
    //fetch weather on startup
    _fetchWeather();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //city name
              Text(_weather?.cityName ?? "Loading city..."),
              //Tempreture
              Text('${_weather?.temperature.round()}°C'),
            ]),
      ),
    );
  }
}