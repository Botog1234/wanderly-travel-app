import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_pages.dart';
import 'models/place.dart';
import 'models/places_snapshot.dart';
import 'providers/destination_providers.dart';
import 'world_Search.dart';

class DestinationResultsPage extends ConsumerStatefulWidget {
  final CountryInfo country;

  const DestinationResultsPage({
    super.key,
    required this.country,
  });

  @override
  ConsumerState<DestinationResultsPage> createState() =>
      _DestinationResultsPageState();
}

class _DestinationResultsPageState
    extends ConsumerState<DestinationResultsPage> {
  static const Color _teal = Color(0xFF168B83);

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  Timer? _searchDebounce;

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _searchQuery = value.trim().toLowerCase());
    });
  }

  List<Place> _filterPlaces(List<Place> places) {
    return places.where((place) {
      final matchesCategory = switch (_selectedCategory) {
        'Hotels' => place.isHotel,
        'Attractions' =>
        !place.isHotel &&
            place.categories.any(
                  (category) => category.startsWith('tourism'),
            ),
        _ => true,
      };

      final matchesSearch = _searchQuery.isEmpty ||
          place.name.toLowerCase().contains(_searchQuery) ||
          place.address.toLowerCase().contains(_searchQuery) ||
          place.categories.any(
                (category) => category.toLowerCase().contains(_searchQuery),
          );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _retry() {
    ref.invalidate(destinationPlacesProvider(widget.country.name));
  }

  void _openPlace(Place place) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => place.isHotel
            ? HotelBookingPage(place: place)
            : AttractionBookingPage(place: place),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync =
    ref.watch(destinationPlacesProvider(widget.country.name));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.country.name),
        actions: [
          IconButton(
            tooltip: 'Refresh places',
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search places',
                prefixIcon: const Icon(Icons.search, color: _teal),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.close),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Wrap(
              spacing: 8,
              children: ['All', 'Attractions', 'Hotels'].map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: placesAsync.when(
              loading: _buildLoadingSkeleton,
              error: (error, stackTrace) => _buildError(error),
              data: (snapshot) {
                final visiblePlaces = _filterPlaces(snapshot.places);

                return Column(
                  children: [
                    if (snapshot.isFromCache)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Offline · Last updated '
                                '${_formatDateTime(snapshot.lastUpdated)}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: visiblePlaces.isEmpty
                          ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No places found in this category.'
                              : 'No places match '
                              '“${_searchController.text}”.',
                          textAlign: TextAlign.center,
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: visiblePlaces.length,
                        itemBuilder: (context, index) {
                          final place = visiblePlaces[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                const Color(0xFFDDF3EF),
                                child: Icon(
                                  place.isHotel
                                      ? Icons.hotel_outlined
                                      : Icons.attractions_outlined,
                                  color: _teal,
                                ),
                              ),
                              title: Text(place.name),
                              subtitle: Text(
                                '${place.address}\n'
                                    '${place.isHotel ? 'Hotel · Plan a stay' : 'Attraction · Plan a visit'}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                              ),
                              onTap: () => _openPlace(place),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8ECEF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 170,
                        color: const Color(0xFFE8ECEF),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 230,
                        color: const Color(0xFFE8ECEF),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 44,
              color: _teal,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load places.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}