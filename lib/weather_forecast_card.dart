import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherForecastCard extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final DateTime startDate;
  final DateTime endDate;

  const WeatherForecastCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<WeatherForecastCard> createState() => _WeatherForecastCardState();
}

class _WeatherForecastCardState extends State<WeatherForecastCard> {
  late Future<List<_ForecastDay>> _forecastFuture;

  @override
  void initState() {
    super.initState();
    _forecastFuture = _loadForecast();
  }

  @override
  void didUpdateWidget(covariant WeatherForecastCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _forecastFuture = _loadForecast();
    }
  }

  Future<List<_ForecastDay>> _loadForecast() async {
    final latitude = widget.latitude;
    final longitude = widget.longitude;

    if (latitude == null || longitude == null) {
      throw Exception('This place does not have coordinates.');
    }

    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'daily':
        'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'forecast_days': '16',
        'temperature_unit': 'celsius',
        'timezone': 'auto',
      },
    );

    late final http.Response response;

    try {
      response = await http.get(uri).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw Exception('The weather forecast took too long to load.');
    } on SocketException {
      throw Exception('No internet connection is available for the forecast.');
    } on http.ClientException {
      throw Exception('Could not connect to the weather service.');
    }

    if (response.statusCode != 200) {
      throw Exception('Weather service returned ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Weather service returned invalid data.');
    }

    final daily = decoded['daily'];
    if (daily is! Map<String, dynamic>) {
      throw const FormatException('Weather forecast data is missing.');
    }

    final times = daily['time'];
    if (times is! List) {
      throw const FormatException('Weather forecast dates are missing.');
    }

    final codes = daily['weather_code'] as List? ?? [];
    final highs = daily['temperature_2m_max'] as List? ?? [];
    final lows = daily['temperature_2m_min'] as List? ?? [];
    final rainChances =
        daily['precipitation_probability_max'] as List? ?? [];

    double? numberAt(List values, int index) {
      if (index >= values.length) return null;
      final value = values[index];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    final start = _dateOnly(widget.startDate);
    final end = _dateOnly(widget.endDate);
    final days = <_ForecastDay>[];

    for (var i = 0; i < times.length; i++) {
      final date = DateTime.tryParse(times[i].toString());
      if (date == null) continue;

      final day = _dateOnly(date);
      if (day.isBefore(start) || day.isAfter(end)) continue;

      final codeValue = i < codes.length ? codes[i] : null;
      final code = codeValue is num
          ? codeValue.toInt()
          : int.tryParse(codeValue?.toString() ?? '');

      days.add(
        _ForecastDay(
          date: date,
          weatherCode: code,
          high: numberAt(highs, i),
          low: numberAt(lows, i),
          rainChance: numberAt(rainChances, i),
        ),
      );
    }

    return days;
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _weatherDescription(int? code) {
    if (code == null) return 'Conditions unavailable';
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly cloudy';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code == 85 || code == 86) return 'Snow showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Weather forecast';
  }

  int _outdoorScore(_ForecastDay day) {
    var score = 100 - (day.rainChance ?? 50).round();

    if (day.weatherCode != null && day.weatherCode! >= 95) {
      score -= 40;
    } else if (day.weatherCode != null &&
        day.weatherCode! >= 51 &&
        day.weatherCode! <= 82) {
      score -= 15;
    }

    if (day.high != null && (day.high! < 12 || day.high! > 32)) {
      score -= 10;
    }

    if (day.low != null && day.low! < 5) {
      score -= 5;
    }

    return score;
  }

  _ForecastDay _bestDay(List<_ForecastDay> days) {
    var best = days.first;

    for (final day in days.skip(1)) {
      if (_outdoorScore(day) > _outdoorScore(best)) {
        best = day;
      }
    }

    return best;
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}';

  String _formatTemperature(double? temperature) {
    if (temperature == null) return '--';
    return temperature == temperature.roundToDouble()
        ? temperature.toStringAsFixed(0)
        : temperature.toStringAsFixed(1);
  }

  Widget _buildInsight(BuildContext context, _ForecastDay day) {
    final scheme = Theme.of(context).colorScheme;
    final rain = day.rainChance?.round();
    final hasStormRisk = day.weatherCode != null && day.weatherCode! >= 95;
    final highRainChance = rain != null && rain >= 70;

    final heading = hasStormRisk
        ? 'Consider an indoor plan on ${_formatDate(day.date)}'
        : highRainChance
        ? 'No low-rain day in this forecast'
        : 'Best outdoor day: ${_formatDate(day.date)}';

    final details = <String>[
      if (rain != null) '$rain% rain chance',
      if (day.high != null) 'high ${_formatTemperature(day.high)}°C',
      _weatherDescription(day.weatherCode).toLowerCase(),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: TextStyle(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on the forecast: ${details.join(' · ')}.',
                  style: TextStyle(
                    color: scheme.onSecondaryContainer,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(_ForecastDay day) {
    final scheme = Theme.of(context).colorScheme;
    final rainText = day.rainChance == null
        ? ''
        : ' · Rain ${day.rainChance!.round()}%';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.wb_sunny_outlined,
        color: scheme.primary,
      ),
      title: Text(
        '${_formatDate(day.date)} · ${_weatherDescription(day.weatherCode)}',
      ),
      subtitle: Text(
        'High ${_formatTemperature(day.high)}°C · '
            'Low ${_formatTemperature(day.low)}°C$rainText',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<_ForecastDay>>(
          future: _forecastFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading forecast…',
                    style: TextStyle(color: scheme.onSurface),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Forecast unavailable: ${snapshot.error}',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              );
            }

            final days = snapshot.data ?? [];

            if (days.isEmpty) {
              return Text(
                'A day-specific forecast is not available yet. '
                    'Forecasts cover up to 16 days ahead.',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              );
            }

            final bestDay = _bestDay(days);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather for your trip',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInsight(context, bestDay),
                const SizedBox(height: 8),
                ...days.map(_buildDayRow),
                Text(
                  'Insight compares rain chance, temperature, and conditions. '
                      'Weather data: Open-Meteo.',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ForecastDay {
  final DateTime date;
  final int? weatherCode;
  final double? high;
  final double? low;
  final double? rainChance;

  const _ForecastDay({
    required this.date,
    required this.weatherCode,
    required this.high,
    required this.low,
    required this.rainChance,
  });
}