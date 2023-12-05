class Weather {
  final String cityName;
  final double temperatureCelsius;

  Weather({
    required this.cityName,
    required this.temperatureCelsius,
  });

  @override
  String toString() =>
      'The temperature in $cityName is ${temperatureCelsius.toStringAsFixed(2)}°C.';
}
