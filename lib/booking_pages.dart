import 'package:flutter/material.dart';

import 'models/place.dart';
import 'trip_store.dart';
import 'weather_forecast_card.dart';

class HotelBookingPage extends StatefulWidget {
  final Place place;

  const HotelBookingPage({
    super.key,
    required this.place,
  });

  @override
  State<HotelBookingPage> createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends State<HotelBookingPage> {
  DateTimeRange? _stay;
  int _guests = 1;

  String get _name => widget.place.name;
  String get _address => widget.place.address;
  double? get _latitude => widget.place.latitude;
  double? get _longitude => widget.place.longitude;

  Future<void> _chooseDates() async {
    final today = DateUtils.dateOnly(DateTime.now());

    final range = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 3),
      helpText: 'Choose your stay dates',
    );

    if (range != null && mounted) {
      setState(() => _stay = range);
    }
  }

  void _confirmStay() {
    if (_stay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose check-in and check-out dates')),
      );
      return;
    }

    TripStore.saveHotel(
      name: _name,
      address: _address,
      checkIn: _stay!.start,
      checkOut: _stay!.end,
      guests: _guests,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stay saved to your trip')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Plan your hotel stay'),
        backgroundColor: scheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PlaceSummary(
            name: _name,
            address: _address,
            icon: Icons.hotel_outlined,
          ),
          const SizedBox(height: 24),
          Text(
            'Your stay',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: Icon(Icons.date_range, color: scheme.primary),
            title: Text(
              _stay == null
                  ? 'Choose check-in and check-out'
                  : '${_formatDate(_stay!.start)} – '
                  '${_formatDate(_stay!.end)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _chooseDates,
          ),
          const SizedBox(height: 12),
          _PeoplePicker(
            label: 'Guests',
            count: _guests,
            onChanged: (value) => setState(() => _guests = value),
          ),
          if (_stay != null) ...[
            const SizedBox(height: 16),
            WeatherForecastCard(
              latitude: _latitude,
              longitude: _longitude,
              startDate: _stay!.start,
              endDate: _stay!.end,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Review',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This saves the stay to your trip and calendar. '
                'It does not reserve a room or charge you.',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _confirmStay,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Confirm stay'),
          ),
        ],
      ),
    );
  }
}

class AttractionBookingPage extends StatefulWidget {
  final Place place;

  const AttractionBookingPage({
    super.key,
    required this.place,
  });

  @override
  State<AttractionBookingPage> createState() =>
      _AttractionBookingPageState();
}

class _AttractionBookingPageState extends State<AttractionBookingPage> {
  DateTime? _visitDate;
  int _visitors = 1;

  String get _name => widget.place.name;
  String get _address => widget.place.address;
  double? get _latitude => widget.place.latitude;
  double? get _longitude => widget.place.longitude;

  Future<void> _chooseDate() async {
    final today = DateUtils.dateOnly(DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 3),
      helpText: 'Choose your visit date',
    );

    if (date != null && mounted) {
      setState(() => _visitDate = date);
    }
  }

  void _confirmVisit() {
    if (_visitDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a visit date')),
      );
      return;
    }

    TripStore.saveAttraction(
      name: _name,
      address: _address,
      visitDate: _visitDate!,
      visitors: _visitors,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visit saved to your trip')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Plan your visit'),
        backgroundColor: scheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PlaceSummary(
            name: _name,
            address: _address,
            icon: Icons.attractions_outlined,
          ),
          const SizedBox(height: 24),
          Text(
            'Your visit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: Icon(Icons.calendar_month, color: scheme.primary),
            title: Text(
              _visitDate == null
                  ? 'Choose a visit date'
                  : _formatDate(_visitDate!),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _chooseDate,
          ),
          const SizedBox(height: 12),
          _PeoplePicker(
            label: 'Visitors',
            count: _visitors,
            onChanged: (value) => setState(() => _visitors = value),
          ),
          if (_visitDate != null) ...[
            const SizedBox(height: 16),
            WeatherForecastCard(
              latitude: _latitude,
              longitude: _longitude,
              startDate: _visitDate!,
              endDate: _visitDate!,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'This saves the planned visit to your trip and calendar. '
                'It does not purchase tickets.',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _confirmVisit,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Confirm visit'),
          ),
        ],
      ),
    );
  }
}

class SavedTripsPage extends StatelessWidget {
  const SavedTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trips = TripStore.savedTrips;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Saved trips'),
        backgroundColor: scheme.surface,
      ),
      body: trips.isEmpty
          ? Center(
        child: Text(
          'Your saved stays and visits will appear here.',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final trip = trips[index];
          final isHotel = trip.type == 'Hotel stay';
          final dateText = trip.endDate == null
              ? _formatDate(trip.startDate)
              : '${_formatDate(trip.startDate)} – '
              '${_formatDate(trip.endDate!)}';

          return Card(
            color: scheme.surface,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.secondaryContainer,
                child: Icon(
                  isHotel
                      ? Icons.hotel_outlined
                      : Icons.attractions_outlined,
                  color: scheme.primary,
                ),
              ),
              title: Text(trip.name),
              subtitle: Text(
                '${trip.type} · $dateText\n'
                    '${trip.address}\n'
                    'People: ${trip.people}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

class _PlaceSummary extends StatelessWidget {
  final String name;
  final String address;
  final IconData icon;

  const _PlaceSummary({
    required this.name,
    required this.address,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          child: Icon(icon, color: scheme.primary),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(address),
        ),
      ),
    );
  }
}

class _PeoplePicker extends StatelessWidget {
  final String label;
  final int count;
  final ValueChanged<int> onChanged;

  const _PeoplePicker({
    required this.label,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surface,
      child: ListTile(
        leading: Icon(Icons.people_outline, color: scheme.primary),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Remove one',
              onPressed: count > 1 ? () => onChanged(count - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$count'),
            IconButton(
              tooltip: 'Add one',
              onPressed: count < 12 ? () => onChanged(count + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day}/${date.month}/${date.year}';