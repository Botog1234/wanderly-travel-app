import 'package:flutter/material.dart';

import 'calendar.dart';
import 'destination_results_page.dart';
import 'saves_pages.dart';
import 'trip_store.dart';
import 'weather.dart';
import 'world_Search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedCountry;

  double get _textScale => MediaQuery.textScalerOf(context).scale(1.0);

  Future<void> _openWorldSearch() async {
    final country = await Navigator.push<CountryInfo>(
      context,
      MaterialPageRoute<CountryInfo>(
        builder: (_) => const CountrySearchPage(),
      ),
    );

    if (!mounted || country == null) return;

    setState(() => _selectedCountry = country.name);

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DestinationResultsPage(country: country),
      ),
    );
  }

  Future<void> _openCalendar() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const CalendarPage(),
      ),
    );
  }

  Future<void> _openSavedTrips() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const SavedPage(),
      ),
    );
  }

  void _openTripUpdates() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const TripUpdatesPage(),
      ),
    );
  }

  void _openFlightsPage() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FlightsComingSoonPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              sliver: SliverToBoxAdapter(child: _buildGreeting()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(child: _buildSearchBar()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(child: _buildExploreCard()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              sliver: SliverToBoxAdapter(child: _buildWeatherTile()),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final scheme = Theme.of(context).colorScheme;
    final compact =
        MediaQuery.sizeOf(context).width < 360 || _textScale > 1.3;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.explore_rounded,
            color: scheme.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wanderly',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              if (!compact)
                Text(
                  'Explore the world',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Search countries',
          onPressed: _openWorldSearch,
          constraints: const BoxConstraints.tightFor(width: 42, height: 42),
          style: IconButton.styleFrom(
            backgroundColor: scheme.surface,
            foregroundColor: scheme.primary,
          ),
          icon: const Icon(Icons.public_rounded),
        ),
        if (!compact) ...[
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Trip reminders',
            onPressed: _openTripUpdates,
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
            style: IconButton.styleFrom(
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurface,
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ],
    );
  }

  Widget _buildGreeting() {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, traveler 👋',
          style: TextStyle(
            fontSize: 14,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Where do you want to go?',
          style: TextStyle(
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        if (_selectedCountry != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: scheme.primary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Selected country: $_selectedCountry',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: scheme.primary, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              readOnly: true,
              onTap: _openWorldSearch,
              decoration: InputDecoration(
                hintText: 'Search destinations',
                hintStyle: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Choose a country',
            onPressed: _openWorldSearch,
            icon: Icon(Icons.tune_rounded, color: scheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCard() {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: scheme.secondaryContainer,
                  child: Icon(
                    Icons.public_rounded,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCountry == null
                            ? 'Start exploring'
                            : 'Explore $_selectedCountry',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose a country to find live attractions and '
                            'places to stay.',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openWorldSearch,
                icon: const Icon(Icons.travel_explore_rounded),
                label: const Text('Explore destinations'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherTile() {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surface,
      child: ListTile(
        leading: Icon(
          Icons.wb_sunny_outlined,
          color: scheme.primary,
        ),
        title: const Text('Weather'),
        subtitle: const Text('Check the forecast for a destination'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const WeatherPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final scheme = Theme.of(context).colorScheme;

    const items = [
      Icons.home_rounded,
      Icons.calendar_month_outlined,
      Icons.favorite_border_rounded,
      Icons.flight_takeoff_rounded,
    ];

    const labels = ['Home', 'Calendar', 'Saved', 'Flights'];

    return NavigationBar(
      selectedIndex: 0,
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            _openCalendar();
            break;
          case 2:
            _openSavedTrips();
            break;
          case 3:
            _openFlightsPage();
            break;
        }
      },
      destinations: List.generate(
        items.length,
            (index) => NavigationDestination(
          icon: Icon(items[index]),
          label: labels[index],
        ),
      ),
    );
  }
}

class FlightsComingSoonPage extends StatelessWidget {
  const FlightsComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Flights')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 36),
                Center(
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Icon(
                      Icons.flight_takeoff_rounded,
                      size: 64,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'COMING SOON',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Your next journey is taking off soon.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We’re working on flight planning. For now, you can '
                      'explore destinations and plan places to visit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.explore_rounded),
                  label: const Text('Back to Wanderly'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TripUpdatesPage extends StatelessWidget {
  const TripUpdatesPage({super.key});

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _countdownText(SavedTrip trip, DateTime today) {
    final startDate = DateUtils.dateOnly(trip.startDate);
    final lastDate = DateUtils.dateOnly(trip.endDate ?? trip.startDate);

    if (startDate.isBefore(today) && !lastDate.isBefore(today)) {
      return 'In progress';
    }

    final daysUntil = startDate.difference(today).inDays;

    if (daysUntil == 0) return 'Starts today';
    if (daysUntil == 1) return 'Starts tomorrow';
    return 'Starts in $daysUntil days';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateUtils.dateOnly(DateTime.now());
    final thirtyDaysFromNow = today.add(const Duration(days: 30));

    final activeOrUpcoming = TripStore.savedTrips.where((trip) {
      final lastDate = DateUtils.dateOnly(trip.endDate ?? trip.startDate);
      return !lastDate.isBefore(today);
    }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final nextTrip = activeOrUpcoming.isEmpty ? null : activeOrUpcoming.first;

    final otherNearTermTrips = activeOrUpcoming.where((trip) {
      final startDate = DateUtils.dateOnly(trip.startDate);

      return trip.id != nextTrip?.id &&
          !startDate.isBefore(today) &&
          !startDate.isAfter(thirtyDaysFromNow);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Trip reminders')),
      body: activeOrUpcoming.isEmpty
          ? _buildEmptyState(context, scheme)
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your next plan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildNextTripCard(context, scheme, nextTrip!, today),
          const SizedBox(height: 28),
          Text(
            'Other plans · next 30 days',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (otherNearTermTrips.isEmpty)
            Card(
              color: scheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No other plans are coming up in the next 30 days.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            )
          else
            ...otherNearTermTrips.map(
                  (trip) => _buildTripTile(context, scheme, trip),
            ),
          const SizedBox(height: 12),
          Text(
            'These reminders appear in the app. They don’t send '
                'phone notifications.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextTripCard(
      BuildContext context,
      ColorScheme scheme,
      SavedTrip trip,
      DateTime today,
      ) {
    final dateText = trip.endDate == null
        ? _formatDate(trip.startDate)
        : '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate!)}';

    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  trip.type == 'Hotel stay'
                      ? Icons.hotel_outlined
                      : Icons.attractions_outlined,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _countdownText(trip, today),
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              trip.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${trip.type} · $dateText',
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
            const SizedBox(height: 4),
            Text(
              trip.address,
              style: TextStyle(
                color: scheme.onSecondaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTile(
      BuildContext context,
      ColorScheme scheme,
      SavedTrip trip,
      ) {
    final dateText = trip.endDate == null
        ? _formatDate(trip.startDate)
        : '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate!)}';

    return Card(
      color: scheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          trip.type == 'Hotel stay'
              ? Icons.hotel_outlined
              : Icons.attractions_outlined,
          color: scheme.primary,
        ),
        title: Text(trip.name),
        subtitle: Text('${trip.type} · $dateText'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: scheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No upcoming plans',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Save a stay or visit and your next plan will appear here.',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}