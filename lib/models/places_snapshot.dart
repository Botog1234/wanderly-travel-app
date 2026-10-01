import 'place.dart';

class PlacesSnapshot {
  final List<Place> places;
  final DateTime lastUpdated;
  final bool isFromCache;

  PlacesSnapshot({
    required List<Place> places,
    required this.lastUpdated,
    required this.isFromCache,
  }) : places = List.unmodifiable(places);
}