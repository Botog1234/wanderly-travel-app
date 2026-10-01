import 'package:flutter/material.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  static const Color teal = Color(0xFF168B83);

  final TextEditingController _cityController = TextEditingController();
  String _city = 'Bali';
  int _selectedDay = 0;

  final List<_WeatherDay> _forecast = const [
    _WeatherDay(day: 'Today', icon: Icons.wb_sunny_rounded, high: 30, low: 24),
    _WeatherDay(day: 'Tue', icon: Icons.cloud_rounded, high: 29, low: 23),
    _WeatherDay(day: 'Wed', icon: Icons.thunderstorm_rounded, high: 27, low: 22),
    _WeatherDay(day: 'Thu', icon: Icons.wb_cloudy_rounded, high: 28, low: 23),
    _WeatherDay(day: 'Fri', icon: Icons.wb_sunny_rounded, high: 31, low: 24),
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _searchCity() {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _city = city;
      _selectedDay = 0;
    });

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final weather = _forecast[_selectedDay];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F8),
      appBar: AppBar(
        title: const Text(
          'Weather',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF5F8F8),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSearch(),
            const SizedBox(height: 22),
            _buildCurrentWeather(weather),
            const SizedBox(height: 22),
            const Text(
              '5-day forecast',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF17212B),
              ),
            ),
            const SizedBox(height: 12),
            _buildForecast(),
            const SizedBox(height: 22),
            _buildConditions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _cityController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _searchCity(),
            decoration: InputDecoration(
              hintText: 'Search a city',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _searchCity,
          style: IconButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.white,
            minimumSize: const Size(52, 52),
          ),
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }

  Widget _buildCurrentWeather(_WeatherDay weather) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF168B83), Color(0xFF56B9A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                weather.day,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(weather.icon, size: 70, color: Colors.white),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.high}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      height: 1,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Text(
                    'Partly sunny',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Feels pleasant for exploring today.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildForecast() {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _forecast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = _forecast[index];
          final selected = _selectedDay == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? teal : Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: selected ? teal : const Color(0xFFE7ECEC),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day.day,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF68757A),
                      fontSize: 12,
                    ),
                  ),
                  Icon(
                    day.icon,
                    color: selected ? Colors.white : teal,
                  ),
                  Text(
                    '${day.high}° / ${day.low}°',
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF26343E),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConditions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EDF0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conditions',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ConditionItem(
                  icon: Icons.water_drop_outlined,
                  label: 'Humidity',
                  value: '68%',
                ),
              ),
              Expanded(
                child: _ConditionItem(
                  icon: Icons.air_rounded,
                  label: 'Wind',
                  value: '12 km/h',
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ConditionItem(
                  icon: Icons.wb_sunny_outlined,
                  label: 'UV index',
                  value: 'Moderate',
                ),
              ),
              Expanded(
                child: _ConditionItem(
                  icon: Icons.visibility_outlined,
                  label: 'Visibility',
                  value: '10 km',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConditionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConditionItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF168B83)),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF89939A),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeatherDay {
  final String day;
  final IconData icon;
  final int high;
  final int low;

  const _WeatherDay({
    required this.day,
    required this.icon,
    required this.high,
    required this.low,
  });
}