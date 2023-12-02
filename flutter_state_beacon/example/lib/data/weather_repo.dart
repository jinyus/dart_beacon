import 'dart:math';

import 'package:example/const.dart';

import 'weather_model.dart';

abstract class WeatherRepository {
  Future<Weather> fetchWeather(String cityName);
}

class FakeWeatherRepository implements WeatherRepository {
  @override
  Future<Weather> fetchWeather(String cityName) async {
    await Future.delayed(k100ms * 10);

    final random = Random();

    if (random.nextInt(10) > 5) {
      throw NetworkException();
    }

    return Weather(
      cityName: cityName,
      // Temperature between 20 and 35.99
      temperatureCelsius: 20 + random.nextInt(15) + random.nextDouble(),
    );
  }
}

class NetworkException implements Exception {}
