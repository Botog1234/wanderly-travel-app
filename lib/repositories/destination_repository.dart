import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/geoapify_data_source.dart';
import '../models/place.dart';
import '../models/places_snapshot.dart';

class DestinationRepository {
  DestinationRepository(this._dataSource);

  final GeoapifyDataSource _dataSource;

  String _cacheKey(String countryName) =>
      'geoapify_places_${Uri.encodeComponent(countryName.toLowerCase())}';

  Future<PlacesSnapshot> getPlacesForCountry(String countryName) async {
    try {
      final places = await _dataSource.fetchPlacesForCountry(countryName);
      final fetchedAt = DateTime.now().toUtc();

      // Saving the cache must not make a successful API request fail.
      await _saveCache(countryName, places, fetchedAt);

      return PlacesSnapshot(
        places: places,
        lastUpdated: fetchedAt,
        isFromCache: false,
      );
    } catch (_) {
      final cached = await _readCache(countryName);
      if (cached != null) return cached;

      rethrow;
    }
  }

  Future<void> _saveCache(
      String countryName,
      List<Place> places,
      DateTime fetchedAt,
      ) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final cache = {
        'lastUpdated': fetchedAt.toIso8601String(),
        'places': places.map((place) => place.toCacheJson()).toList(),
      };

      await preferences.setString(_cacheKey(countryName), jsonEncode(cache));
    } catch (_) {
      // Keep showing live results if writing the cache fails.
    }
  }

  Future<PlacesSnapshot?> _readCache(String countryName) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final cachedJson = preferences.getString(_cacheKey(countryName));
      if (cachedJson == null) return null;

      final decoded = jsonDecode(cachedJson);
      if (decoded is! Map<String, dynamic>) return null;

      final dateText = decoded['lastUpdated']?.toString();
      final lastUpdated =
      dateText == null ? null : DateTime.tryParse(dateText);
      final rawPlaces = decoded['places'];

      if (lastUpdated == null || rawPlaces is! List) return null;

      final places = <Place>[];
      for (final item in rawPlaces) {
        if (item is Map<String, dynamic>) {
          places.add(Place.fromCacheJson(item));
        }
      }

      return PlacesSnapshot(
        places: places,
        lastUpdated: lastUpdated,
        isFromCache: true,
      );
    } catch (_) {
      // Ignore a missing or unreadable cache; the original API error is shown.
      return null;
    }
  }

  void close() {
    _dataSource.close();
  }
}