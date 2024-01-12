part of 'search.dart';

class WeatherRepository {
  Future<Weather> fetchWeather(String cityName) async {
    await Future<void>.delayed(k100ms * 10);

    final random = math.Random();

    if (random.nextInt(10) > 5 || cityName.isEmpty) {
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
